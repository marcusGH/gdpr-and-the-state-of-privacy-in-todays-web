library(rvest)
library(magrittr)
library(dplyr)

#' Title
#'
#' @return
#' @export
#'
#' @examples
get_gdpr_tlds <- function() {
  # This website has a list of all TLDs belonging to the EEA,
  #   in which the GDPR applies
  read_html("https://www.whois365.com/en/listtld/europe") %>%
    html_element(".tldtable") %>%
    html_table() %>%
    # We get two columns with the same name, so rename on of them
    rename("None" = 2) %>%
    # there are intermediate rows in the table we don't want
    filter(!TLD == "TLD") %>%
    # discard alternative TLDs like .бел
    filter(nchar(TLD) == 3) %>%
    # this column has the TLDs
    pull(1) %>%
    # remove the dot
    sub('.', '', .)
}
