library(yaml)
library(here)
library(rprojroot)
library(magrittr)

#' Title
#'
#' @param template_path 
#' @param save_path 
#' @param params 
#'
#' @return
#' @export
#'
#' @examples
process_sql_template <- function(template_path, save_path, params) {
  query_lines  <- readLines(template_path)
  for (key in names(params)) {
    query_lines <- gsub(pattern = paste0("\\{\\{", key, "\\}\\}"), replace = params[key], x = query_lines)
  }
  writeLines(query_lines, con=save_path)
}


#' Title
#'
#' @param query_path 
#'
#' @return
#' @export
#'
#' @examples
parse_sql_query <- function(query_path) {
  file_handler <- file(query_path, "r")
  query <- ""
  
  while (TRUE){
    line <- readLines(file_handler, n = 1)
    # end of line
    if ( length(line) == 0 ){
      break
    }
    # replace tabs
    line <- gsub("\\t", " ", line)
    # replace comments with multi-line comments
    if (grepl(pattern="--", x=line)) {
      line <- paste0(sub("--", "/*", line), "*/")
    }
    query <- paste(query, line, delim=" ")
  }
  close(file_handler)
  return (query)
}
