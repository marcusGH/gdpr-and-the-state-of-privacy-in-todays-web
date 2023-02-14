install.packages("tidyverse")
install.packages("eurostat")


install.packages("remotes")
remotes::install_github("UrbanInstitute/urbnthemes")
remotes::install_github("hrbrmstr/waffle")
devtools::install_github("liamgilbey/ggwaffle")

# Install the Lato font
remotes::install_version('Rttf2pt1', version = '1.3.8')
urbnthemes::lato_import()
extrafont::font_import()
# extrafont::loadfonts(device = "pdf")
# extrafont::loadfonts(device = "postscript")
