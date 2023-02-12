library(bigrquery)
library(DBI)

con <- dbConnect(
  bigrquery::bigquery(),
  project = "httparchive",
  billing = getOption("bigquery_billing_ID")
)
con

# open up authentication in browser window
# and accept permissions
dbListTables(con)

sql <- "SELECT * FROM `httparchive.sample_data.summary_pages_desktop_10k` LIMIT 10"

table2 <- DBI::dbGetQuery(con, sql, n = 10)

write.csv(table2, here(getwd(), "data", "test_data.csv"), row.names = FALSE)

