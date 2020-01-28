# read_io_conc.R

library("tidyverse")
library("readxl")

# READ 2002 BEA IO Concordance ----
# (manually cleaned)

io_conc_raw_2002 <- readxl::read_excel("data-raw/bea_io_codes/Appendix A_rev 4-24-08.xlsx", sheet = "manually-cleaned") %>%
  select(io_code = IO_code, naics_2002_ranges)

io_conc_to_naics_2002_future <- io_conc_raw_2002 %>%
  mutate(naics_2002_set = ranges_to_set_6digit(
    naics_2002_ranges,
    listing = naicsmatch::naics_2002_listing
  ))

io_conc_to_naics_2002 <- io_conc_raw_2002 %>%

  # make lists from comma-separated things
  mutate(naics_1 = str_split(naics_code, pattern = ",")) %>%
  unnest() %>%
  mutate(naics_1 = str_trim(naics_1)) %>%

  # drop things with *'s
  # filter(!str_detect("\\*")) %>%

  # make ranges from dashed ranges
  mutate(naics_range = make_ranges(naics_1)) %>%
  unnest() %>%
  mutate(naics_2 = if_else(is.na(naics_range), naics_1, naics_range)) %>%

  # make all possible from 4- or 5-digit naics codes
  mutate(naics_3 = map(naics_2, function(naics){
    if (str_detect(naics, "^\\d{4}$")) {
      paste0(naics, str_sub(as.character(100:199), 2, 3))
    } else if (str_detect(naics, "^\\d{5}$")) {
      paste0(naics, str_sub(as.character(10:19), 2, 2))
    } else naics
  })) %>%
  unnest() %>%
  select(io_code, naics_orig = naics_code, naics_clean = naics_3)







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
