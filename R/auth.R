#' Set and Get App token from CDC
#'
#' @rdname cdc_app_token
#'
#' @description
#' Helper function for setting and getting your CDC App token for use throughout the package.
#' This is not strictyly necessary as data.cdc.gov allows anonymous requests. App tokens are useful for
#' security reasons and to bypass the rate limits that are forced with anonymous API requests.
#'
#' @param token App token from [data.cdc.gov](https://data.cdc.gov/). This should be a character string
#' which gets attached to your system environment for security.
#'
#' @return Character. The app token.
#'
#' @details To receive your app token, you can go to [https://data.cdc.gov/signup](https://data.cdc.gov/signup). After
#' setting up your account, you can go to the [developer settings](https://data.cdc.gov/profile/edit/developer_settings) to
#' create a new app token.
#'
#' @examples
#' cdc_app_token()
#'
#' cdc_app_token(token = "APP_TOKEN")
#'
#' @export
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
          "Get a token at {.url https://data.cdc.gov/signup}"
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

#' @rdname cdc_app_token
#'
#' @examples cdc_set_token(token = "APP_TOKEN")
#'
#' @export
cdc_set_token <- function(token){
  cdc_app_token(token = token)
}

#' @rdname cdc_app_token
#'
#' @examples cdc_get_token()
#'
#' @export
cdc_get_token <- function() {
  token <- Sys.getenv("CDC_APP_TOKEN", unset = NA_character_)
  if(is.na(token)){
    return(NULL)
    } else {
      return(token)
    }
}
