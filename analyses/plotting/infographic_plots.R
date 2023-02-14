library(here)
library(dplyr)
library(tidyr)
library(magrittr)
library(tibble)
library(ggplot2)
library(rprojroot)

# library(eurostat)
# library(sf)
# library(ggthemes)
library(scales)
# library(ggthemes)
library(tidyverse)
library(urbnthemes)
library(waffle)

library(showtext)

# TODO: import dataset here ....

root <- find_root(has_file("README.md"))
df <- read.csv(here(root, "data", "gdpr_compliancy_data_full.csv"))

set_urbn_defaults(style="print")
options(scipen=10000)

# Welcome back, Marcus
# TODOs:
#   * port all the plots to this method and start prodcuing the three plots for inforgraphic
#   * Meanwhile, figure out how to make infographic in latex and export plots to pdf
#   * also build up documentation and install requirements script (and check if need fontawesome

# The different categories can be seperates into 4 disjoint sets:
#  +-----------------------+
#  |      /-----+-----\    |
#  |  A  (  B / C \ D )    |
#  |     \----+-+-+---/    |
#  +-----------------------+
#
#  where:
#   C = websites using google adsense and has a cookie compliance banner
#   B = websites using a cookie compliance banner, but without google ads
#   D = websites using google ads, but without cookie compliance banner (GDPR violation)
#   A = websites doing none of the above
#  and we currently have:
#   num_unique_pages_legal_google_ads        = C
#   num_unique_pages_with_google_ads         = C + D
#   num_unique_pages_with_cookie_compliance  = B + C
#   num_unique_pages                         = A + B + C + D
# divide all the numbers by this value
quantity = 10000
tibble(df) %>%
  mutate(D = num_unique_pages_with_google_ads - num_unique_pages_legal_google_ads) %>%
  mutate(B = num_unique_pages_with_cookie_compliance - num_unique_pages_legal_google_ads) %>%
  mutate(C = num_unique_pages_legal_google_ads) %>%
  mutate(A = num_unique_pages - B - C - D) %>%
  select(tld, A, B, C, D) %>%
  summarise(`Cookie consent banner, but no Google ads` = sum(D) / quantity,
            `Google ads with consent` = sum(C) / quantity,
            `Google ads without consent` = sum(B) / quantity,
            `No cookie consent banner and no Google ads` = sum(A) / quantity) %>%
  mutate(ignore = 1) %>%
  pivot_longer(cols = !ignore) %>%
  select(name, value) -> waffle_data

# Manually inserting the fonts and drawing the .eps file using
# low-level methods was the only way I could create R plots with
# Lato fonts on Linux after 3 hours of trying    :/
font.add("Lato",
         regular = here("fonts", "Lato-Regular.ttf"),
         bold = here("fonts", "Lato-Bold.ttf"),
         italic = here("fonts", "Lato-Italic.ttf"),
         bolditalic = here("fonts", "Lato-BoldItalic.ttf"))
setEPS()
postscript(here(root, "outputs", "internet_waffle.eps"),
           width = 8,
           height = 20)
showtext.begin()

# create the plot
waffle_data %>%
  ggplot(aes(fill=name, values=value)) +
  geom_waffle(
    # size = 1,
    n_rows = 10,
    flip = TRUE,
    # radius = unit(1, "pt"),
    height = 5,
    width = 5,
  ) #+
  # facet_wrap(~location, nrow = 1, strip.position = "bottom") +
  scale_fill_manual(
    values = c(alpha("#000000", 1), alpha("#d2d2d2", 1), "#fdbf11", alpha("#1696d2", 1))
  ) +
    # MAYBE CHANGE THIS ????
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = function(x) x * quantity,
                     expand = c(0, 0),
                     breaks = scales::pretty_breaks(n = 10)
                     ) +
  coord_equal() +
  labs(
    title = "The Websites of the Internet,",
    subtitle = "Seperated by Their Use of Advertisements\n and Cookie Compliance Banners",
    x = "1 square = 10 000 websites",
    y = ""
  ) +
  theme_minimal(base_family = "Lato") +
  theme(
    panel.grid = element_blank(),
    axis.ticks.y = element_line(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    legend.position = "bottom",
    legend.spacing.x = unit(0, "cm"),
    legend.spacing.y = unit(3, "cm"),
    plot.title.position = "plot"
  ) +
  guides(fill = guide_legend(
    title = "",
    reverse = TRUE,
    nrow = 4
    )
  )

dev.off()

# TODO: make this for the total number of websites instead
# Then make proportion bar plot comparing the three categories of websites to highlight proportions
# also, with cateogires: EU-country, other-country TLD, international, other