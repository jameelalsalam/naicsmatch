# naics-match.R

#' Create a NAICS concordance between different level NAICS codes
#' 
#' @param x, y naics code character vectors
#' 
#' Returns a data frame with 2 columns `idx` and `idy`. The first always matches the `x` input, while the second column matches up appropriate aggregated categories.
#' @export
#' @examples 
#' naics_match(
#' x = c("300000", "200001", "200002", "100000"),
#' y = c("100", "20", "200001"))
naics_match <- function(x, y) {
  stopifnot(is.character(x))
  stopifnot(is.character(y))
  
  dx <- tibble(idx = x, naics = x)
  dy <- tibble(idy = y, naics = y)
  
  matches <- list()
  dx_rem <- dx

  for (i in 6:1) {
    matches[[i]] <- left_join(dx_rem, dy)
    
    dx_rem <- filter(matches[[i]], is.na(idy)) %>%
      select(-idy) %>%
      mutate(naics = stringr::str_sub(naics, 1, i-1))
    
    if(i > 1) {matches[[i]] <- filter(matches[[i]], !is.na(idy))}

  }
  
  xwalk <- bind_rows(matches) %>% 
    select(-naics) %>% 
    distinct(idx, idy) %>%
    arrange(idx)
  
  res <- tibble(
    idx = x ) %>% left_join(xwalk, by = "idx") %>%
    pull(idy)
  
  res
}

#' Retrieve (or generate) a NAICS concordance
#' 
#' @param from length 1 chr or numeric representing starting naics version
#' @param to length 1 chr or numeric representing ending naics version
#' @export
naics_conc <- function(from, to) {
  
  stopifnot(length(from) == 1)
  stopifnot(is.character(from) | is.numeric(from))
  from_num <- str_remove(as.character(from), "^naics_")
  stopifnot(from_num %in% c(2002, 2007, 2012, 2017))
  from_str <- glue::glue("naics_{from_num}")
  
  stopifnot(length(to) == 1)
  stopifnot(is.character(to) | is.numeric(to))
  to_num <- str_remove(as.character(to), "^naics_")
  stopifnot(to_num %in% c(2002, 2007, 2012, 2017))
  to_str <- glue::glue("naics_{to_num}")
  
  stopifnot(from_num != to_num) # allow conc to same?
  min_num <- min(from_num, to_num)
  max_num <- max(from_num, to_num)
  
  conc <- if(min_num == "2002" & max_num == "2007") {
    naicsmatch::naics_2002_2007 
    
  } else if(min_num == "2002" & max_num == "2012") {
    distinct(left_join(naicsmatch::naics_2002_2007, naicsmatch::naics_2007_2012, by = "naics_2007"), naics_2002, naics_2012)
    
  } else if(min_num == "2002" & max_num == "2017") {
    distinct(left_join(left_join(naicsmatch::naics_2002_2007, naicsmatch::naics_2007_2012, by = "naics_2007"), naicsmatch::naics_2012_2017, by = "naics_2012"), naics_2002, naics_2017)
  } else if(min_num == "2007" & max_num == "2012") {
    naicsmatch::naics_2007_2012
  } else if(min_num == "2007" & max_num == "2017") {
    distinct(left_join(naicsmatch::naics_2007_2012, naicsmatch::naics_2012_2017, by = "naics_2012"), naics_2007, naics_2017)
  } else if(min_num == "2012" & max_num == "2017") {
    naicsmatch::naics_2012_2017 
  } else {
    stop("Invalid from/to")
  }
  
  res <- if(min_num == from_num) conc else {
    select(conc, 2, 1)
  }
  
  res
}

#' Construct special naics concordances
#' 
#' Right now just 5 -> 6
#' 
#' Either conc or from/to should be supplied
#' 
#' @param conc
#' @param from
#' @param to
#' @examples 
#' conc_mini <- filter(naics_2012_2017, 
#'                         naics_containing(naics_2012) == "33522" |
#'                           naics_containing(naics_2017) == "33522")
#' conc_5_to_6 <- naics_conc_special(conc_mini, from_levels = 5, to_levels = 6)
naics_conc_special <- function(conc = NULL, 
                               from = NULL, to = NULL, 
                               from_levels = 6, to_levels = 6) {
  
  if(is.null(conc) & !is.null(from) & !is.null(to)) {
    conc <- naics_conc(from, to)
  } else if(!is.null(conc) & is.null(from) & is.null(to)) {
    conc <- conc
  } else {
    stop("Either `conc` or `from` and `to` must be supplied.")
  }
  
  stopifnot(all(from_levels >= 1))
  stopifnot(all(from_levels <= 6))
  stopifnot(all(to_levels >= 1))
  stopifnot(all(to_levels <= 6))
  
  # TODO: check that from_levels, to_levels are in allowed bounds
  
  stopifnot(length(from_levels) == 1)
  stopifnot(length(to_levels) == 1)
  
  res_conc <- conc
  
  res_conc[[1]] <- naics_containing(res_conc[[1]], from_levels)
  res_conc[[2]] <- naics_containing(res_conc[[2]], to_levels)
  
  res_conc <- distinct(res_conc)
  
  res_conc
}

#' Translate a NAICS code into another form
#' 
#' One-to-one translations are easier than others...
#' Params `from` & `to` can be e.g., 2002, "2002", or "naics_2002"
#' Valid NAICS versions are 2002, 2007, 2012, and 2017
#' 
#' @param naics character vector of NAICS codes
#' @param from length 1 chr or numeric representing starting naics version
#' @param to length 1 chr or numeric representing ending naics version
#' @returns chr (or list?) same length as `naics`
#' 
#' @examples
#' naics <- ex_asm09$naics_2007
#' from <- "2007"; to <- "2012"
#' all.equal(
#' ex_asm09 %>% left_join(naics_2007_2012, by = "naics_2007"),
#' mutate(ex_asm09, naics_2012 = naics_translate(naics_2007, 2007, 2012))
#' )
#' @export
naics_translate <- function(naics, from, to) {
  
  conc <- naics_conc(from = from, to = to)
  
  res <- tibble::tibble(
    from = naics
  ) %>%
    left_join(conc, by = c("from" = from_str)) %>%
    group_by(!!from_str) %>%
    chop(cols = to_str) %>%
    pull(!!to_str)
  
}
