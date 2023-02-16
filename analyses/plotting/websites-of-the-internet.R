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
library(eurostat)

library(showtext)

root <- find_root(has_file("README.md"))
df <- read.csv(here(root, "data", "gdpr-compliancy-data-full.csv"))

set_urbn_defaults(style="print")
options(scipen=10000)

# The different categories can be seperated into 4 disjoint sets:
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
  # solve the above equations for A, B, C, and D
  mutate(D = num_unique_pages_with_google_ads - num_unique_pages_legal_google_ads) %>%
  mutate(B = num_unique_pages_with_cookie_compliance - num_unique_pages_legal_google_ads) %>%
  mutate(C = num_unique_pages_legal_google_ads) %>%
  mutate(A = num_unique_pages - B - C - D) %>%
  select(tld, A, B, C, D) %>%
  # rename the columns to descriptive name, and make each box equal to 50k sites
  summarise(`Cookie consent banner, but no Google ads` = sum(B) / quantity,
            `Google ads with consent` = sum(C) / quantity,
            `Google ads without consent` = sum(D) / quantity,
            `No consent banner and no Google ads` = sum(A) / quantity) %>%
  # transform data into suitable geom_waffle format
  mutate(ignore = 1) %>%
  pivot_longer(cols = !ignore) %>%
  select(name, value) -> waffle_data

# Manually inserting the fonts and drawing the .eps file using
# low-level methods was the only way I could create R plots with
# Lato fonts on Linux after 3 hours of trying  :/
font.add("Lato",
         regular = here(root, "fonts", "Lato-Regular.ttf"),
         bold = here(root, "fonts", "Lato-Bold.ttf"),
         italic = here(root, "fonts", "Lato-Italic.ttf"),
         bolditalic = here(root, "fonts", "Lato-BoldItalic.ttf"))
# we need to draw on this device
setEPS()
postscript(here(root, "outputs", "internet-waffle.eps"),
           width = 10,
           height = 20)
# open the device
showtext.begin()

# We import the graphic in latex with scale .35
# Needed later when setting the font size
latex_scaling <- .33

# create the plot
waffle_data %>%
  ggplot(aes(fill=name, values=value)) +
  geom_waffle(
    size = .2,
    n_rows = 10,
    flip = TRUE,
    radius = unit(.5, "pt"),
    height = 0.6,
    width = 0.6,
  )  +
  # urban theme colours
  scale_fill_manual(
    values = c(alpha("#000000", 1), alpha("#d2d2d2", 1), "#fdbf11", alpha("#1696d2", 1))
  ) +
  scale_x_continuous(labels = scales::comma) +
  # use french numbering style on the y-axis for readability
  # we also need to readjust the values because we divided everything
  # by the quantity above. Also, we have 10 columns, hence "* 10"
  scale_y_continuous(
    labels = function(x, ...)  format(x * 10 * quantity, ..., big.mark = " ", scientific = FALSE, trim = TRUE),
    expand = c(0, 0),
    breaks = scales::pretty_breaks(n = 10)
  ) +
  # make the squares not rectangular
  coord_equal() +
  labs(
    title = "   The Websites of the Internet Seperated\n   by Their Use of Ads and Cookie Banners",
    # subtitle = " Seperated by Their Use of Ads and Cookie Compliance Banners",
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
    # legend.spacing.x = unit(0, "cm"),
    legend.spacing.y = unit(3, "cm"),
    plot.title.position = "plot",
    # The only way to scale the boxes is to
    # set the scale when including the graphic into latex, so
    # we need to set the font size in such a way that it exactly
    # counteracts the latex scaling, in order to comply with the
    # style guide (we use the print guides)
    text = element_text(size = 8.5 / latex_scaling),
    plot.title = element_text(size = 12 / latex_scaling),
    plot.subtitle = element_text(size = 9.5 / latex_scaling),
    axis.title.x = element_text(size = 8.5 / latex_scaling, face = "italic")
  ) +
  guides(fill = guide_legend(
    title = "",
    reverse = TRUE,
    nrow = 4
    )
  )

# close the device and save
dev.off()


#################################################################
# Compute various statistics that are mentioned in text         #
#################################################################

print(paste0("Number of websites: ", sum(df$num_unique_pages)))
print(paste0("Number of requests: ", sum(df$num_requests)))
print(paste0("Proportion of websites using cookie banners: ",
             sum(df$num_unique_pages_with_cookie_compliance) / sum(df$num_unique_pages)))

eu_tlds <- eu_countries %>%
  select(code) %>%
  pull()

# proportion of traffic
tibble(df) %>%
  filter(toupper(tld) %in% eu_tlds) %>%
  pull(num_requests) %>%
  sum() %>%
  divide_by(sum(df$num_requests)) -> traffic_proportion
print(paste0("Proportion of traffic that's directed to EU sites: ", traffic_proportion))
print(paste0("Total requests to EU sites: ", traffic_proportion * sum(df$num_requests)))

# proportion of websites
tibble(df) %>%
  filter(toupper(tld) %in% eu_tlds) %>%
  pull(num_unique_pages) %>%
  sum() %>%
  divide_by(sum(df$num_unique_pages)) -> sites_proportion
print(paste0("Proportion of websites that are EU tld: ", sites_proportion))

# Cookie banner proportion of EU and non_EU
tibble(df) %>%
  filter(toupper(tld) %in% eu_tlds) %>%
  summarise(`Cookie banner proportion` = sum(num_unique_pages_with_cookie_compliance) / sum(num_unique_pages)) %>%
  pull() %>%
  paste0("EU sites proportion of pages with cookie banner: ", .) %>%
  print()
tibble(df) %>%
  filter(toupper(tld) %in% eu_tlds == FALSE) %>%
  summarise(`Cookie banner proportion` = sum(num_unique_pages_with_cookie_compliance) / sum(num_unique_pages)) %>%
  pull() %>%
  paste0("non-EU sites proportion of pages with cookie banner: ", .) %>%
  print()

# Proportion of EU websites using Google AdSense
tibble(df) %>%
  filter(toupper(tld) %in% eu_tlds) %>%
  summarise(`ads proportion` = sum(num_unique_pages_with_google_ads) / sum(num_unique_pages)) %>%
  # summarise(`ads proportion` = sum(num_google_ads) / sum(num_requests)) %>%
  pull() %>%
  paste0("EU sites proportion of pages with google ads: ", .) %>%
  print()
