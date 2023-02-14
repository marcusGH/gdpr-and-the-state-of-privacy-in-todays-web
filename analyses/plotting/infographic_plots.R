library(here)
library(dplyr)
library(tidyr)
library(magrittr)
library(tibble)
library(ggplot2)
library(rprojroot)
library(scales)
library(tidyverse)
library(urbnthemes)
library(waffle)

library(showtext)

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
quantity = 50000
tibble(df) %>%
  mutate(D = num_unique_pages_with_google_ads - num_unique_pages_legal_google_ads) %>%
  mutate(B = num_unique_pages_with_cookie_compliance - num_unique_pages_legal_google_ads) %>%
  mutate(C = num_unique_pages_legal_google_ads) %>%
  mutate(A = num_unique_pages - B - C - D) %>%
  select(tld, A, B, C, D) %>%
  summarise(`Cookie consent banner, but no Google ads` = sum(D) / quantity,
            `Google ads with consent` = sum(C) / quantity,
            `Google ads without consent` = sum(B) / quantity,
            `No consent banner and no Google ads` = sum(A) / quantity) %>%
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
           width = 10,
           height = 20)
showtext.begin()


# create the plot
waffle_data %>%
  ggplot(aes(fill=name, values=value)) +
  # uncount(ceiling(value)) %>%
  # waffle_iron(aes_d(group = name)) %>%
  # ggplot(aes(x, y, fill = group)) +
  geom_waffle(
    size = .2,
    n_rows = 10,
    flip = TRUE,
    radius = unit(.5, "pt"),
    height = 0.6,
    width = 0.6,
  )  +
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
    subtitle = "Seperated by Their Use of Ads\n and Cookie Compliance Banners",
    x = "1 square = 50 000 websites",
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
    plot.title.position = "plot",
    # font sizes. The only way to scale the boxes is to
    # set the scale when including the graphic into latex, and
    # then increasing the font size to counteract this caling
    text = element_text(size = 12 * 1/.35),
    plot.title = element_text(size = 18 * 1/.35),
    plot.subtitle = element_text(size = 14 * 1/.35),
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

(15.7 + 2.61) / (15.7 + 2.61 + 23.7 + 211)
