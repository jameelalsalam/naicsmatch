# read asm example data

library(tidyverse)

ex_asm <- read_csv(
  "data-raw/ASM_2009_31GS101_with_ann.csv") %>%
  select(4,5,31)
  #select(4,5, 6, 7, 24, 26, 27, 29, 30, 31)

ex_asm <- ex_asm[-1, ] # first row (after names) are descriptions

ex_asm <- ex_asm %>%
  filter(NAICS.id %in% c(
    "333512", "333513",  # machine tools join
    "311822", "311823", # flour and pasta mftring join
    "311830", #tortillas
    "334113", # computer terminals
    "334119"  # computers split into computers and cameras
  )) %>%
  mutate(vos = as.numeric(RCPTOT)) %>%
  select(-RCPTOT)

usethis::use_data(ex_asm, overwrite = TRUE)
