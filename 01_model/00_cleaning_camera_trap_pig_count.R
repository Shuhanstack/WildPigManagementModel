# load packages
library(tidyverse)
library(here)
library(janitor)
library(lubridate)
# install.package("chron")
library(chron)

# 1. Read in data 
pig_image <- timelapse_output %>% 
  clean_names()

# 2. Clean the data
pig_image_partial <- pig_image %>% 
  select(file, relative_path, species, date, time, count_species) %>% 
  mutate(date = dmy(date)) %>% 
  separate(relative_path, into = c("month", "check", "camera_station", "id")) %>% 
  unite("camera_id", camera_station, id, sep = "-") %>% 
  unite("check", month, check)

# 3. Data wrangling

## 3.1. Time difference between two successive images
pig_episode <- pig_image_partial %>%
  mutate(time = chron(times = time), 
         time_diff = NA, 
         episode_id = NA) %>% 
  arrange(camera_id, date, time) 

time_diff = diff(pig_episode$time)
# 1/86400 for one second

time_diff_length <- length(time_diff)

i = 1

for (i in 1:time_diff_length) {
  pig_episode$time_diff[i] = time_diff[i]
  i = i + 1
}

## 3.2. Assign episode
episode = 1

row_n_join_pig = length(pig_episode$file)

for (i in 1:time_diff_length) {
  
  if(pig_episode$time_diff[i] >= 0 & pig_episode$time_diff[i] <= 3.8194444444e-03){
    pig_episode$episode_id[i] = episode # 3.8194444444e-03 is 1/86400 * (5*60 + 30), which is 00:05:30
  }else{
    pig_episode$episode_id[i] = episode
    episode = episode + 1 
  }
}

# assign the last row the same episode as the second last row
pig_episode$episode_id[row_n_join_pig] = pig_episode$episode_id[row_n_join_pig-1]

# 4. Summary analysis 
# - find number of group in each day
# - narrow down time period to 2013 and 2015 (i.e. removed observations in 2015)
# - assume each episode is one group
# - assume groups in each day are different groups
# - assume the group size is the number of pig occurrences per episode, which is the same as the maximum "pig count per image" (i.e. `r countspecies`) in each episode
pig_episode_full_summary<- pig_episode %>% 
  select(episode_id, check, camera_id, date, time, count_species) %>% 
  filter(date < "2015-01-01") %>% 
  rename(group_id = episode_id) %>% # assume one episode contains one group
  group_by(group_id) %>% 
  mutate(time_first_photo_in_group = min(time), # the time when the group first recorded by the camera station
         group_size = max(count_species), # group size is proximated by the maximum number of pig count per image in each group
         num_image_per_group = length(group_id)) %>% 
  ungroup() %>% 
  group_by(camera_id, date) %>%  
  mutate(n_group_per_day = length(unique(group_id)))

# 5. Prepare output data
# creat meaningful subset of data
Pig_NumImgPerGroup <- pig_episode_full_summary%>% 
  select(group_id, check, camera_id, date, time_first_photo_in_group, group_size, num_image_per_group) %>% unique()

# create the full datatable of number of group per day per site 
# - include NA when the cameras did not operate
# - include 0 when there's no records of pigs
NumGroupPerDay_long <- pig_episode_full_summary %>% 
  select(camera_id, date, n_group_per_day) %>% 
  unique()

# read in the full template for numbers of visits per site that also contains NA and 0
aggre_max_count <- model_data_template %>% 
  mutate(date = mdy(date))

# join the number of group to the full datatable
join_maxcount_groupn <- left_join(aggre_max_count, NumGroupPerDay_long)

# replace NA with 0 if the number of individual was 0
join_maxcount_groupn$n_group_per_day[join_maxcount_groupn$max_count==0] <- 0

# remove the column of the number of individual
NumGroupPerDay <- join_maxcount_groupn %>% 
  select(-max_count) 

# 6. Write output data 
write_csv(pig_episode_full_summary, directory_pig_episode_full_summary)
write_csv(Pig_NumImgPerGroup, directory_Pig_NumImgPerGroup)
write_csv(NumGroupPerDay, directory_NumGroupPerDay)




