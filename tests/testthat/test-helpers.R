# Tests for helper functions

test_that("cdc_count validates dataset_id", {
  expect_error(cdc_count(NULL))
  expect_error(cdc_count(123))
  expect_error(cdc_count(""))
})

test_that("cdc_count returns integer", {
  skip_if_offline()
  skip_on_cran()

  result <- cdc_count("swc5-untb")

  expect_type(result, "integer")
  expect_length(result, 1)
  expect_gt(result, 0)
})

test_that("cdc_count respects where parameter", {
  skip_if_offline()
  skip_on_cran()

  count_all <- cdc_count("swc5-untb")
  count_mn <- cdc_count("swc5-untb", where = "stateabbr = 'MN'")

  expect_lt(count_mn, count_all)
  expect_gt(count_mn, 0)
})

test_that("cdc_columns validates dataset_id", {
  expect_error(cdc_columns(NULL))
  expect_error(cdc_columns(123))
  expect_error(cdc_columns(""))
})

test_that("cdc_columns returns character vector", {
  skip_if_offline()
  skip_on_cran()

  result <- cdc_columns("swc5-untb")

  expect_type(result, "character")
  expect_gt(length(result), 0)
})

test_that("cdc_distinct validates inputs", {
  expect_error(cdc_distinct(NULL, "col"))
  expect_error(cdc_distinct("swc5-untb", NULL))
  expect_error(cdc_distinct("", "col"))
})

test_that("cdc_distinct returns expected structure", {
  skip_if_offline()
  skip_on_cran()

  result <- cdc_distinct("swc5-untb", "stateabbr", limit = 10)

  expect_s3_class(result, "tbl_df")
  expect_true("stateabbr" %in% names(result))
  expect_true("n" %in% names(result))
})

test_that("cdc_distinct respects limit", {
  skip_if_offline()
  skip_on_cran()

  result <- cdc_distinct("swc5-untb", "stateabbr", limit = 5)

  expect_lte(nrow(result), 5)
})

test_that("cdc_preview validates dataset_id", {
  expect_error(cdc_preview(NULL))
  expect_error(cdc_preview(123))
  expect_error(cdc_preview(""))
})

test_that("cdc_preview returns expected rows", {
  skip_if_offline()
  skip_on_cran()

  result <- cdc_preview("swc5-untb", n = 5)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 5)
})

test_that("cdc_preview respects n parameter", {
  skip_if_offline()
  skip_on_cran()

  result3 <- cdc_preview("swc5-untb", n = 3)
  result7 <- cdc_preview("swc5-untb", n = 7)

  expect_equal(nrow(result3), 3)
  expect_equal(nrow(result7), 7)
})
