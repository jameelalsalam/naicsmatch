# test_that("multiplication works", {
#   expect_equal(2 * 2, 4)
# })

library(tidyverse)

starch_oils_milling <- filter(asm09, str_detect(naics_2007, "^31122")) %>%
  mutate(
    level = naics_code_level(naics_2007),
    type = naics_code_type(naics_2007),
    naics_set = rollup_set_6digit(
      naics_2007,
      listing = naicsmatch::naics_2007_listing)) %>%
  select(-year, -vos09) %>%
  arrange(naics_2007)

test_that("rollup set calculation works as expected", {

  expect_equal(
    starch_oils_milling$naics_set[[4]], c("311222", "311223"))

})
