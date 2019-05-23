# read_naics_2017.R

library(tidyverse)
library(readxl)

naics_2017 <- read_excel(
  "data-raw/census/2017_NAICS_Descriptions.xlsx"
) %>%
  rename(naics = Code,
         title = Title,
         descr = Description) %>%
  mutate(trilateral = stringr::str_detect(title, "T$")) %>%
  mutate(title = str_remove(title, "T$"))

usethis::use_data(naics_2017)


naics_2007 <- read_excel(
  "data-raw/census/2007_to_2012_NAICS.xls",
  skip = 3,
  col_names = c("naics_2007", "naics_2007_desc",
                "naics_2012", "naics_2012_desc"),
  col_types = c(rep("text", 4), rep("skip", 5))) %>%
  select(naics_2007, naics_2007_desc)
