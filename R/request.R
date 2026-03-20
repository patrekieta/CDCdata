#' Build a base request to the CDC API
#'
#' @description Internal function to create an httr2 request object with common
#' configuration: headers, authentication, retry logic, and rate limiting.
#'
#' @param dataset_id Character. The Dataset ID found in data.cdc.gov.
#' @param base_url Character. The base URL (default: data.cdc.gov).
#' @param format Character. Response format: "json" or "csv".
#'
#' @return An httr2 request object.
#'
#' @export
build_request <- function(dataset_id, base_url = .cdc_base_url, format = "json") {

  accept_header <- if(format == "csv"){"text/csv"} else {"application/json"}

  token <- cdc_get_token()
  if(!is.null(token)){
    endpoint <- paste0("/api/v3/views/", dataset_id, "/query.", format)
  } else {
    endpoint <- paste0("/resource/", dataset_id, ".", format)
  }

  req <- httr2::request(base_url) |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_headers(
      Accept = accept_header,
      `User-Agent` = paste0("cdcdata/", utils::packageVersion("cdcdata"))
    ) |>
    httr2::req_retry(
      max_tries = .cdc_defaults$max_retries,
      is_transient = is_transient_error
    ) |>
    httr2::req_throttle(rate = .cdc_defaults$rate_limit)

  if(!is.null(token)) {
    req <- httr2::req_headers(req, `X-App-Token` = token)
  }

  req
}

#' Build a base request to the CDC API
#'
#' @description Internal function to create an httr2 request object with common
#' configuration: headers, authentication, retry logic, and rate limiting.
#'
#' @param endpoint Character. The API endpoint path.
#' @param base_url Character. The base URL (default: data.cdc.gov).
#' @param format Character. Response format: "json" or "csv".
#'
#' @return An httr2 request object.
#'
#' @export
build_request2 <- function(endpoint, base_url = .cdc_base_url, format = "json") {

  accept_header <- if (format == "csv") "text/csv" else "application/json"

  req <- httr2::request(base_url) |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_headers(
      Accept = accept_header,
      `User-Agent` = paste0("cdcdata/", utils::packageVersion("cdcdata"))
    ) |>
    httr2::req_retry(
      max_tries = .cdc_defaults$max_retries,
      is_transient = is_transient_error
    ) |>
    httr2::req_throttle(rate = .cdc_defaults$rate_limit)

  token <- cdc_get_token()
  if (!is.null(token)) {
    req <- httr2::req_headers(req, `X-App-Token` = token)
  }

  req
}


#' Build SoQL query parameters
#'
#' @description Converts query parameters to Socrata Query Language (SoQL) format.
#'
#' @param select Character vector of column names to return.
#' @param where Character. SoQL WHERE clause for filtering.
#' @param order Character. Column(s) to sort by.
#' @param group Character. Column(s) to group by.
#' @param having Character. SoQL HAVING clause for filtering groups.
#' @param limit Integer. Maximum number of rows to return.
#' @param offset Integer. Number of rows to skip.
#' @param q Character. Full-text search query.
#'
#' @return A named list of query parameters.
#'
#' @noRd
build_soql_params <- function(select = NULL,
                               where = NULL,
                               order = NULL,
                               group = NULL,
                               having = NULL,
                               limit = NULL,
                               offset = NULL,
                               q = NULL) {
  params <- list()

  if (!is.null(select)) {
    params[["$select"]] <- paste(select, collapse = ", ")
  }
  if (!is.null(where)) {
    params[["$where"]] <- where
  }
  if (!is.null(order)) {
    params[["$order"]] <- order
  }
  if (!is.null(group)) {
    params[["$group"]] <- group
  }
  if (!is.null(having)) {
    params[["$having"]] <- having
  }
  if (!is.null(limit)) {
    params[["$limit"]] <- as.integer(limit)
  }
  if (!is.null(offset)) {
    params[["$offset"]] <- as.integer(offset)
  }
  if (!is.null(q)) {
    params[["$q"]] <- q
  }

  params
}


#' Perform API request and parse response
#'
#' @param req An httr2 request object.
#' @param as Character. Output format: "dataframe", "list", or "raw".
#' @param format Character. Response format: "json" or "csv".
#'
#' @return Parsed response in requested format.
#' @export
perform_request <- function(req, as = "dataframe", format = "json") {
  resp <- httr2::req_perform(req)

  if(as == "raw") {
    return(httr2::resp_body_string(resp))
  }

  if(format == "csv") {
    csv_text <- httr2::resp_body_string(resp)
    data <- utils::read.csv(
      text = csv_text,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    if(as == "list") {
      return(as.list(data))
    } else {
      return(as.data.frame(data))
    }
  }

  data <- httr2::resp_body_json(resp, simplifyVector = TRUE)

  if(as == "list") {
    return(data)
  }

  if (is.data.frame(data)) {
    as.data.frame(data)
  } else if (is.list(data) && length(data) > 0) {
    tryCatch(
      as.data.frame(data),
      error = function(e) data
    )
  } else {
    data
  }
}
