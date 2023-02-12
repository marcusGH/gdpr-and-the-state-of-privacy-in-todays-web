library(here)
library(magrittr)
library(rprojroot)
library(yaml)

source(here(find_root(has_file("README.md")), "src", "helper_functions", "sql_query_utils.R"))

#' Title
#'
#' @param full
#' @param filename
#' @return
#' @export
#'
#' @examples
create_gdpr_compliancy_query <- function(full = FALSE, filename) {
  proj_root <- find_root(has_file("README.md"))
  # read the configured table names and third party list
  config <- yaml.load_file(here(proj_root, "config.yaml"))
  
  third_party_cond <- paste(
    sapply(config$third_parties, function(tp) paste0("CONTAINS_SUBSTR(req.url, '", tp, "') OR")),
    collapse = "\n"
  )
  
  third_party_cond <- config$third_parties %>%
    # wrap the url in appropriate SQL syntax
    sapply(function(x) paste0("CONTAINS_SUBSTR(req.url, '", x, "') OR")) %>%
    paste(collapse="\n") %>%
    # remove the last 'OR'
    substr(start=1, stop=nchar(.)-3)
  
  params <- list(
    REQUESTS_TABLE=ifelse(full, config$summary_requests_table_full, config$summary_requests_table_small),
    PAGES_TABLE=ifelse(full, config$summary_pages_table_full, config$summary_pages_table_small),
    TECHNOLOGIES_TABLE=ifelse(full, config$technologies_table_full, config$technologies_table_small),
    THIRD_PARTY_COND=third_party_cond
  )
  
  # Process the SQL template with these parameters
  process_sql_template(
    template_path=here(proj_root, "sql", "templates", "gdpr_compliancy_by_country_time_template.sql"),
    save_path=here(proj_root, "sql", "queries", filename),
    params=params
  )
}

create_gdpr_compliancy_query(full = TRUE, "gdpr_compliancy_query_full.sql")
create_gdpr_compliancy_query(full = FALSE, "gdpr_compliancy_query_sample.sql")