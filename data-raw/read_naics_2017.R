# read_naics_2017.R

library(tidyverse)
library(readxl)

naics_2017_listing <- read_excel(
  "data-raw/census/2-6 digit_2017_Codes.xlsx",
  col_names = c("naics", "title"),
  col_types = c("skip", "text", "text", rep("skip", 3)),
  skip = 2
)

usethis::use_data(naics_2017_listing, overwrite = TRUE)

naics_2012_listing <- read_excel(
  "data-raw/census/2-digit_2012_Codes.xls",
  col_names = c("naics", "title"),
  col_types = c("skip", "text", "text"),
  skip = 2
)

usethis::use_data(naics_2012_listing, overwrite = TRUE)

naics_2007_listing <- read_excel(
  "data-raw/census/naics07.xls",
  col_names = c("naics", "title"),
  col_types = c("skip", "text", "text"),
  skip = 2
)

usethis::use_data(naics_2007_listing, overwrite = TRUE)

naics_2002_listing <- read_fwf(
  file = "data-raw/census/naics_2_6_02.txt",
  col_positions = fwf_widths(c(6, NA), c("naics", "title")),
  col_types = cols(
    naics = col_character(),
    title = col_character()),
  skip = 7
)

if(!naics_2002_listing$naics[[1]] == "11") stop("check skip parameter for naics_2002_listing")

usethis::use_data(naics_2002_listing, overwrite = TRUE)
