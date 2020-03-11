# test_translate_special.R


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

data_multi_complete <- tribble(
  ~naics, ~value, ~year,
  "11111",  6, 2020,
  "111111", 1, 2020,
  "111112", 2, 2020,
  "111113", 3, 2020
)

data_multi_partial_explicit <- tribble(
  ~naics, ~value, ~year,
  "11111",  6, 2020,
  "111111", 1, 2020,
  "111112", 2, 2020,
  "111113", NA, 2020
)

data_multi_partial_implicit <- tribble(
  ~naics, ~value, ~year,
  "11111",  6, 2020,
  "111111", 1, 2020,
  "111112", 2, 2020,
  "111113", NA, 2020
)

# split-combine with 'special' and split_method = "na"
# results in losing targets of split (e.g., 2 was split into 2 and 3)
# TODO: maybe targets of split should say NA
naics_translate_data_special(
  data = data_multi_complete,
  conc = conc_split_combine,
  .vars = "value",
  by = "year",
  split_method = "na",
  combine_method = "sum"
)  %>% {
  expect_equal(sum(.$value, na.rm = TRUE), 1) }


# using 1/n preserves total, does not make use of 5-digit data
naics_translate_data_special(
  data = data_multi_complete,
  conc = conc_split_combine,
  .vars = "value",
  by = "year",
  split_method = "1/n",
  combine_method = "sum"
) %>% {
  expect_equal(sum(.$value), 6) }



### when combining, with partial data at the 6-digit level, should use complete data at 5-digit level.

naics_translate_data_special(
  data = data_multi_partial_explicit,
  conc = conc_combine_all,
  .vars = "value",
  by = "year",
  split_method = "na",
  combine_method = "sum"
) %>% {
  expect_equal(.$value, 6) }

# also implicit missing
naics_translate_data_special(
  data = data_multi_partial_implicit,
  conc = conc_combine_all,
  .vars = "value",
  by = "year",
  split_method = "na",
  combine_method = "sum"
) %>% {
  expect_equal(.$value, 6) }

# regardless of split_method
naics_translate_data_special(
  data = data_multi_partial_explicit,
  conc = conc_combine_all,
  .vars = "value",
  by = "year",
  split_method = "1/n",
  combine_method = "sum"
) %>% {
  expect_equal(.$value, 6) }



# special method with incomplete data
# BUG? 1/n means that partial data still doesn't use higher level data.
naics_translate_data_special(
  data = data_multi_partial_explicit,
  conc = conc_combine_all,
  .vars = "value",
  by = "year",
  split_method = "1/n",
  combine_method = "sum"
)

# naics_translate_data_special should NOT REQUIRE by = year variable

naics_translate_data_special(
  data = select(data_multi_partial_explicit, -year),
  conc = conc_combine_all,
  .vars = "value",
  split_method = "1/n",
  combine_method = "sum") %>% {
    expect_equal(.$value, 6)}
