library(naicsmatch)

test_that("naics code types work as expected", {

  # roll-up code types detected as roll-ups
  expect_equal(naics_code_type(
    c("31-33", "12345M", "11111N", "11111P")),
    rep("rollup", 4))

  # TODO: not yet validating -- should I?

  expect_equal(naics_code_type(
    c("123456", "12345", "1234", "123", "12")),
    rep("std", 5))
})
