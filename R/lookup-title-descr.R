#' @name details
NULL

#' Lookup Titles and Descriptions of NAICS Codes
#'
#' Convenience function. Focus on most recent NAICS code classifications. Lookup for prior may be added in teh
#' @param naics a character vector of NAICS codes to look up
#' @rdname details
#' @export
naics_title <- function(naics) {

  tibble::tibble(naics = naics) %>%
    left_join(naics_2017, by = "naics") %>%
    pull(title)

}

#' @rdname details
#' @export
naics_descr <- function(naics) {

  tibble::tibble(naics = naics) %>%
    left_join(naics_2017, by = "naics") %>%
    pull(descr)

}
