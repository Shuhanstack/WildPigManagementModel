library(tidyverse)
library(here)


#===================================================================#
#====================== A. N-Mixture model =========================#
#===================================================================#

#===================================================================#
#                 00_cleaning_camera_trap_pig_count                 #
#===================================================================#

# ------------------ Timelapse output data in CSV -------------------
timelapse_output <- read_csv(here::here("input", "TimelapseData_join_pig_occurrence.csv"))

# ---- Full template of visit per site for N-Mixture model --------
### This template contains visits with zero pigs recorded or visits where some camera stations were not operating (NA)
### data in clean format, not a matrix
model_data_template <- read_csv(here::here("input", "aggregate_pig_perday.csv")) %>% 
  pivot_longer("10/1/2013":"9/30/2014",
               names_to = "date", # one day is one visit
               values_to = "max_count") 

# -----------Output directories and files --------------------------
directory_pig_episode_full_summary = here::here("scratch", "pig_episode_full_summary.csv")
directory_Pig_NumImgPerGroup = here::here("scratch", "PigGroupSize.csv")
directory_NumGroupPerDay = here::here("scratch","NumGroupPerDay.csv")

#===================================================================#
#                    01_n_mixture_model_by_group                    #
#===================================================================#
## select the time period of visits over which you want to run the N-Mixture model
begin_visit = "x2013_10_23"
end_visit = "x2014_04_22"
name_analysis_n_mixture = "April"

## set up model parameters: 
K_n_mixture = 100
# for p and lamnda, you can change them in the `pcount()` function in `01_n_mixture_model_by_group.R`

# -----------Output directories and files --------------------------
datatable_name_n_mixture = gsub(" ", "", paste("NumGroupPerStatn_", name_analysis_n_mixture, ".csv"))
directory_result_n_mixture = here::here("output", "NumGroupPerStatn", datatable_name_n_mixture)

#===================================================================#
#                  02_number_of_groups_to_abundance                 #
#===================================================================#

# -----------Output directories and files --------------------------
datatable_name_abundance = gsub(" ", "", paste("site_abundance_", name_analysis_n_mixture, ".csv"))
directory_site_abundance = here::here("output", "SiteAbundance", datatable_name_abundance)


