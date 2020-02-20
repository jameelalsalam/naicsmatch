# listings.R

#' Retrieve or specify a NAICS listing version
#'
#' @param version a character string, options are 2017, 2012, 2007, and 2002.
#' @param listing a data frame with a `naics` character column or character vector
#'
#' @return data frame version of specified naics listing
#'
#' Only one of `version` or `listing` should be supplied
#'
#' @importFrom tibble tibble
#' @export
naics_listing <- function(version = NA_character_, listing = NULL) {

  version <- as.character(version)
  allowed_versions <- c("2017", "2012", "2007", "2002")

  # input checks

  # either version or listing should be supplied
  if(is.na(version) & is.null(listing)) stop("No listing supplied or version.")
  if(!is.na(version) & !is.null(listing)) stop("Provide only one of `version` or `listing`")

  # version should be NA or length 1 character
  if(! length(version) == 1 | !is.character(version) | (
    !is.na(version) & !version %in% allowed_versions)) {
    stop("When requesting a naics_listing by version, the version parameter must be coercible to a length 1 character vector. Current valid naics listing versions are ", allowed_versions, ". You supplied ", version)
  }

  res <- if(!is.na(version)) {
    # get listing by `version`
    switch (version,
      "2017" = naics_2017_listing,
      "2012" = naics_2012_listing,
      "2007" = naics_2007_listing,
      "2002" = naics_2002_listing
    )

  } else {
    # get listing by `listing`

    if(is.data.frame(listing)) {
      # listing is a df already
      listing

      # TODO: could at least standardize column name...

    } else {
      # listing is a vector
      tibble(naics = listing)
    }
  }

  res
}


#' NAICS Code List Datasets
#'
#' This package contains NAICS code list datasets for the NAICS code definitions for 2017, 2012, 2007, and 2002. Codes are included for all levels of aggregation. Code listings are formatted as dataframes with a single `naics` column. They are downloaded from the U.S. Census.
#'
#' @name naics_listing_data
NULL

#' @rdname naics_listing_data
"naics_2017_listing"

#' @rdname naics_listing_data
"naics_2012_listing"

#' @rdname naics_listing_data
"naics_2007_listing"

#' @rdname naics_listing_data
"naics_2002_listing"
