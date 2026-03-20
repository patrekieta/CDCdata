# Package-level constants
.cdc_base_url <- "https://data.cdc.gov"
.socrata_base_url <- "https://api.us.socrata.com"

# Default configuration
.cdc_defaults <- list(
  page_size = 1000,
  max_retries = 3,

  rate_limit = 10
)

#' Check if an HTTP error is transient (retryable)
#'
#' @param resp An httr2 response object.
#' @return Logical indicating if the error is transient.
#' @noRd
is_transient_error <- function(resp) {
  status <- httr2::resp_status(resp)
  status %in% c(429L, 500L, 502L, 503L, 504L)
}

#' Validate dataset ID format
#'
#' @param id The dataset ID to validate.
#' @noRd
validate_dataset_id <- function(id) {

  if(!is.character(id) || length(id) != 1 || nchar(id) == 0) {
    cli::cli_abort("{.arg dataset_id} must be a non-empty string.")
  }

  if (!grepl("^[a-z0-9]{4}-[a-z0-9]{4}$", id)) {
    cli::cli_warn(
      c(
        "Dataset ID {.val {id}} doesn't match expected format.",
        "i" = "Expected format: {.val xxxx-xxxx} (e.g., {.val swc5-untb})."
      )
    )
  }
}



# NULL check and replacement
`%||%` <- function(x, y){
  if(is.null(x)){
    y
  } else{
    x
  }
}
