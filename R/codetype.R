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
#' dplyr::select(ex_asm09, naics_2007, naics_label_2007) %>% dplyr::mutate( type = naics_code_type(naics_2007))
naics_code_type <- function(naics_code,
                            naics_version = c("2002", "2007", "2012", "2017"),
                            naics_listing = naicsmatch::naics_2017) {

  reg_2to6digit <- "^[:digit:]{2,6}$"

  reg_rollup_2dash <- "^[:digit:]{2}-[:digit:]{2}$" #ASM, IO
  reg_5digitMNP <- "^[:digit:]{5}[MNP]$" #ASM
  reg_6digitdash <- "^[:digit:]{6}-[:digit:]$" #MECS

  type <- case_when(
    str_detect(naics_code, reg_2to6digit) ~ "std",

    str_detect(naics_code, reg_5digitMNP) ~ "rollup",
    str_detect(naics_code, reg_rollup_2dash) ~ "rollup",
    str_detect(naics_code, reg_6digitdash) ~ "rollup",

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
#' @import stringr
#' @examples
#' dplyr::select(ex_asm09, naics_2007, naics_label_2007) %>% dplyr::mutate( level = naics_code_level(naics_2007))
naics_code_level <- function(naics_code,
                            naics_version = c("2002", "2007", "2012", "2017"),
                            naics_listing = naicsmatch::naics_2017) {

  reg_rollup_2dash <- "^[:digit:]{2}-[:digit:]{2}$"
  reg_6digit <- "^[:digit:]{6}$"
  reg_5digit <- "^[:digit:]{5}$"
  reg_5digitMNP <- "^[:digit:]{5}[MNP]$"
  reg_4digit <- "^[:digit:]{4}$"
  reg_3digit <- "^[:digit:]{3}$"
  reg_2digit <- "^[:digit:]{2}$"
  reg_6digitdash <- "^[:digit:]{6}-[:digit:]$" #MECS

  level <- case_when(
    str_detect(naics_code, reg_6digit) ~ "6-digit",
    str_detect(naics_code, reg_5digit) ~ "5-digit",
    str_detect(naics_code, reg_4digit) ~ "4-digit",
    str_detect(naics_code, reg_3digit) ~ "3-digit",
    str_detect(naics_code, reg_2digit) ~ "2-digit",

    str_detect(naics_code, reg_5digitMNP) ~ "6-digit",
    str_detect(naics_code, reg_rollup_2dash) ~ "2-digit",
    str_detect(naics_code, reg_6digitdash) ~ "6-digit",

    TRUE ~ NA_character_
  )

  level
}

#' Return containing naics category
#'
#' @param naics_code Currently works through substring, only for standard-ish codes
#' @param level either numeric or character, e.g., "5-digit", "5", or 5
#' @return character vector up to the appropriate level
#' @examples
#' naics_containing("335221", 5)
#' naics_containing("335221", "5")
#' naics_containing("335221", "5-digit")
#' @export
naics_containing <- function(naics_code, level = "5-digit") {

  stopifnot(length(level) == 1)

  if(is.character(level) & str_detect(level, "^[:digit:]-digit$")) {
    digits <- str_extract(level, "^[:digit:](?=-digit$)")
  } else if(is.character(level) & str_detect(level, "^[:digit:]$")) {
    digits <- as.numeric(level)
  } else if(is.numeric(level) & level >= 1 & level <= 6) {
    digits <- level
  }

  res <- str_sub(naics_code, 1, digits)
  res
}
