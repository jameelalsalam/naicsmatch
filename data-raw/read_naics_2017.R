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

usethis::use_data(naics_2017, overwrite = TRUE)


naics_2007 <- read_excel(
  "data-raw/census/naics07.xls",
  skip = 2,
  col_names = c("seq_no", "naics", "descr"),
  col_types = c(rep("text", 3))) %>%
  select(naics, descr)

usethis::use_data(naics_2007, overwrite = TRUE)
