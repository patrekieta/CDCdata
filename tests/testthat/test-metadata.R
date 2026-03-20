# Tests for metadata and discovery functions

test_that("cdc_metadata validates dataset_id", {
  expect_error(cdc_metadata(NULL))
  expect_error(cdc_metadata(123))
  expect_error(cdc_metadata(""))
})

test_that("cdc_metadata returns expected structure", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  meta <- cdc_metadata("swc5-untb")

  expect_type(meta, "list")
  expect_true("id" %in% names(meta))
  expect_true("name" %in% names(meta))
  expect_true("description" %in% names(meta))
  expect_true("tags" %in% names(meta))
  expect_true("columns" %in% names(meta))
  expect_true("rows" %in% names(meta))
})

test_that("cdc_metadata returns columns as data frame", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  meta <- cdc_metadata("swc5-untb", include_columns = TRUE)

  expect_s3_class(meta$columns, "data.frame")
  expect_true("field_name" %in% names(meta$columns))
  expect_true("data_type" %in% names(meta$columns))
})

test_that("cdc_metadata respects include_columns = FALSE", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  meta <- cdc_metadata("swc5-untb", include_columns = FALSE)

  expect_null(meta$columns)
})

test_that("cdc_metadata fetches row count", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  meta <- cdc_metadata("swc5-untb", fetch_row_count = TRUE)

  expect_true(!is.null(meta$rows) && !is.na(meta$rows))
  expect_gt(meta$rows, 0)
})

test_that("cdc_datasets returns expected structure", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_datasets("PLACES", limit = 5)

  expect_s3_class(result, "data.frame")
  expect_true(all(c("id", "name", "description", "category", "tags") %in% names(result)))
  expect_lte(nrow(result), 5)
})

test_that("cdc_datasets respects limit parameter", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_datasets(limit = 3)

  expect_lte(nrow(result), 3)
})

test_that("cdc_datasets warns on limit > 100", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  expect_warning(cdc_datasets(limit = 150), "100")
})

test_that("cdc_datasets_by_category validates category", {
  expect_error(cdc_datasets_by_category(NULL))
  expect_error(cdc_datasets_by_category(123))
  expect_error(cdc_datasets_by_category(""))
})

test_that("cdc_datasets_by_category returns expected structure", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_datasets_by_category("COVID-19", limit = 5)

  expect_s3_class(result, "data.frame")
  expect_true(all(c("id", "name", "category", "tags") %in% names(result)))
})

test_that("cdc_datasets_by_tag validates tag", {
  expect_error(cdc_datasets_by_tag(NULL))
  expect_error(cdc_datasets_by_tag(123))
  expect_error(cdc_datasets_by_tag(""))
})

test_that("cdc_datasets_by_tag returns expected structure", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_datasets_by_tag("covid-19", limit = 5)

  expect_s3_class(result, "data.frame")
  expect_true(all(c("id", "name", "category", "tags") %in% names(result)))
})

test_that("cdc_categories returns expected structure", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_categories()

  expect_s3_class(result, "data.frame")
  expect_true(all(c("category", "count") %in% names(result)))
})

test_that("cdc_tags returns expected structure", {
  skip_if_cdc_unavailable()
  skip_on_cran()

  result <- cdc_tags(limit = 20)

  expect_s3_class(result, "data.frame")
  expect_true(all(c("tag", "count") %in% names(result)))
})

test_that("cdc_browse validates dataset_id", {
  expect_error(cdc_browse(NULL))
  expect_error(cdc_browse(123))
  expect_error(cdc_browse(""))
})
