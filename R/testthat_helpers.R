# Test helper functions

# Check if we have internet connectivity
skip_if_offline <- function() {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }

  # Also check if CDC API is reachable
  tryCatch({
    httr2::request("https://data.cdc.gov") |>
      httr2::req_timeout(5) |>
      httr2::req_perform()
  }, error = function(e) {
    skip("CDC API not reachable")
  })
}

