# ranges.R
# e.g., "123456-8" -> "123456", "123457", "123458"
# makes list of chr


#' Translates ranges into lists of (start, end)
#'
#' Intended for e.g., "123456-8" -> "123456", "123458"
#' @examples
#' x <- c("111111", "123456-8", "111-20")
#' @import stringr
code_range_lims <- function(x, candidates) {

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
