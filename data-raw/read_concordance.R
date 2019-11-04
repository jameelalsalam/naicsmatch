# read in concordance from census

library(tidyverse)
library(readxl)

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

naics_2012_2017 <- read_excel(
  "data-raw/census/2012_to_2017_NAICS.xlsx",
  skip = 3,
  col_names = c("naics_2012", "naics_2012_desc",
                "naics_2017", "naics_2017_desc")
  ,
  col_types = c(rep("text", 4), rep("skip", 5))) %>%
  select(naics_2012, naics_2017)
# file has 5 extra blank columns

usethis::use_data(naics_2012_2017, overwrite = TRUE)

naics_2017_2012 <- read_excel(
  "data-raw/census/2017_to_2012_NAICS.xlsx",
  skip = 3,
  col_names = c("naics_2017", "naics_2017_desc",
                "naics_2012", "naics_2012_desc")
  ,
  col_types = c(rep("text", 4), rep("skip", 7))) %>%
  select(naics_2017, naics_2012)
# file has 7 extra blank columns

usethis::use_data(naics_2017_2012, overwrite = TRUE)

naics_2002_2007 <- read_excel(
  "data-raw/census/2002_to_2007_NAICS.xls",
  skip = 3,
  col_names = c("naics_2002", "naics_2002_desc",
                "naics_2007", "naics_2007_desc")
  ,
  col_types = c(rep("text", 4))) %>%
  select(naics_2002, naics_2007)

usethis::use_data(naics_2002_2007, overwrite = TRUE)

