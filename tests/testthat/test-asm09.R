

asm09 <- mutate(asm09,
       type  = naics_code_type(naics_2007),
       level = naics_code_level(naics_2007))

test_that("ASM 09 data coverage", {

  expect_false(any(is.na(asm09$level)))
  expect_false(any(is.na(asm09$type)))

})
