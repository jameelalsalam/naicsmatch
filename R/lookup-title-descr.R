#' Lookup Titles and Descriptions of NAICS Codes
#'
#' Convenience function. Focus on most recent NAICS code classifications. Lookup for prior may be added in teh
#' @param naics a character vector of NAICS codes to look up
#' @aliases naics_descr
#' @import dplyr
#' @export
#' @examples
#' naics_title(c("332710", "332722", "332723"))
naics_title <- function(naics) {

  tibble::tibble(naics = naics) %>%
    left_join(naics_2017, by = "naics") %>%
    pull(title)

}

#' @rdname naics_title
#' @export
#' @examples
#' naics_descr(c("332710", "332722", "332723"))
naics_descr <- function(naics) {

  tibble::tibble(naics = naics) %>%
    left_join(naics_2017, by = "naics") %>%
    pull(descr)

}
