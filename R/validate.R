#' Check that a character vector contains valid NAICS codes
#'
#' `is_naics` form is a predicate
#' `assert_naics` form is an assertion
#'
#' @name is_naics
NULL

#' @rdname is_naics
#' @param naics character vector of candidate codes
#' @export
is_naics <- function(naics) {
  if (! is.character) stop ("Parameter `naics` must be a character vector.")

  is.element(naics, naics_2017$naics)
}

#' @rdname is_naics
#' @export
assert_naics <- function(naics) {
  if (! all(is_naics(naics))) stop("All values must be valid NAICS 2017 codes.")
  invisible(naics)
}
