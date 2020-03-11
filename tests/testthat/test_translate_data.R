# test_translate_data.R


## conc

conc_none <- tribble(
  ~naics, ~new_naics,
  "111111", "111111",
  "111112", "111112",
  "111113", "111113"
)

conc_split_partial <- tribble(
  ~naics, ~new_naics,
  "111111", "111112",
  "111111", "111113"
)

conc_combine_partial <- tribble(
  ~naics, ~new_naics,
  "111111", "111113",
  "111112", "111113"
)

conc_combine_all <- tribble(
  ~naics, ~new_naics,
  "111111", "111113",
  "111112", "111113",
  "111113", "111113"
)

conc_split_combine <- tribble(
  ~naics, ~new_naics,
  "111111", "111111",
  "111112", "111112",
  "111112", "111113",
  "111113", "111113"
)

## data

data_complete <- tribble(
  ~naics, ~value,
  "111111", 1,
  "111112", 2,
  "111113", 3
)

data_extra <- tribble(
  ~naics, ~value,
  "111111", 1,
  "111112", 2,
  "111115", 5
)


data_partial_explicit <- tribble(
  ~naics, ~value,
  "111111", 1,
  "111112", 2,
  "111113", NA
)

data_partial_implicit <- tribble(
  ~naics, ~value,
  "111111", 1,
  "111112", 2
)

data_multi_complete <- tribble(
  ~naics, ~value,
  "11111",  6,
  "111111", 1,
  "111112", 2,
  "111113", 3
)

data_multi_partial_explicit <- tribble(
  ~naics, ~value,
  "11111",  6,
  "111111", 1,
  "111112", 2,
  "111113", NA
)

data_multi_partial_implicit <- tribble(
  ~naics, ~value,
  "11111",  6,
  "111111", 1,
  "111112", 2,
  "111113", NA
)

## tests

# complete data

test_that("total preserving for complete examples", {

  naics_translate_data(
    data_complete,
    conc = conc_combine_all,
    .vars = "value",

    combine_method = "sum"
  ) %>% {
    expect_equal(.$value, 6)}

})

test_that("NA being combined with other values via conc results in NA total", {

  # partial, but explicit -- NA total b/c NA is one of the components summed
  naics_translate_data(
    data_partial_explicit,
    conc = conc_combine_all,
    .vars = "value",

    combine_method = "sum"
  ) %>% {
    expect_equal(.$value, c(NA_real_))}

  # implicit missing also results in NA, b/c target components based on crosswalk
  naics_translate_data(
    data_partial_implicit,
    conc = conc_combine_all,
    .vars = "value",

    combine_method = "sum"
  ) %>% {
    expect_equal(.$value, c(NA_real_))}

  # if conc is partial, the unmentioned codes are silently dropped
  naics_translate_data(
    data_extra,
    conc = conc_combine_partial,
    .vars = "value",

    combine_method = "sum"
  ) %>% {
    expect_equal(.$value, 3) }

  # implicit v. explicit is the same........
  naics_translate_data(
    data_partial_implicit,
    conc = conc_combine_partial,
    .vars = "value",

    combine_method = "sum"
  ) %>% {
    expect_equal(.$value, 3) }

})






