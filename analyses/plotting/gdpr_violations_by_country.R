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
library(showtext)
library(eurostat)

root <- find_root(has_file("README.md"))
df <- read.csv(here(root, "data", "gdpr_compliancy_data_full.csv"))
df$tld <- toupper(df$tld)

set_urbn_defaults(style="print")
options(scipen=10000)


eu_tlds <- eu_countries %>%
  select(code) %>%
  pull()

tibble(df) %>%
  summarise(prop = sum(num_google_ads_violations) / sum(num_requests)) %>%
  pull() -> international_avg
international_avg <- international_avg * 100

tibble(df) %>%
  filter(tld %in% eu_tlds == FALSE) %>%
  summarise(prop = sum(num_google_ads_violations) / sum(num_requests)) %>%
  pull() -> non_eu_avg
non_eu_avg <- non_eu_avg * 100

tibble(df) %>%
  filter(tld %in% eu_tlds) %>%
  summarise(prop = sum(num_google_ads_violations) / sum(num_requests)) %>%
  pull() -> eu_avg
eu_avg <- eu_avg * 100


# Manually inserting the fonts and drawing the .eps file using
# low-level methods was the only way I could create R plots with
# Lato fonts on Linux after 3 hours of trying    :/
font.add("Lato",
         regular = here("fonts", "Lato-Regular.ttf"),
         bold = here("fonts", "Lato-Bold.ttf"),
         italic = here("fonts", "Lato-Italic.ttf"),
         bolditalic = here("fonts", "Lato-BoldItalic.ttf"))
setEPS()
postscript(here(root, "outputs", "gdpr_by_country.eps"),
           width = 17,
           height = 15)
showtext.begin()

latex_scaling <- .23

tibble(df) %>%
  filter(tld %in% eu_tlds) %>%
  mutate(proportion_violation = 100 * num_google_ads_violations / num_requests) %>%
  rename(code = tld) %>%
  # to get the country names
  left_join(eu_countries, by = "code") %>%
  select(name, proportion_violation) %>%
  arrange(proportion_violation) %>%
  # ensure the countries will appear in sorted order
  mutate(name = factor(name, levels = .$name)) %>%
  ggplot(aes(proportion_violation, name)) +
    # add intercepts
    geom_vline(
      xintercept=international_avg,
      linetype="dashed",
      size=2,
      color = "#1696d2",
      ) +
    geom_vline(
      xintercept=non_eu_avg,
      linetype="dashed",
      size=2,
      color = "#1696d2",
      ) +
    geom_vline(
      xintercept=eu_avg,
      linetype="dashed",
      size=2,
      color = "#1696d2",
      ) +
    annotate(
      geom = "text",
      y = Inf, x = 8,
      # The y-axis is not continuous, so position the label by adding 500 space characters :/
      label = paste0("All sites average", paste(replicate(120, " "), collapse = "")),
      angle = 90,
      size = 14
    ) +
    annotate(
      geom = "text",
      y = Inf, x = 9,
      # The y-axis is not continuous, so position the label by adding 500 space characters :/
      label = paste0("non-EU sites average", paste(replicate(115, " "), collapse = "")),
      angle = 90,
      size = 14
    ) +
    annotate(
      geom = "text",
      y = Inf, x = 3,
      # The y-axis is not continuous, so position the label by adding 500 space characters :/
      label = paste0("EU sites average", paste(replicate(170, " "), collapse = "")),
      angle = 90,
      size = 14
    ) +
    geom_segment(
      aes(x = 0,
          xend = proportion_violation,
          y = name,
          yend = name
        ),
      linewidth = 2,
      ) +
    geom_point(
      size = 10,
    ) +
    scale_x_continuous(
      expand = expansion(mult = c(0, 0)),
      limits = c(0, 9.999),
      breaks = scales::pretty_breaks(n = 5),
    ) +
    labs(title = "             GDPR Violations by Country",
         y = NULL,
         x = "% of Requests") +
    theme_minimal(base_family = "Lato") +
    theme(
      plot.background = element_rect(fill = "transparent",
                                      colour = NA_character_),
      panel.background = element_rect(fill = "transparent",
                                      colour = NA_character_),
      # panel.grid.major.x = element_blank(),
      # panel.grid.minor.x = element_blank(),
      panel.grid.major.y = element_blank(),
      legend.position = "bottom",
      axis.ticks.x = element_line(size=3),
      axis.ticks.length = unit(.7, "cm"),
      plot.title.position = "plot",
      # font sizes. The only way to scale the boxes is to
      # set the scale when including the graphic into latex, and
      # then increasing the font size to counteract this caling
      text = element_text(size = 12 * 1/latex_scaling, family = "Lato"),
      plot.title = element_text(size = 18 * 1/latex_scaling, family = "Lato"),
      plot.subtitle = element_text(size = 14 * 1/latex_scaling, family = "Lato"),
    )

dev.off()
