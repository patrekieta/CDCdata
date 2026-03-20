#' Query a CDC Dataset
#'
#' @description Fetches data from a CDC dataset on data.cdc.gov using the Socrata API.
#' Supports flexible querying via SoQL ([Socrata Query Language](https://dev.socrata.com/docs/functions/#,)).
#'
#' @param dataset_id Character. The unique dataset identifier (e.g., "swc5-untb"
#'   for PLACES data). You can find this in the dataset URL or via `cdc_datasets()`.
#' @param select Character vector. Columns to return. Use `NULL` for all columns.
#' @param where Character. SoQL WHERE clause for filtering rows.
#'   Example: `"year = '2023' AND stateabbr = 'MN'"`
#' @param order Character. Column(s) to sort by. Use `"column DESC"` for descending.
#' @param group Character. Column(s) to group by for aggregation.
#' @param having Character. SoQL HAVING clause for filtering aggregated results.
#' @param q Character. Full-text search query across all text fields.
#' @param limit Integer. Maximum rows to return. Default 1000, max 50000 per request.
#' @param offset Integer. Number of rows to skip (for manual pagination).
#' @param as Character. Output format: "dataframe" (default), "list", or "raw".
#' @param as_csv Logical. If `TRUE`, requests data in CSV format instead of JSON.
#'   CSV can be faster for large datasets and may handle some data types differently.
#'   Default is `FALSE`.
#'
#' @return A data.frame (default), list, or raw string depending on `as`.
#'
#' @details
#' ## SoQL Reference
#'
#' Common WHERE clause operators:
#' - Comparison: `=`, `!=`, `<`, `>`, `<=`, `>=`
#' - Logical: `AND`, `OR`, `NOT`
#' - Text: `LIKE '%pattern%'`, `starts_with()`, `contains()`
#' - Null checks: `IS NULL`, `IS NOT NULL`
#' - Lists: `IN ('a', 'b', 'c')`
#'
#' Aggregation functions (use with `group`):
#' - `count(*)`, `sum()`, `avg()`, `min()`, `max()`
#'
#' ## JSON vs CSV
#'
#' JSON (default) preserves data types and handles nested structures.
#' CSV may be faster for large flat datasets but converts everything to strings.
#'
#'
#' @examples
#' \dontrun{
#' cdc_query("swc5-untb", limit = 100)
#'
#' cdc_query(
#'   "swc5-untb",
#'   select = c("stateabbr", "locationname", "access2_crudeprev"),
#'   where = "stateabbr = 'MN' AND year = '2023'",
#'   order = "access2_crudeprev DESC",
#'   limit = 50
#' )
#'
#' cdc_query(
#'   "swc5-untb",
#'   select = c("stateabbr", "count(*) as n"),
#'   group = "stateabbr",
#'   order = "n DESC"
#' )
#'
#' # Use CSV format for potentially faster downloads
#' cdc_query("swc5-untb", limit = 100, as_csv = TRUE)
#' }
#'
#' @seealso [cdc_fetch()] for paginated retrieval of large datasets.
#' @export
cdc_query <- function(dataset_id,
                      select = NULL,
                      where = NULL,
                      order = NULL,
                      group = NULL,
                      having = NULL,
                      q = NULL,
                      limit = 1000,
                      offset = NULL,
                      as = c("dataframe", "list", "raw"),
                      as_csv = FALSE,
                      progress = interactive()) {

  as <- match.arg(as)

  validate_dataset_id(dataset_id)

  format <- if(as_csv){"csv"} else {"json"}

  params <- build_soql_params(
    select = select,
    where = where,
    order = order,
    group = group,
    having = having,
    limit = limit,
    offset = offset,
    q = q
  )

  req <- build_request(dataset_id = dataset_id, format = format)

  if(length(params) > 0) {
    req <- httr2::req_url_query(req, !!!params)
  }

  if(progress) {
    cli::cli_alert_info("Fetching data from {.val {dataset_id}}...")
  }

  output <- perform_request(req, as = as, format = format)

  if(progress) {
    cli::cli_alert_success("Complete: {.val {nrow(output)}} rows fetched.")
  }
  return(output)
}


