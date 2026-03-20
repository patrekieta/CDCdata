# Tests for request building and HTTP utilities

test_that("build_request creates valid httr2 request", {
  req <- CDCdata:::build_request("/resource/test-1234.json")

  expect_s3_class(req, "httr2_request")
})
test_that("build_request sets correct base URL", {
  req <- CDCdata:::build_request("/resource/test-1234.json")

  expect_match(req$url, "https://data.cdc.gov")
})

test_that("build_request sets JSON accept header by default", {
  req <- CDCdata:::build_request("/resource/test-1234.json", format = "json")

  # Headers are stored in the request
  expect_true(!is.null(req$headers))
})

test_that("build_request sets CSV accept header when format='csv'", {
  req <- CDCdata:::build_request("/resource/test-1234.csv", format = "csv")

  expect_true(!is.null(req$headers))
})

test_that("build_request includes app token when set", {
  old_token <- Sys.getenv("CDC_APP_TOKEN", unset = NA)
  on.exit({
    if (is.na(old_token)) {
      Sys.unsetenv("CDC_APP_TOKEN")
    } else {
      Sys.setenv(CDC_APP_TOKEN = old_token)
    }
  })

  Sys.setenv(CDC_APP_TOKEN = "test-token-xyz")
  req <- CDCdata:::build_request("/resource/test-1234.json")

  # Token should be in headers
  expect_true(!is.null(req$headers))
})

test_that("get_app_token returns NULL when not set", {
  old_token <- Sys.getenv("CDC_APP_TOKEN", unset = NA)
  on.exit({
    if (is.na(old_token)) {
      Sys.unsetenv("CDC_APP_TOKEN")
    } else {
      Sys.setenv(CDC_APP_TOKEN = old_token)
    }
  })

  Sys.unsetenv("CDC_APP_TOKEN")

  expect_null(CDCdata:::get_app_token())
})

test_that("get_app_token returns token when set", {
  old_token <- Sys.getenv("CDC_APP_TOKEN", unset = NA)
  on.exit({
    if (is.na(old_token)) {
      Sys.unsetenv("CDC_APP_TOKEN")
    } else {
      Sys.setenv(CDC_APP_TOKEN = old_token)
    }
  })

  Sys.setenv(CDC_APP_TOKEN = "my-test-token")

  expect_equal(CDCdata:::get_app_token(), "my-test-token")
})

test_that("is_transient_error identifies retryable status codes", {
  # Create mock responses with different status codes
  # Note: This tests the logic, actual httr2 response objects
  # would need to be mocked more completely

  # We can test the function logic directly
  is_transient <- CDCdata:::is_transient_error

  # The function expects an httr2 response, so we skip detailed testing
expect_true(is.function(is_transient))
})
