#' Make a Sankey Diagram of a NAICS Crosswalk
#'
#' @export
naics_sankey <- function(crosswalk,
                         from = "naics_2007",
                         to = "naics_2012",
                         value = "vos09") {

  asm_sankey_data <- crosswalk %>%

    select(naics_2007, naics_2012, vos09) %>%
    ggforce::gather_set_data(x = c("naics_2007", "naics_2012")) %>%
    mutate(x = factor(x),
           y = factor(y)) %>%
    mutate(label = case_when(
      as.character(x) == "naics_2007" ~ naics_2007,
      as.character(x) == "naics_2012" ~ naics_2012,
      TRUE ~ NA_character_
    ))

  ggplot(asm_sankey_data,
         mapping = aes(x = x,
                       id = id,
                       split = y,
                       value = vos09)) +
    ggforce::geom_parallel_sets(aes(fill = naics_2007),
                       alpha = 0.5, axis.width = 0.13) +
    ggforce::geom_parallel_sets_axes(axis.width = 0.1, fill = "grey80", color = "grey80") +
    ggforce::geom_parallel_sets_labels(
      aes(split = label),
      color = 'black',
      size = 10/.pt,
      angle = 0
    )

}
