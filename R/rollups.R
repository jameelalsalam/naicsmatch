# rollups.R

#' Determine categories included in NAICS-based rollups
#'
#' @param naics_code character vector of possibly valid codes
#' @param naics_version length-1 character indicating version
#' @param naics_listing datrframe with naics code information, defaults to 2017 version
#'
#' Only one of `naics_version` and `naics_listing` should be supplied. If both are supplied, `naics_listing` is used.
#'
#' This version specifically deals with 6-digit rollups, such as "12345M"
#' @return list of character vectors representing the set for each rollup. For standard codes, same is returned, (for invalid codes, NA is returned??).
#'
#' @export
rollup_set_6digit <- function(
  naics_code,
  naics_version = c("2002", "2007", "2012", "2017"),
  naics_listing = naicsmatch::naics_2017) {

  data <- tibble(naics = naics_code) %>%
    mutate(
    level = naics_code_level(.data$naics),
    type = naics_code_type(.data$naics)
  ) %>%
    mutate(
      containing_5digit = if_else(
        level == "6-digit",
        str_sub(naics, 1, 5), NA_character_
      )) %>%
    filter(!is.na(containing_5digit)) %>%
    group_by(containing_5digit) %>%
    mutate(naics_set_data = list(unique(naics))) %>%
    ungroup()

  grps <- naics_listing %>%
    mutate(level = naics_code_level(naics),
           type  = naics_code_type(naics),
           containing_5digit = if_else(
             level == "6-digit",
             str_sub(naics, 1, 5), NA_character_
           )) %>%
    filter(! is.na(containing_5digit)) %>%
    group_by(containing_5digit) %>%
    summarize(naics_set_listing = list(unique(naics))) %>%
    ungroup()

  data_2 <- left_join(data, grps, by = "containing_5digit") %>%
    mutate(naics_set = map2(
      naics_set_listing, naics_set_data, ~setdiff(.x, .y))) %>%
    filter(type == "rollup") %>%
    select(naics, level, type, naics_set)

  res <- tibble(
      naics = naics_code,
      level = naics_code_level(naics),
      type = naics_code_type(naics)
    ) %>%
    left_join(
      select(data_2, naics, naics_set), by = "naics"
    ) %>%
    mutate(., naics_set =
             map2(.data$naics_set, .data$naics,
                  ~if(is.null(.x)) .y else .x))

  pull(res, naics_set)
}
