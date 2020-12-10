# load packages
library(tidyverse)
library(here)
library(janitor)
library(gt)

# package for N-mixture model 
library(unmarked)

# Method followed [this tutorial](https://mcolvin.github.io/WFA8433/Class-18.html)

# read in data
data_n_mixture_raw <- read_csv(here::here("scratch", "NumGroupPerDay.csv")) %>% 
  clean_names()

# ========================= set up parameters ==================================== #
## ONLY set up parameters in the following lines of code if running this script by itself

## select the time period of visits over which you want to run the N-Mixture model
# begin_visit <- "x2013_10_23"
# end_visit = "x2014_04_22"

# N-Mixture model input:
# K_n_mixture = 100
# for p and lamnda, you can change them directly in the pcount() function.

# name_analysis_n_mixture = "x2013_10"
# datatable_name_n_mixture = gsub(" ", "", paste("NumGroupPerStatn_", name_analysis_n_mixture, ".csv"))
# directory_result_n_mixture = here("output", "NumGroupPerStatn", datatable_name_n_mixture)
# ========================= END of set up parameters ============================== #

# check if the combination of date and camera_id is unique
validate_n_mixture_data <- count(data_n_mixture_raw, date, camera_id) %>% 
filter(n == 2)
try(if(nrow(validate_n_mixture_data) != 0) stop("records of visits and sites are not unique in data used for N-mixture model"))

data_n_mixture_full <- data_n_mixture_raw %>%  
  pivot_wider(names_from = date,
              values_from = n_group_per_day) %>% 
  clean_names()

# filter data to the designated range of visits
data_n_mixture_partial <- data_n_mixture_full %>% 
  select(camera_id, all_of(begin_visit):all_of(end_visit)) 

# count number of column
n_col <- ncol(data_n_mixture_partial)

# filter out rows that only contain NAs
### add another attribute "rowsumna" that sums the number of NA in each row
data_n_mixture_partial$rowsumna = rowSums(is.na(data_n_mixture_partial))
### filter out rows that contain less number of NA than total number of columns minus the first camera id column
data_n_mixture_occurrence<- data_n_mixture_partial %>% 
  filter(rowsumna < n_col - 1) 

# store all camera station id
station_id_n_mixture <- data_n_mixture_occurrence[ ,1]

# use this model for full dates
# transform the class of the data
data_transform_n_mixture <- unmarked::unmarkedFramePCount(y = data_n_mixture_occurrence[, -c(1, n_col+1)])

# fit model
fit_n_mixture <- pcount(~1 ~1, # p = 1, lambda = 1
                    data = data_transform_n_mixture,
                    K = K_n_mixture)

summary(fit_n_mixture)

# detect probability 
detect_prop_n_mixture = plogis(coef(fit_n_mixture)[2])

# estimates of N at each camera station
N_hat_n_mixture <- bup(ranef(fit_n_mixture))

result_n_mixture <- data.frame("Camera_station" = station_id_n_mixture,
                           "Estimated_num_group" = N_hat_n_mixture)

# write output 
write_csv(result_n_mixture, directory_result_n_mixture)












