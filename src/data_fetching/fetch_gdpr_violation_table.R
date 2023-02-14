library(bigrquery)
library(DBI)

root_dir <- find_root(has_file("README.md"))
source(here(root_dir, "src", "helper_functions", "sql_query_utils.R"))

con <- dbConnect(
  bigrquery::bigquery(),
  project = "httparchive",
  dataset = "sample_data",
  billing = getOption("bigquery_billing_ID")
)

# Fetch the sample table
sql <- parse_sql_query(here(root_dir, "sql", "queries", "gdpr_compliancy_query_sample.sql"))
print(paste0("SQL query: ", sql))
gdpr_table <- DBI::dbGetQuery(con, sql)
write.csv(gdpr_table, here(root_dir, "data", "gdpr_compliancy_data_sample.csv"), row.names = FALSE)

# Fetch the full table
sql <- parse_sql_query(here(root_dir, "sql", "queries", "gdpr_compliancy_query_full.sql"))
print(paste0("SQL query: ", sql))
gdpr_table <- DBI::dbGetQuery(con, sql)
write.csv(gdpr_table, here(root_dir, "data", "gdpr_compliancy_data_full.csv"), row.names = FALSE)
