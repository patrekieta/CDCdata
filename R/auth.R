cdc_app_token <- function(token = NULL, quiet = FALSE) {
  env_var <- "CDC_APP_TOKEN"

  if (is.null(token)) {
    current <- Sys.getenv(env_var, unset = NA_character_)
    if (is.na(current)) {
      if (!quiet) {
        cli::cli_alert_info(
          "No app token set. Anonymous requests have lower rate limits."
        )
        cli::cli_alert_info(
          "Get a token at {.url https://data.cdc.gov/profile/edit/developer_settings}"
        )
      }
      return(invisible(NULL))
    }
    return(invisible(current))
  }

  if (!is.character(token) || length(token) != 1 || nchar(token) == 0) {
    cli::cli_abort("{.arg token} must be a non-empty string.")
  }

  Sys.setenv(CDC_APP_TOKEN = token)
  if (!quiet) {
    cli::cli_alert_success("CDC app token set for this session.")
  }
  invisible(token)
}


get_app_token <- function() {
  token <- Sys.getenv("CDC_APP_TOKEN", unset = NA_character_)
  if (is.na(token)) NULL else token
}
