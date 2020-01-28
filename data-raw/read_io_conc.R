# read_io_conc.R

library("tidyverse")
library("readxl")
library("naicsmatch")

# READ 2002 BEA IO Concordance ----
# (manually cleaned)

io_conc_raw_2002 <- readxl::read_excel("data-raw/bea_io_codes/Appendix A_rev 4-24-08.xlsx", sheet = "manually-cleaned") %>%
  select(io_code = IO_code, naics_2002_ranges)

io_conc_to_naics_2002 <- io_conc_raw_2002 %>%
  mutate(naics_2002_set = naicsmatch::ranges_to_set_6digit(
    naics_2002_ranges,
    listing = naicsmatch::naics_2002_listing
  ))





# READ 2007/2012 BEA IO Concordance ---------

io_conc_raw_2012 <- read_xlsx(
  path = "data-raw/bea_io_codes/Use_SUT_Framework_2007_2012_DET.xlsx",
  sheet = "NAICS Codes",
  col_names = c("io_sector", "io_summary", "io_usummary", "io_detail", "industry_title", "notes", "naics_2012_codes"),
  skip = 5) %>%

  filter(! (
    is.na(io_sector) &
      is.na(io_summary) &
      is.na(io_usummary) &
      is.na(io_detail)))

# titles are mixed into the columns. need to strip them out and associate them with the codes

code_regex <- "^[:alnum:]{1,6}$"

keep_codes_only <- function(x) {
  if_else(str_detect(x, code_regex), x, NA_character_)
}

code_title <- io_conc_raw_2012 %>%
  mutate(
    level = case_when(
      str_detect(io_sector, code_regex) ~ "io_sector",
      str_detect(io_summary, code_regex) ~ "io_summary",
      str_detect(io_usummary, code_regex) ~ "io_usummary",
      str_detect(io_detail, code_regex) ~ "io_detail",
      TRUE ~ NA_character_),

    code = case_when(
      level == "io_sector" ~ io_sector,
      level == "io_summary" ~ io_summary,
      level == "io_usummary" ~ io_usummary,
      level == "io_detail" ~ io_detail,
      is.na(level) ~ NA_character_
    ),

    title = case_when(
      level == "io_sector" ~ io_summary,
      level == "io_summary" ~ io_usummary,
      level == "io_usummary" ~ io_detail,
      level == "io_detail" ~ industry_title,
      is.na(level) ~ NA_character_
    )
  ) %>%
  filter(!is.na(code)) %>%
  mutate(
    io_sector = if_else(
      level == "io_sector", io_sector, NA_character_),
    io_summary = if_else(
      level == "io_summary", io_summary, NA_character_),
    io_usummary = if_else(
      level == "io_usummary", io_usummary, NA_character_),
    io_detail = if_else(
      level == "io_detail", io_detail, NA_character_)
    ) %>%
  select(code, title, level,
         io_sector, io_summary, io_usummary, io_detail,
         naics_2012_codes) %>%
  fill(io_sector, .direction = "down") %>%
  group_by(io_sector) %>%
  fill(io_summary, .direction = "down") %>%
  group_by(io_summary) %>%
  fill(io_usummary, .direction = "down") %>%
  ungroup()
