# Test helper functions

skip_if_cdc_unavailable <- function() {
  testthat::skip_if_offline()

  tryCatch({
    httr2::request("https://data.cdc.gov") |>
      httr2::req_timeout(5) |>
      httr2::req_perform()
  }, error = function(e) {
    testthat::skip("CDC API not reachable")
  })
}
