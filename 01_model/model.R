source("parameters.R", local = knitr::knit_global())
output_html_name = gsub(" ", "", paste("model_", name_analysis_n_mixture, ".html"))
rmarkdown::render(input = "model.Rmd", output_file = here::here("html", output_html_name))