#' Fetch Large CDC Datasets with Pagination
#'
#' @description Retrieves large datasets by automatically paginating through all results.
#' Shows a progress bar for long-running queries.
#'
#' @inheritParams cdc_query
#' @param max_rows Integer. Maximum total rows to fetch. Use `Inf` for all rows.
#' @param page_size Integer. Rows per API request (default 1000, max 50000).
#' @param progress Logical. Show progress bar? Default `TRUE` for interactive sessions.
#'
#' @return A data.frame containing all fetched rows.
#'
#' @examples
#' \dontrun{
#' places_mn <- cdc_fetch(
#'   "swc5-untb",
#'   where = "stateabbr = 'MN'",
#'   max_rows = 5000
#' )
#'
#' all_data <- cdc_fetch("swc5-untb", where = "year = '2023'")
#'
#' # Use CSV format for faster downloads
#' cdc_fetch("swc5-untb", where = "stateabbr = 'CA'", as_csv = TRUE)
#' }
#'
#' @seealso [cdc_query()]
#' @export
cdc_fetch <- function(dataset_id,
                      select = NULL,
                      where = NULL,
                      order = NULL,
                      q = NULL,
                      max_rows = Inf,
                      page_size = 1000,
                      progress = interactive(),
                      as_csv = FALSE) {
  validate_dataset_id(dataset_id)

  if(page_size > 50000) {
    cli::cli_warn("Maximum page size is 50,000. Setting {.arg page_size} to 50000.")
    page_size <- 50000
  }

  all_data <- list()
  offset <- 0
  rows_fetched <- 0
  page <- 1

  if(progress) {
    cli::cli_alert_info("Fetching data from {.val {dataset_id}}...")
  }

  repeat {
    current_limit <- min(page_size, max_rows - rows_fetched)
    if(current_limit <= 0) {
      break
    }

    chunk <- cdc_query(
      dataset_id = dataset_id,
      select = select,
      where = where,
      order = order,
      q = q,
      limit = current_limit,
      offset = offset,
      as = "dataframe",
      as_csv = as_csv,
      progress = FALSE
    )

    if(nrow(chunk) == 0){
      break
    }

    all_data[[page]] <- chunk
    rows_fetched <- rows_fetched + nrow(chunk)
    offset <- offset + nrow(chunk)
    page <- page + 1L

    if(progress) {
      cli::cli_alert_info("Fetched {.val {rows_fetched}} rows...")
    }

    if(nrow(chunk) < current_limit){
      break
    }
    if(rows_fetched >= max_rows) {
      break
    }
    if(rows_fetched != page_size){
      break
    }
  }

  if(length(all_data) == 0) {
    if(progress) {
      cli::cli_alert_warning("No data returned.")
    }
    return(data.frame())
  }

  result <- tryCatch(
    {
      # Try dplyr::bind_rows if available
      if (requireNamespace("dplyr", quietly = TRUE)) {
        dplyr::bind_rows(all_data)
      } else {
        # Manual column alignment fallback
        all_cols <- unique(unlist(lapply(all_data, names)))
        aligned <- lapply(all_data, function(df) {
          missing_cols <- setdiff(all_cols, names(df))
          for (col in missing_cols) {
            df[[col]] <- NA
          }
          df[, all_cols, drop = FALSE]
        })
        do.call(rbind, aligned)
      }
    },
    error = function(e) {
      # Last resort: just rbind and let it fail with informative error
      do.call(rbind, all_data)
    }
  )

  if(progress) {
    cli::cli_alert_success("Complete: {.val {nrow(result)}} rows fetched.")
  }

  as.data.frame(result)
}

