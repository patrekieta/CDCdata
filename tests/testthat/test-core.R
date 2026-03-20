# Tests for core validation and utility functions

test_that("validate_dataset_id accepts valid IDs", {
expect_silent(cdcdata:::validate_dataset_id("swc5-untb"))
  expect_silent(cdcdata:::validate_dataset_id("abc1-def2"))
  expect_silent(cdcdata:::validate_dataset_id("1234-5678"))
  expect_silent(cdcdata:::validate_dataset_id("aaaa-bbbb"))
})

test_that("validate_dataset_id warns on invalid format", {
  expect_warning(cdcdata:::validate_dataset_id("invalid"))
  expect_warning(cdcdata:::validate_dataset_id("too-long-id"))
  expect_warning(cdcdata:::validate_dataset_id("SWCS-UNTB"))
  expect_warning(cdcdata:::validate_dataset_id("abc-defg"))
  expect_warning(cdcdata:::validate_dataset_id("abcde-fgh"))
  expect_warning(cdcdata:::validate_dataset_id("ab12-cd"))
})
test_that("validate_dataset_id errors on wrong type", {
  expect_error(cdcdata:::validate_dataset_id(NULL))
  expect_error(cdcdata:::validate_dataset_id(123))
  expect_error(cdcdata:::validate_dataset_id(c("a", "b")))
  expect_error(cdcdata:::validate_dataset_id(""))
  expect_error(cdcdata:::validate_dataset_id(NA))
  expect_error(cdcdata:::validate_dataset_id(NA_character_))
})

test_that("build_soql_params creates correct parameters", {
  params <- cdcdata:::build_soql_params(
    select = c("col1", "col2"),
    where = "col1 = 'a'",
    limit = 100
  )

  expect_equal(params[["$select"]], "col1, col2")
  expect_equal(params[["$where"]], "col1 = 'a'")
  expect_equal(params[["$limit"]], 100L)
})

test_that("build_soql_params handles NULL values", {
  params <- cdcdata:::build_soql_params()
  expect_length(params, 0)

  params <- cdcdata:::build_soql_params(limit = 50)
  expect_length(params, 1)
  expect_equal(params[["$limit"]], 50L)
})

test_that("build_soql_params handles all parameters", {
  params <- cdcdata:::build_soql_params(
    select = c("a", "b", "c"),
    where = "x > 10",
    order = "a DESC",
    group = "category",
    having = "count(*) > 5",
    limit = 100,
    offset = 50,
    q = "search term"
  )

  expect_equal(params[["$select"]], "a, b, c")
  expect_equal(params[["$where"]], "x > 10")
  expect_equal(params[["$order"]], "a DESC")
  expect_equal(params[["$group"]], "category")
  expect_equal(params[["$having"]], "count(*) > 5")
  expect_equal(params[["$limit"]], 100L)
  expect_equal(params[["$offset"]], 50L)
  expect_equal(params[["$q"]], "search term")
})

test_that("build_soql_params converts limit and offset to integer", {
  params <- cdcdata:::build_soql_params(limit = 100.5, offset = 25.9)

  expect_type(params[["$limit"]], "integer")
  expect_type(params[["$offset"]], "integer")
  expect_equal(params[["$limit"]], 100L)
  expect_equal(params[["$offset"]], 25L)
})

test_that("cdc_app_token validates input", {
  expect_error(cdc_app_token(123, quiet = TRUE))
  expect_error(cdc_app_token("", quiet = TRUE))
  expect_error(cdc_app_token(c("a", "b"), quiet = TRUE))
  expect_error(cdc_app_token(NA, quiet = TRUE))
})

test_that("cdc_app_token sets and retrieves token", {
  old_token <- Sys.getenv("CDC_APP_TOKEN", unset = NA)
  on.exit({
    if (is.na(old_token)) {
      Sys.unsetenv("CDC_APP_TOKEN")
    } else {
      Sys.setenv(CDC_APP_TOKEN = old_token)
    }
  })

  Sys.unsetenv("CDC_APP_TOKEN")
  expect_null(cdc_app_token(quiet = TRUE))

  cdc_app_token("test-token-123", quiet = TRUE)
  expect_equal(cdc_app_token(quiet = TRUE), "test-token-123")
})

test_that("null coalescing operator works correctly", {
  `%||%` <- cdcdata:::`%||%`

  expect_equal(NULL %||% "default", "default")
  expect_equal("value" %||% "default", "value")
  expect_equal(NA %||% "default", NA)
  expect_equal(0 %||% "default", 0)
  expect_equal("" %||% "default", "")
})

test_that("empty_datasets_df returns correct structure", {
  df <- cdcdata:::empty_datasets_df()

  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 0)
  expect_named(df, c("id", "name", "description", "category", "tags",
                     "updated_at", "rows", "url"))

  expect_type(df$id, "character")
  expect_type(df$name, "character")
  expect_type(df$rows, "integer")
})
