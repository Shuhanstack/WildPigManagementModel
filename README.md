# CP - Wild Pig Management
This repo contains data cleaning, wrangling, and analysis scripts for N-mixture modeling, spatial interpolation, and pig occurrence analysis. 

File structure:

- `00_pig_occurrence_per_episode.RMD`: transforms tabular output from Timelapse2 to the number of occurrences in each episode. The output file `pig_occurrence_per_episode.csv` in `cleaned_data/` is used in `02_cleaning_spatial_data.RMD` to filter cameras that had records of wild pigs during the period of study. 
- `01_model/`: contains scripts that outputs the N-mixture modeling results of estimated wild pig population abundance at each camera site in given time period
  - `00_cleaning_camera_trap_pig_count.R`: clean