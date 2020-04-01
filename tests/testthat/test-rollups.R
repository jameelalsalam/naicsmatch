# test_that("multiplication works", {
#   expect_equal(2 * 2, 4)
# })

library(tidyverse)

starch_oils_milling <- filter(asm09, str_detect(naics_2007, "^31122")) %>%
  mutate(
    level = naics_code_level(naics_2007),
    type = naics_code_type(naics_2007),
    naics_set = rollup_to_set_6digit(
      naics_2007,
      listing = naicsmatch::naics_2007_listing)) %>%
  select(-year, -vos09) %>%
  arrange(naics_2007)

asm09_sets <- mutate(asm09) %>%
  mutate(
    level = naics_code_level(naics_2007),
    type = naics_code_type(naics_2007),
    naics_set = rollup_to_set_6digit(
      naics_2007,
      listing = naicsmatch::naics_2007_listing)) %>%
  select(-year, -vos09) %>%
  arrange(naics_2007)

# asm09_sets %>%
#   mutate(naics_set = purrr::map_chr(naics_set,
#                              ~glue::glue_collapse(.x, sep = ", "))) %>% readr::write_csv("outputs/asm09_sets.csv")

test_that("rollup set calculation works as expected", {

  expect_equal(
    starch_oils_milling$naics_set[[4]], c("311222", "311223"))

})

test_that("rollup handles 'M' situation", {

  # synthetic 'M' value
  expect_equal(
    rollup_to_set_6digit(
      c("11111M"), listing = c("111111", "111112", "111113")),
    list(c("111111", "111112", "111113"))
  )
})

test_that("rollup handles 'N' situation", {

  # synthetic 'N' value
  expect_equal(
    rollup_to_set_6digit(
      c("111111", "11111N"), listing = c("111111", "111112", "111113")),
    list(c("111111"), c("111112", "111113"))
  )
})

# test_that("rollup handles 'N' & 'P' situation in ASM09 (currently fails)", {
#
#   # synthetic 'N' + 'P'
#   expect_equal(
#     rollup_to_set_6digit(
#       c("111111", "11111N", "11111P"),
#       listing = c("111111", "111112", "111113", "111114", "111115")),
#     list(c("111111"), c("111112", "111113"), c("111114", "111115"))
#   )
#
# })

# hosiery and socks

hs <- naics_2007_listing %>% filter(str_detect(naics, "^31511[19]"))
# ITC uses rollups e.g. "31511X" to indicate equivalent 6-digit code to 31511

test_that("rollup handles 'X' values from ITC.", {
  expect_equal(
    rollup_to_set_6digit("31511X", listing = naics_2007_listing), list(c("315111", "315119"))
  )
})
