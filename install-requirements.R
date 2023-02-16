install.packages(c("DBI",
                   "bigrquery",
                   "dplyr",
                   "eurostat",
                   "ggplot2",
                   "here",
                   "magrittr",
                   "rprojroot",
                   "scales",
                   "showtext",
                   "tibble",
                   "tidyr",
                   "tidyverse"))

install.packages("remotes")
remotes::install_github("UrbanInstitute/urbnthemes")
remotes::install_github("hrbrmstr/waffle")

# Install the Lato font (not necessary anymore because importing manually)
# remotes::install_version('Rttf2pt1', version = '1.3.8')
# urbnthemes::lato_import()
