# ranges.R

#' Determine categories included in NAICS-based ranges
#'
#' @param naics_code character vector of possibly valid codes
#' @param version length-1 character indicating version
#' @param listing dataframe or character vector with naics code information
#'
#' Only one of `version` and `listing` should be supplied.
#'
#' This version specifically deals with ranges (possibly comma delimited) such as are found in BEA IO table data. Trims any *'s.
#' E.g., "123456-8, 111111" -> "123456", "123457", "123458", "111111"
#' @return list of character vectors representing the set for each range. For standard codes, same is returned, (for invalid codes, NA is returned??).
#'
#' @import stringr
#' @export
#' @examples
#' naics_ranges <- io_conc_raw_2002$naics_2002_ranges[1:5]
#' listing <- naicsmatch::naics_2002_listing
#' ranges_to_set_6digit(
#' io_conc_raw_2002$naics_2002_ranges[1:5],
#' listing = naicsmatch::naics_2002_listing
#' )
ranges_to_set_6digit <- function(
  naics_ranges,
  version = NA_character_,
  listing = NULL
) {

  # split by commas, then disaggregate ranges
  data <- tibble(naics_ranges = naics_ranges) %>%
    mutate(naics_range = str_split(naics_ranges, pattern = ",")) %>%
    tidyr::unnest(cols = c(naics_range)) %>%
    mutate(naics_range = str_trim(naics_range)) %>%

    # drop things with *'s?
    # filter(!str_detect("\\*")) %>%

    # trim *'s
    mutate(naics_range = str_remove(naics_range, "[*]")) %>%

    # make ranges from dashed ranges
    mutate(naics_set = make_ranges(naics_range)) %>%
    tidyr::unnest(cols = c(naics_set)) %>%
    mutate(naics_set = if_else(is.na(naics_set), naics_range, naics_set)) %>%

    # characterize code levels to facilitate finding all possible 6-digit within these codes (levels 4-6)
    mutate(
      level = naics_code_level(.data$naics_set)
    )

  listing_containing <- listing %>%
    filter(naics_code_level(naics) == "6-digit") %>%
    mutate(`4-digit` = naics_containing(naics, "4-digit"),
           `5-digit` = naics_containing(naics, "5-digit"),
           `6-digit` = naics)

  listing_6digit <- listing_containing %>%
    rename(naics6 = naics) %>%
    pivot_longer(cols = c("4-digit", "5-digit", "6-digit"),
                 names_to = "level",
                 values_to = "naics")


  # filter actually existing 6-digit codes within listing
  data_preview <- left_join(data, listing_6digit,
                          by = c("level" = "level", "naics_set" = "naics"))

  data_res <- data_preview %>%
    select(naics_ranges, naics6) %>%
    group_by(naics_ranges) %>%
    # want to end up with list of unique vectors...
    summarize(naics_set = list(unique(naics6)))

  res <- left_join(
    tibble(naics_ranges = naics_ranges),
    data_res, by = "naics_ranges"
  )

  pull(res, naics_set)
}

#' Translates ranges into lists of (start, end)
#'
#' Intended for e.g., "123456-8" -> "123456", "123458"
#' @param x character vector of range values
#' @param listing dataframe of NAICS listing to compare against
#' @examples
#' x <- c("111111", "123456-8", "111-20")
#' code_range_lims(x)
#' @import stringr
code_range_lims <- function(x, listing = NULL) {

  is_range <- str_detect(x, "^\\d{2,6}-\\d{1,6}$")

  rng_text <- str_extract(x, "\\d-\\d")

  rng_pre <- str_extract(x, "(\\d{2,5})(?=-\\d)")

  rng_post_leaf <- str_extract(x, "(?<=\\d-)(\\d{1,6})")
  rng_post_len  <- str_length(rng_post_leaf)
  rng_pre_len <- str_length(rng_pre)
  rng_post <- str_c(
    str_sub(rng_pre, 1, rng_pre_len - rng_post_len),
    rng_post_leaf)

  res <- tibble(
    x,
    is_range = is_range,
    start = rng_pre,
    end = rng_post
  ) %>%
    mutate(start = if_else(is_range, start, x),
           end   = if_else(is_range, end, x)) %>%
    select(start, end)

  res
}

# takes a single range per vector position
# returns nested list, with all integer values, handles only 1-digit trailing digit, e.g., "11111-3", NOT eg "111-20"
make_ranges <- function(x) {

  rng_text <- x %>%
    str_extract("\\d-\\d")

  rng_pre <- x %>%
    str_extract("(\\d{3,5})(?=\\d-\\d)")

  rng_df <- tibble(
    x, rng_text, rng_pre
  ) %>%
    filter(!is.na(rng_text)) %>%
    mutate(rng_nums = str_extract_all(rng_text, "\\d")) %>%
    mutate(rng_nums = map(rng_nums, ~c(.x[[1]]:.x[[2]]))) %>%
    mutate(rng_list = map2(rng_pre, rng_nums, ~paste0(.x, .y)))

  res <- tibble("input" = x) %>%
    left_join(rng_df, by = c("input" = "x")) %>%
    mutate(rng_list = map(rng_list, ~.x %||% NA_character_)) %>%
    select(input, rng_list) %>%
    pull(rng_list)

  res
}
