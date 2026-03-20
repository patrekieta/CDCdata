#' Get Row Count for a Dataset
#'
#' @description Returns the number of rows in a dataset (or matching a filter).
#' Useful for checking dataset size before fetching.
#'
#' @inheritParams cdc_query
#'
#' @return Integer. The row count.
#'
#' @examples
#' \dontrun{
#' cdc_count("swc5-untb")
#'
#' cdc_count("swc5-untb", where = "stateabbr = 'MN'")
#' }
#'
#' @export
cdc_count <- function(dataset_id, where = NULL, ...) {
  result <- cdc_query(
    dataset_id = dataset_id,
    select = "count(*) as n",
    where = where,
    as = "dataframe",
    progress = FALSE,
    quiet_token = TRUE,
    ...
  )

  as.integer(result$n[[1]])
}


#' Get Column Names for a Dataset
#'
#' @description Returns the column (field) names for a dataset. Useful for building queries.
#'
#' @param dataset_id Character. The dataset identifier.
#'
#' @return Character vector of column names.
#'
#' @examples
#' \dontrun{
#' cdc_columns("swc5-untb")
#' }
#'
#' @export
cdc_columns <- function(dataset_id) {
  meta <- cdc_metadata(dataset_id, include_rowcount = FALSE)
  return(meta$cols)
}


#' Get Distinct Values for a Column
#'
#' @description Returns unique values for a column in a dataset.
#' Useful for exploring categorical variables.
#'
#' @inheritParams cdc_query
#' @param column Character. The column name.
#' @param limit Integer. Maximum distinct values to return (default 100).
#' @param ... Arguments passed to [cdc_query()]
#'
#' @return A data.frame with the distinct values and their counts.
#'
#' @examples
#' \dontrun{
#' cdc_distinct("swc5-untb", "stateabbr")
#'
#' cdc_distinct("swc5-untb", "year")
#' }
#'
#' @export
cdc_distinct <- function(dataset_id, column, where = NULL, limit = 100, ...) {
  if(is.null(column)){
    cli::cli_abort("Must provide valid {.arg column} name.")
  }

  cdc_query(
    dataset_id = dataset_id,
    select = c(column, "count(*) as n"),
    where = where,
    group = column,
    order = "n DESC",
    limit = limit,
    ...
  )
}


#' Preview Dataset Sample
#'
#' @description Returns a small sample of rows from a dataset for quick inspection.
#'
#' @inheritParams cdc_query
#' @param n Integer. Number of rows to return (default 10).
#' @param ... Arguments passed to [cdc_query()]
#'
#' @return A data.frame with the sample rows.
#'
#' @examples
#' \dontrun{
#' cdc_preview("swc5-untb")
#' }
#'
#' @export
cdc_preview <- function(dataset_id, n = 10, ...) {
  cdc_query(dataset_id, limit = n, ...)
}
