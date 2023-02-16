library(yaml)
library(here)
library(rprojroot)
library(magrittr)

#' Function for processing a SQL query template
#'
#' Replaces occurrences of {{KEY}} in the SQL query with correspoding
#' values in the params argument for each KEY there.
#'
#' @param template_path path to template SQL file
#' @param save_path path to which the processed query should be written
#' @param params a list of key-values for keys to be replaced in the template
#'
#' @export
#'
#' @examples
#' process_sql_template(
#'     here("templates", "my_query.sql"),
#'     here("queries", "my_query.sql"),
#'     list(COND1="my_col = 4", YEAR="2016")
#' )
process_sql_template <- function(template_path, save_path, params) {
  query_lines  <- readLines(template_path)
  # Replace {{KEY}} by VALUE for each (KEY, VALUE) in params
  for (key in names(params)) {
    # need to escape the curly brackets for the regex, but \ is a
    # special character in R strings, so we also need to escape those
    query_lines <- gsub(pattern = paste0("\\{\\{", key, "\\}\\}"), replace = params[key], x = query_lines)
  }
  writeLines(query_lines, con=save_path)
}

#' Function for reading a SQL query file into an R string that can be used by DBI::dbGetQuery
#'
#' @param query_path path to SQL query file
#'
#' @return string containing the query, with line comments supressed
#' @export
#'
#' @examples
#' sql <- parse_sql_query(here("queries", "my_query.sql"))
#' my_table <- DBI::dbGetQuery(con, sql, n = 10)
parse_sql_query <- function(query_path) {
  file_handler <- file(query_path, "r")
  query <- ""
  
  while (TRUE){
    line <- readLines(file_handler, n = 1)
    # end of file
    if ( length(line) == 0 ){
      break
    }
    # replace tabs
    line <- gsub("\\t", " ", line)
    # replace line comments with multi-line comments 
    if (grepl(pattern="--", x=line)) {
      line <- paste0(sub("--", "/*", line), "*/")
    }
    query <- paste(query, line, delim=" ")
  }
  close(file_handler)
  return (query)
}

#' Uses the SQL template in `sql/templates/` to create the final SQL query
#' 
#' Reads the configuration file and injects the query with
#' the pages, requests, and technology tables of interest.
#'
#' @param filename the name of the output file. Should not include the path
#' @param full boolean, whether to use the large tables or the sample data
#' @export
#'
#' @examples
#' create_gdpr_compliancy_query("query-full.sql", full = FALSE)
create_gdpr_compliancy_query <- function(filename, full = FALSE) {
  proj_root <- find_root(has_file("README.md"))
  # read the configured table names and third party list
  config <- yaml.load_file(here(proj_root, "config.yaml"))
  
  # create the SQL conditional for whether a request is third-party or not
  third_party_cond <- config$third_parties %>%
    # wrap the url in appropriate SQL syntax
    sapply(function(x) paste0("CONTAINS_SUBSTR(req.url, '", x, "') OR")) %>%
    # more readable if on seperate lines
    paste(collapse="\n") %>%
    # remove the last 'OR'
    substr(start=1, stop=nchar(.)-3)
  
  # strings to inject into the template
  params <- list(
    REQUESTS_TABLE=ifelse(full, config$summary_requests_table_full, config$summary_requests_table_small),
    PAGES_TABLE=ifelse(full, config$summary_pages_table_full, config$summary_pages_table_small),
    TECHNOLOGIES_TABLE=ifelse(full, config$technologies_table_full, config$technologies_table_small),
    THIRD_PARTY_COND=third_party_cond
  )
  
  # Process the SQL template with these parameters
  process_sql_template(
    template_path=here(proj_root, "sql", "templates", "gdpr-compliancy-by-country-time-template.sql"),
    save_path=here(proj_root, "sql", "queries", filename),
    params=params
  )
}
