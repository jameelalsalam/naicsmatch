# Ways of combining two data frames by preference
# Some background discussion and implementations:
# https://github.com/tidyverse/tidyr/issues/183
# https://github.com/tidyverse/dplyr/issues/4595#issuecomment-547420916 # lionel- implementation of df_partition, df_update

#' Coalesce two data frames by rows
#' 
#' @params x, y dataframes with identical columns
#' @param by a character vector specifying id columns, as in dplyr joins
#' 
#' @export 
coalesce_rows <- function(x, y, by) {
  
  dplyr::bind_rows(
    x,
    dplyr::anti_join(y, x, by = by)
  )
}

#' Filter for rows that have !is.na of several variables
#' 
#' @param data
#' @export
filter_complete <- function(data, ...) {
  
  myvars <- enquos(...)
  
  filter_at(data,
            .vars = myvars,
            all_vars(!is.na(.)))
}

#' Filter for single-valued combos
#' 
#' @param data
#' @export
filter_single_valued <- function(data, ...) {
  
  myvars <- enquos(...)
  
  data %>%
    group_by_at(.vars = myvars) %>%
    filter(n() == 1) %>%
    ungroup()
}