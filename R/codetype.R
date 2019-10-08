#codetype.R

#' Determine NAICS code type between standard codes and NAICS-based rollup categories
#'
#' @param naics_code character vector of possibly valid codes
#' @param naics_version length-1 character indicating version
#' @param naics_listing datrframe with naics code information, defaults to 2017 version
#'
#' Only one of `naics_version` and `naics_listing` should be supplied. If both are supplied, `naics_listing` is used.
#' @export
#' @examples
#' select(ex_asm09, naics_2007, naics_label_2007) %>% mutate( type = naics_code_type(naics_2007)) %>% View()
naics_code_type <- function(naics_code,
                            naics_version = c("2002", "2007", "2012", "2017"),
                            naics_listing = naicsmatch::naics_2017) {

  reg_rollup_2dash <- "^[:digit:]{2}-[:digit:]{2}$"
  reg_6digit <- "^[:digit:]{6}$"
  reg_5digit <- "^[:digit:]{5}$"
  reg_5digitMNP <- "^[:digit:]{5}[MNP]$"
  reg_4digit <- "^[:digit:]{4}$"
  reg_3digit <- "^[:digit:]{3}$"

  type <- case_when(
    str_detect(naics_code, reg_6digit) ~ "std",
    str_detect(naics_code, reg_5digit) ~ "std",
    str_detect(naics_code, reg_4digit) ~ "std",
    str_detect(naics_code, reg_3digit) ~ "std",

    str_detect(naics_code, reg_5digitMNP) ~ "rollup",
    str_detect(naics_code, reg_rollup_2dash) ~ "rollup",
    TRUE ~ NA_character_
  )

  type
}

#' Determine NAICS code aggregation level (2, 3, 4, 5, or 6-digit)
#'
#' @param naics_code character vector of possibly valid codes
#' @param naics_version length-1 character indicating version
#' @param naics_listing datrframe with naics code information, defaults to 2017 version
#'
#' Only one of `naics_version` and `naics_listing` should be supplied. If both are supplied, `naics_listing` is used.
#' @export
#' @examples
#' select(ex_asm09, naics_2007, naics_label_2007) %>% mutate( level = naics_code_level(naics_2007)) %>% View()
naics_code_level <- function(naics_code,
                            naics_version = c("2002", "2007", "2012", "2017"),
                            naics_listing = naicsmatch::naics_2017) {

  reg_rollup_2dash <- "^[:digit:]{2}-[:digit:]{2}$"
  reg_6digit <- "^[:digit:]{6}$"
  reg_5digit <- "^[:digit:]{5}$"
  reg_5digitMNP <- "^[:digit:]{5}[MNP]$"
  reg_4digit <- "^[:digit:]{4}$"
  reg_3digit <- "^[:digit:]{3}$"

  level <- case_when(
    str_detect(naics_code, reg_6digit) ~ "6-digit",
    str_detect(naics_code, reg_5digit) ~ "5-digit",
    str_detect(naics_code, reg_4digit) ~ "4-digit",
    str_detect(naics_code, reg_3digit) ~ "3-digit",

    str_detect(naics_code, reg_5digitMNP) ~ "6-digit",
    str_detect(naics_code, reg_rollup_2dash) ~ "2-digit",
    TRUE ~ NA_character_
  )

  level
}
