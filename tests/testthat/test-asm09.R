

asm09 <- mutate(asm09,
       type  = naics_code_type(naics_2007),
       level = naics_code_level(naics_2007))

tots <- asm09 %>%
  group_by(level) %>%
  summarize(vos_na = sum(vos09),
            vos_rm = sum(vos09, na.rm = TRUE))

tot_3digit <- tots$vos_na[tots$level == "3-digit"]
tot_4digit <- tots$vos_na[tots$level == "4-digit"]
tot_5digit <- tots$vos_na[tots$level == "5-digit"]
tot_6digit <- tots$vos_rm[tots$level == "6-digit"]

test_that("All ASM09 NAICS codes categorized", {

  expect_false(any(is.na(asm09$level)))
  expect_false(any(is.na(asm09$type)))
})

test_that("ASM 09 totals by level are similar", {

  expect_lt(abs(tot_3digit - tot_4digit), 5) # <$5 diff
  expect_lt(abs(tot_3digit - tot_5digit), 5) # <$5 diff
  expect_lt(abs(tot_3digit - tot_6digit) / tot_3digit, .01) # <1% diff, because of non-disclosed data

})


