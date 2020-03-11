
#' Translate a data set, re-summarizing to a new NAICS basis
#' 
#' @param data data frame to concord & re-summarize
#' @param conc the concordance to use. First column should be where its coming from and second should be where its going to.
#' @param .vars vector of strings representing variables to bring along
#' @param by vector of strings representing identity variables need to group_by when doing re-summarization
#' @param join_method approach for combining values. Right now "sum" or "mean" are  the valid options.
#' @param split_method approach for splitting values. Right now "na", "1/n", and "each" are the valid options.
#' 
#' @export
#' @examples 
#' data <- ex_asm09
#' conc <- naicsmatch::naics_2007_2012
#' .vars <- "vos09"
#' #from must be first col of conc
#' #to must be second col of conc
#' asm09_12 <- naics_translate_data(data, conc, .vars = "vos09")
naics_translate_data <- function(
  data, 
  conc,
  .vars,
  by = NULL,
  combine_method = "sum",
  split_method = "na") {
  
  split_method <- str_to_lower(split_method)
  split_method_choices <- c("na", "1/n", "each")
  
  if(length(split_method) > 1 | 
     ! split_method %in% split_method_choices) stop('Possible choices for split_method are ', split_method_choices, '.')
  
  combine_method <- str_to_lower(combine_method)
  combine_method_choices <- c("sum", "mean")
  
  if(length(combine_method) > 1) stop('Possible choices for combine_method are ', combine_method_choices, '.')
  
  if(!is.character(by) & !is.null(by)) stop("Parameter `by` must be a character vector representing columns of the data to group by when re-summarizing.")
  # may relax later to allow NSE or defaults?
  
  # first column of conc must be the from variable and match to data
  from <- names(conc)[[1]]
  to   <- names(conc)[[2]]
  
  conc_choice <- if(split_method == "na") {
    
    conc_wgt_na <- conc %>%
      group_by_at(.vars = from) %>%
      mutate(wgt = if_else(n() == 1, 1, NA_real_)) %>%
      ungroup()
    
  } else if(split_method == "1/n") {
    
    conc_wgt_n <- conc %>%
      group_by_at(.vars = from) %>%
      mutate(wgt = 1 / n()) %>%
      ungroup()
    
  } else if(split_method == "each") {
    
    conc_wgt_each <- conc %>%
      mutate(wgt = 1)
    
  } else stop("Invalid split method '", split_method, "' selected.")
  
  conc_choice_subset <- conc_choice %>% {
    destinations <- semi_join(., data, by = from) %>%
      select(to)
    
    semi_join(., destinations, by = to)
  }
  
  # wgt applied after splitting, before combining
  data_conc <- data %>%
    right_join(conc_choice_subset, by = from) %>%
    mutate_at(
      .vars = .vars,
      .funs = ~.x * wgt) %>%
    select(-wgt)
  
  grp_vars <- c(to, by) # if by == NULL, it disappears in c()
  
  if(combine_method == "sum") {
    res <- data_conc %>%
      group_by_at(.vars = grp_vars) %>%
      summarize_at(
        .vars = .vars,
        .funs = ~sum(.x)) %>%
      ungroup()
    
  } else if(combine_method == "mean") {
    res <- data_conc %>%
      group_by_at(.vars = grp_vars) %>%
      summarize_at(
        .vars = .vars,
        .funs = ~mean(.x)) %>%
      ungroup()
  }

  res
}

#' Translate NAICS data starting from either 5- or 6-digit level, going to 6-digit level.
#' 
#' Ensures data is complete on vars
#' 
naics_translate_data_special <- function(
  data, 
  conc,
  .vars,
  by = NULL,
  combine_method = "sum",
  split_method = "na") {
  
  stopifnot(is.null(by) | is.character(by))
  
  from <- names(conc)[[1]]
  to   <- names(conc)[[2]]
  
  conc6 <- filter(conc, naics_code_level(conc[[1]]) == "6-digit")
  conc56 <- naics_conc_special(conc6, from_levels = 5, to_levels = 6)
  
  data6 <- data %>% {
    filter(., naics_code_level(.[[from]]) == "6-digit")
  } %>%
    naics_translate_data(conc6, .vars = .vars, by = by,
                         combine_method = combine_method,
                         split_method = split_method) %>%
    filter_complete(!!!.vars)
  
  data5 <- data %>% {
    filter(., naics_code_level(.[[from]]) == "5-digit")
  } %>%
    naics_translate_data(conc56, .vars = .vars, by = by,
                         combine_method = combine_method,
                         split_method = "na") %>% # don't split the 5-digit data even if "1/n" is selected.
    filter_complete(!!!.vars)
  
  if(is.null(by)) {
    res <- coalesce_rows(data6, data5, by = rlang::as_string(to))
  } else {
    by_vars <- c(to, by)
    res <- coalesce_rows(data6, data5, by = by_vars)
  }
  
  res
}
