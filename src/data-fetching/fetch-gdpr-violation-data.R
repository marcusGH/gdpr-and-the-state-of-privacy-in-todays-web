library(bigrquery)
library(DBI)
library(rprojroot)

root_dir <- find_root(has_file("README.md"))
source(here(root_dir, "src", "helper-functions", "sql-query-utils.R"))

con <- dbConnect(
  bigrquery::bigquery(),
  project = "httparchive",
  billing = getOption("bigquery_billing_ID")
)

# === Fetch the sample table ===
# Note: this table will not be used, but you can run this code
# to make sure everything is working correctly before spending
# 170 GB of BigQuery credits running the full query
# ==============================

# create the query
create_gdpr_compliancy_query("gdpr-compliancy-query-sample.sql", full = FALSE)
# parse query to R string
sql <- parse_sql_query(here(root_dir, "sql", "queries", "gdpr-compliancy-query-sample.sql"))
print(paste0("SQL query: ", sql))
# query Google BigQuery using the API
gdpr_table <- DBI::dbGetQuery(con, sql)
# save the file for use in plotting
write.csv(gdpr_table, here(root_dir, "data", "gdpr-compliancy-data-sample.csv"), row.names = FALSE)

# === Fetch the full table ===
#        !!! WARNING !!!
# This code will execute an expensive query that joins a table
# with 1 billion rows with another table containing 1 million rows,
# so it will use about 170 GB of your Google BigQuery processing quota.
# Make sure you have at least this much credit available in your
# billing key before running this code.
#        !!! WARNING !!!
# ============================

# create the query
create_gdpr_compliancy_query("gdpr-compliancy-query-sample.sql", full = TRUE)
# parse query to R string
sql <- parse_sql_query(here(root_dir, "sql", "queries", "gdpr-compliancy-query-full.sql"))
print(paste0("SQL query: ", sql))
# query Google BigQuery using the API
gdpr_table <- DBI::dbGetQuery(con, sql)
# save the file for use in plotting
write.csv(gdpr_table, here(root_dir, "data", "gdpr-compliancy-data-full.csv"), row.names = FALSE)
