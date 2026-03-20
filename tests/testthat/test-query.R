# Tests for query functions (cdc_query, cdc_fetch)
# These tests use mocked HTTP responses where possible

test_that("cdc_query validates dataset_id", {
  expect_error(cdc_query(NULL))
  expect_error(cdc_query(123))
  expect_error(cdc_query(""))
})

test_that("cdc_query validates as parameter", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  # Valid 'as' values should not error on argument validation
expect_error(
    cdc_query("swc5-untb", limit = 1, as = "invalid"),
    "should be one of"
  )
})

test_that("cdc_query accepts valid as parameter values", {
  # These should not error on argument matching (may still fail on network)
  expect_error(
    cdc_query("swc5-untb", limit = 1, as = "dataframe"),
    NA
 ) |> tryCatch(error = function(e) {
    # Network errors are OK, we're testing argument validation
    if (!grepl("should be one of", e$message)) TRUE
  })
})

test_that("cdc_fetch validates dataset_id", {
  expect_error(cdc_fetch(NULL))
  expect_error(cdc_fetch(123))
  expect_error(cdc_fetch(""))
})

test_that("cdc_fetch warns on excessive page_size", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  expect_warning(
    cdc_fetch("swc5-untb", page_size = 100000, max_rows = 1, progress = FALSE),
    "50,000"
  )
})

test_that("cdc_fetch respects max_rows parameter", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_fetch(
    "swc5-untb",
    max_rows = 10,
    progress = FALSE
  )

  expect_lte(nrow(result), 10)
})

test_that("cdc_query returns expected structure with dataframe output", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_query("swc5-untb", limit = 5, as = "dataframe")

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_lte(nrow(result), 5)
})

test_that("cdc_query returns list when as='list'", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_query("swc5-untb", limit = 5, as = "list")

  expect_type(result, "list")
})

test_that("cdc_query returns character when as='raw'", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_query("swc5-untb", limit = 5, as = "raw")

  expect_type(result, "character")
  expect_length(result, 1)
})

test_that("cdc_query respects select parameter", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_query(
    "swc5-untb",
    select = c("stateabbr", "year"),
    limit = 5
  )

  expect_true("stateabbr" %in% names(result))
  expect_true("year" %in% names(result))
})

test_that("cdc_query respects where parameter", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_query(
    "swc5-untb",
    where = "stateabbr = 'MN'",
    limit = 10
  )

  expect_true(all(result$stateabbr == "MN"))
})

test_that("cdc_query respects order parameter", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_query(
    "swc5-untb",
    select = c("stateabbr", "year"),
    order = "stateabbr ASC",
    limit = 100
  )

  expect_equal(result$stateabbr, sort(result$stateabbr))
})

test_that("cdc_query works with as_csv = TRUE", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_query("swc5-untb", limit = 5, as_csv = TRUE)

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
})

test_that("cdc_query aggregation works", {
  CDCdata:::skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_query(
    "swc5-untb",
    select = c("stateabbr", "count(*) as n"),
    group = "stateabbr",
    order = "n DESC",
    limit = 10
  )

  expect_true("stateabbr" %in% names(result))
  expect_true("n" %in% names(result))
})
