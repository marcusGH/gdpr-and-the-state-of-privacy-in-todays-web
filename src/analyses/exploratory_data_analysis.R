library(dplyr)
library(tibble)

root_dir <- find_root(has_file("README.md"))
df <- data.frame(read.csv(here(root_dir, "data", "gdpr_compliancy_data_sample.csv")))

head(df)

tib <- tibble(tld=df$tld, num_sites=df$num_unique_pages, sites=1 - df$num_unique_pages_legal_third_party /  df$num_unique_pages_with_third_party_requests, reqs=df$num_gdpr_violations/df$num_third_party)
print(arrange(tib, sites, reqs), n=20)
