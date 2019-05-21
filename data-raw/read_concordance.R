# read in concordance from census

library(tidyverse)
library(readxl)

naics_2007 <- read_excel(
  "data-raw/census/2007_to_2012_NAICS.xls",
  skip = 3,
  col_names = c("naics_2007", "naics_2007_desc",
                "naics_2012", "naics_2012_desc"),
  col_types = c(rep("text", 4), rep("skip", 5))) %>%
  select(naics_2007, naics_2007_desc)

naics_2007_2012 <- read_excel(
  "data-raw/census/2007_to_2012_NAICS.xls",
  skip = 3,
  col_names = c("naics_2007", "naics_2007_desc",
                "naics_2012", "naics_2012_desc"),
  col_types = c(rep("text", 4), rep("skip", 5))) %>%
  select(naics_2007, naics_2012)
# file has 5 extra blank columns

usethis::use_data(naics_2007_2012, overwrite = TRUE)

naics_2012_2007 <- read_excel(
  "data-raw/census/2012_to_2007_NAICS.xls",
  skip = 3,
  col_names = c("naics_2012", "naics_2012_desc",
                "naics_2007", "naics_2007_desc"),
  col_types = c(rep("text", 4))) %>%
# file has 5 extra blank columns
  select(naics_2012, naics_2007)

usethis::use_data(naics_2012_2007, overwrite = TRUE)
