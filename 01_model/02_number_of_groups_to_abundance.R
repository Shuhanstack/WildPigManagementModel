# load packages
library(sf)
library(tidyverse)
library(here)
library(janitor)


# ========================= set up parameters ==================================== #
## ONLY set up parameters in the following lines of code if running this script by itself
#
## the directory of the estimated number of group at each camera station (site) 
## (i.e. the output from N-mixture model by group):
# directory_result_n_mixture = here::here("output", "NumGroupPerStatn","NumGroupPerStatn_**.csv")
#
## where to store the output:
# directory_site_abundance = 
# datatable_name_abundance = here::here("output", "site_abundance", "site_abundance_**.csv")
# ========================= END of set up parameters ============================== #


# read in data
group_size_data <- read_csv(here::here("scratch", "PigGroupSize.csv"))


# 0. Workflow of this file
# - find overall probability for each group size  
# - find weighted average (W = sum(w_i*X_i)/sum(w_i)of group size for each camera station
# - use weighted average of group size and number of groups to find abundance at each camera station during April and September check respectively
# - save results as csv in `/intermediate_data/` and shapefile in `/cleaned_data/`

# 1. Overall probability for each group size
group_size_prob <- group_size_data %>% 
  group_by(group_size) %>% 
  summarize(n = n()) %>% 
  ungroup() %>% 
  mutate(total = sum(n),
         prob = n/total)


# 2. Weighted average by site
weighted_avg <- function(data, prob){
  x <- unique(data)
  w <- filter(prob, group_size %in% x)$prob
  weighted.mean(x, w, na.rm = TRUE)
}

mean_site <- group_size_data %>% 
  group_by(camera_id) %>% 
  summarize(weight_mean_group_size = weighted_avg(group_size, group_size_prob))

# 3. Find abundance at each camera station 
# read in number of group 

group_num <- read_csv(directory_result_n_mixture) %>% 
  clean_names()

# join data
join_group_num_mean_site <- group_num %>% 
  left_join(mean_site) 

# calculate abundance
site_abundance<- join_group_num_mean_site %>% 
  mutate(weight_site_abundance = estimated_num_group*weight_mean_group_size, 
         time_period_starts = lubridate::ymd(readr::parse_number(gsub("_", "", begin_visit))),
         time_period_ends = lubridate::ymd(readr::parse_number(gsub("_", "", end_visit)))) %>% 
  rename(estimated_number_of_group = estimated_num_group)

# 4. Save CSV

write_csv(site_abundance, directory_site_abundance)




