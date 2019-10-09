# listings.R
# TODO: a place to document the naics listings

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

  # version should be NA or length 1 character
  stopifnot(length(version) == 1)
  stopifnot(is.na(version) || is.character(version))

  # either version or listing should be supplied
  if(is.na(version) & is.null(listing)) stop("No listing supplied or version.")
  if(!is.na(version) & !is.null(listing)) stop("Provide only one of `version` or `listing`")

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

    if (is.data.frame(listing)) {
      # listing is a df already
      listing

      # TODO: could at least standardize column name...

    } else {
      # listing is a vector
      tibble(naics = listing)
    }
  }
}
