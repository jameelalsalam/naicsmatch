# read asm example data

library(tidyverse)

# example NAICS for changes 2007 -> 2012
example_naics <- c(
  "333512", "333513",  # machine tools 2007 join
  "333517",            # to be one in 2012

  "311822", "311823", # flour and pasta mftring join, but don't appear in ASM

  "311830", #tortillas same in both

  "334113", # computer terminals in 2007 changes
  "334118", # new 2012 naics

  "333315", # 2007 photocopiers also join with some of other computers

  "334119",  # 2007 computers split into computers and cameras
  "333316", "334118" # into these in 2012
)

# from ASM 2009

ex_asm09 <- read_csv(
  "data-raw/ASM_2009_31GS101_with_ann.csv") %>%
  select(4,5,31)
  #select(4,5, 6, 7, 24, 26, 27, 29, 30, 31)

ex_asm09 <- ex_asm09[-1, ] # first row (after names) are descriptions

ex_asm09 <- ex_asm09 %>%
  filter(NAICS.id %in% example_naics) %>%
  mutate(vos09 = as.numeric(RCPTOT)) %>%
  rename(naics_2007 = NAICS.id,
         naics_label_2007 = `NAICS.display-label`) %>%
  select(-RCPTOT)

usethis::use_data(ex_asm09, overwrite = TRUE)

# from ASM 2016

ex_asm15 <- read_csv(
  "data-raw/ASM_2015_31GS101_with_ann.csv") %>%
  select(4,5,45)
# NAICS ID, NAICS title, and total value of shipments ($1000s)

ex_asm15 <- ex_asm15[-1, ] # first row (after names) are descriptions

ex_asm15 <- ex_asm15 %>%
  filter(NAICS.id %in% example_naics) %>%
  mutate(vos15 = as.numeric(RCPTOT)) %>%
  rename(naics_2012 = NAICS.id,
         naics_label_2012 = `NAICS.display-label`) %>%
  select(-RCPTOT)

usethis::use_data(ex_asm15, overwrite = TRUE)

