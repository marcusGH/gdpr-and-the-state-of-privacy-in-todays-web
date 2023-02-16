library(bigrquery)
library(DBI)

con <- dbConnect(
  bigrquery::bigquery(),
  project = "httparchive",
  dataset = "sample_data",
  billing = getOption("bigquery_billing_ID")
)
con

# this will open up an authentication in your browser
dbListTables(con)
