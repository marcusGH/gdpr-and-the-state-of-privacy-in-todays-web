library(dplyr)
library(tibble)


root_dir <- find_root(has_file("README.md"))
df <- data.frame(read.csv(here(root_dir, "data", "gdpr_compliancy_data_sample.csv")))

source(here(root_dir, "src", "data_fetching", "get_gdpr_tlds.R"))

head(df)

tib <- tibble(tld=df$tld, num_sites=df$num_unique_pages, sites=1 - df$num_unique_pages_legal_third_party /  df$num_unique_pages_with_third_party_requests, reqs=df$num_gdpr_violations/df$num_third_party)
print(arrange(tib, sites, reqs), n=20)

tib <- tibble(tld=df$tld, reqs=df$num_requests, viol=df$num_gdpr_violations)
print(arrange(tib, -reqs), n=30)


df <- data.frame(read.csv(here(root_dir, "data", "gdpr_compliancy_data_full.csv")))

tib <- tibble(tld=df$tld, viol=df$num_google_ads_violations/df$num_requests)
print(arrange(tib, -viol), n=100)

tlds <- get_gdpr_tlds()

tib <- tib %>%
  filter(tld %in% tlds)

print(arrange(tib, viol), n=30)
