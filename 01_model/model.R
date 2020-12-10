# run this file to create reports of estimated pig abundance per camera site in HTML format
# change parameters in parameters.R as need
# rename each run using the `name_analysis_n_mixture` variable
# report.html can be found in `html/`
source("parameters.R", local = knitr::knit_global())
output_html_name = gsub(" ", "", paste("model_", name_analysis_n_mixture, ".html"))
rmarkdown::render(input = "model.Rmd", output_file = here::here("html", output_html_name))

