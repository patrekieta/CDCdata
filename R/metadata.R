#' Search CDC Datasets
#'
#' @description
#' Searches the CDC data portal catalog to discover available datasets.
#' Uses the Socrata Discovery API to find datasets by keyword.
#'
#' @param query Character. Search terms to find datasets. If `NULL`, returns
#'   recent/popular datasets.
#' @param category Character. Filter by category (e.g., "Health Statistics",
#'   "Vaccination"). Case-insensitive partial matching.
#' @param limit Integer. Maximum number of results (default 20, max 100).
#' @param only_datasets Logical. If `TRUE` (default), excludes maps,
#'   charts, and other non-tabular resources.
#'
#' @return A data.frame with columns:
#'   - `id`: Dataset identifier for use with [cdc_query()]
#'   - `name`: Dataset title
#'   - `description`: Brief description
#'   - `category`: Dataset category
#'   - `tags`: Comma-separated list of tags
#'   - `updated_at`: Last update timestamp
#'   - `rows`: Approximate row count (if available)
#'   - `url`: Direct link to dataset page
#'
#' @examples
#' \dontrun{
#' cdc_datasets("PLACES")
#'
#' cdc_datasets("mortality", limit = 10)
#'
#' cdc_datasets("vaccination", category = "COVID-19")
#' }
#'
#' @export
cdc_datasets <- function(query = NULL,
                         category = NULL,
                         limit = 20,
                         only_datasets = TRUE) {
  if (limit > 100) {
    cli::cli_warn("Maximum limit is 100. Setting to 100.")
    limit <- 100
  }

  params <- list(
    domains = "data.cdc.gov",
    search_context = "data.cdc.gov",
    limit = limit
  )

  if (!is.null(query)) {
    params[["q"]] <- query
  }

  if (only_datasets) {
    params[["only"]] <- "datasets"
  }

  req <- httr2::request("https://api.us.socrata.com") |>
    httr2::req_url_path("/api/catalog/v1") |>
    httr2::req_url_query(!!!params) |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_retry(max_tries = 3)

  resp <- httr2::req_perform(req)
  data <- httr2::resp_body_json(resp)

  if (length(data$results) == 0) {
    cli::cli_alert_warning("No datasets found matching your query.")
    return(data.frame(
      id = character(),
      name = character(),
      description = character(),
      category = character(),
      tags = character(),
      updated_at = character(),
      rows = integer(),
      url = character()
    ))
  }

  results <- lapply(data$results, function(r) {
    resource <- r$resource %||% list()
    link <- r$link %||% NA
    tags_list <- r$classification$domain_tags %||% character()

    data.frame(
      id = resource$id %||% NA,
      name = resource$name %||% NA,
      description = substr(resource$description %||% "", 1, 200),
      category = paste(r$classification$domain_category %||% "", collapse = ", "),
      tags = paste(tags_list, collapse = ", "),
      updated_at = resource$updatedAt %||% NA,
      rows = as.integer(resource$rows_count %||% NA),
      url = link
    )
  })

  result <- do.call(rbind, results)

  if (!is.null(category)) {
    result <- result[grepl(category, result$category, ignore.case = TRUE), ]
  }

  as.data.frame(result)
}


#' Get Dataset Metadata
#'
#' @description
#' Retrieves detailed metadata for a specific CDC dataset, including
#' column names, types, descriptions, and dataset-level information.
#'
#' @param dataset_id Character. The dataset identifier.
#' @param include_columns Logical. If `TRUE` (default), includes column-level metadata.
#' @param include_rowcount Logical. If `TRUE` (default), creates row count metadata. Row count is not available
#' in the api metadata so this has to be created manually using [cdc_count()].
#' @param cleaned Logical. If `TRUE` (default), returns the cleaned metadata. If `FALSE`, provides the raw metadata
#' including row_count (unless `include_rowcount = FALSE`).
#'
#' @return A list containing:
#'   - `id`: Dataset identifier
#'   - `name`: Dataset title
#'   - `description`: Full description
#'   - `attribution`: Data source attribution
#'   - `category`: Dataset category
#'   - `tags`: Associated tags
#'   - `created_at`: Creation timestamp
#'   - `updated_at`: Last update timestamp
#'   - `row_count`: Row count (if `include_rowcount = TRUE`)
#'   - `columns`: data.frame of column metadata (if `include_columns = TRUE`)
#'
#' @examples
#' \dontrun{
#' cdc_metadata("swc5-untb")
#' }
#'
#' @export
cdc_metadata <- function(dataset_id, include_columns = TRUE, include_rowcount = TRUE, cleaned = TRUE) {

  validate_dataset_id(dataset_id)

  endpoint <- paste0("/api/views/", dataset_id, ".json")
  req <- build_request(endpoint)

  data <- perform_request(req, as = "list")

  if(include_rowcount){
    rows <- CDCdata::cdc_count(dataset_id)
    data$row_count <- rows
  }

  if(!cleaned){
    return(data)
  }

  result <- list(
    id = data$id,
    name = data$name,
    description = data$description %||% NA,
    attribution = data$attribution %||% NA,
    category = data$category %||% NA,
    tags = data$tags %||% character(),
    created_at = data$createdAt,
    updated_at = data$rowsUpdatedAt,
    row_count = data$row_count %||% NA
  )

  if(include_columns && !is.null(data$columns)) {
    cols <- data$columns %||% NA
    result$cols <- cols
  }

  return(result)
}


#' Open Dataset in Browser
#'
#' @description Opens the CDC data portal page for a dataset in your default web browser.
#'
#' @param dataset_id Character. The dataset identifier.
#'
#' @examples
#' \dontrun{
#' cdc_browse("swc5-untb")
#' }
#'
#' @export
cdc_browse <- function(dataset_id) {
  validate_dataset_id(dataset_id)
  url <- paste0(.cdc_base_url, "/d/", dataset_id)
  utils::browseURL(url)
  cli::cli_alert_success("Opening {.url {url}}")
  invisible(url)
}


#' List Available Categories
#'
#' @description Returns a list of dataset categories available on data.cdc.gov.
#' Use these category names with [cdc_datasets_category()].
#'
#' @param limit Integer. Maximum categories to return (default 100).
#'
#' @return A data.frame with columns:
#'   - `category`: Category name
#'   - `count`: Number of datasets in this category
#'
#' @examples
#' \dontrun{
#' # List all categories
#' cdc_categories()
#'
#' # See which categories have the most datasets
#' cdc_categories() |> dplyr::arrange(dplyr::desc(count))
#' }
#'
#' @export
cdc_categories <- function(limit = 100) {
  params <- list(
    domains = "data.cdc.gov",
    search_context = "data.cdc.gov",
    only = "datasets",
    limit = 0
  )

  req <- httr2::request("https://api.us.socrata.com") |>
    httr2::req_url_path("/api/catalog/v1") |>
    httr2::req_url_query(!!!params) |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_retry(max_tries = 3)

  resp <- httr2::req_perform(req)
  data <- httr2::resp_body_json(resp)

  facets <- data$results
  if (length(facets) == 0) {
    datasets <- cdc_datasets(limit = limit)
    cats <- datasets$category[datasets$category != ""]
    cat_counts <- as.data.frame(table(cats), stringsAsFactors = FALSE)
    names(cat_counts) <- c("category", "count")
    return(as.data.frame(cat_counts))
  }

  data.frame(
    category = character(),
    count = integer()
  )
}


#' Search Datasets by Category
#'
#' @description
#' Finds datasets within a specific category on data.cdc.gov.
#' Use `cdc_categories()` to see available categories.
#'
#' @param category Character. The category name to search for.
#'   Supports partial matching (case-insensitive).
#' @param query Character. Optional additional search terms to filter within
#'   the category.
#' @param limit Integer. Maximum number of results (default 20, max 100).
#' @param exact Logical. If `TRUE`, requires exact category match. If `FALSE`
#'   (default), uses partial matching.
#'
#' @return A data.frame with columns:
#'   - `id`: Dataset identifier for use with [cdc_query()]
#'   - `name`: Dataset title
#'   - `description`: Brief description
#'   - `category`: Dataset category
#'   - `tags`: Comma-separated list of tags
#'   - `updated_at`: Last update timestamp
#'   - `rows`: Approximate row count (if available)
#'   - `url`: Direct link to dataset page
#'
#' @examples
#' \dontrun{
#' # Find all vaccination datasets
#' cdc_datasets_category("Vaccination")
#'
#' # Find COVID-19 related datasets
#' cdc_datasets_category("COVID-19")
#'
#' # Search within a category
#' cdc_datasets_category("Vaccination", query = "influenza")
#'
#' # Exact category match
#' cdc_datasets_category("NCHS", exact = TRUE)
#' }
#'
#' @seealso [cdc_categories()] to list available categories,
#'   [cdc_datasets()] for general keyword search.
#' @export
cdc_datasets_category <- function(category,
                                      query = NULL,
                                      limit = 20,
                                      exact = FALSE) {

  if (!is.character(category) || length(category) != 1 || nchar(category) == 0) {
    cli::cli_abort("{.arg category} must be a non-empty string.")
  }

  if (limit > 100) {
    cli::cli_warn("Maximum limit is 100. Setting to 100.")
    limit <- 100
  }

  params <- list(
    domains = "data.cdc.gov",
    search_context = "data.cdc.gov",
    categories = category,
    only = "datasets",
    limit = limit
  )

  if (!is.null(query)) {
    params[["q"]] <- query
  }

  req <- httr2::request("https://api.us.socrata.com") |>
    httr2::req_url_path("/api/catalog/v1") |>
    httr2::req_url_query(!!!params) |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_retry(max_tries = 3)

  resp <- httr2::req_perform(req)
  data <- httr2::resp_body_json(resp)

  if (length(data$results) == 0) {
    cli::cli_alert_warning("No datasets found in category {.val {category}}.")
    return(data.frame(
      id = character(),
      name = character(),
      description = character(),
      category = character(),
      tags = character(),
      updated_at = character(),
      url = character()
    ))
  }

  results <- lapply(data$results, function(r) {
    resource <- r$resource %||% list()
    link <- r$link %||% NA
    domain_cat <- paste(r$classification$domain_category %||% "", collapse = ", ")
    tags_list <- r$classification$domain_tags %||% character()

    data.frame(
      id = resource$id %||% NA,
      name = resource$name %||% NA,
      description = substr(resource$description %||% "", 1, 200),
      category = domain_cat,
      tags = paste(tags_list, collapse = ", "),
      updated_at = resource$updatedAt %||% NA,
      url = link
    )
  })

  result <- do.call(rbind, results)

  if (exact) {
    result <- result[tolower(result$category) == tolower(category), ]
  }


  if (nrow(result) == 0) {
    cli::cli_alert_warning(
      "No datasets found with exact category match for {.val {category}}."
    )
  }

  as.data.frame(result)
}


#' List Available Tags
#'
#' @description Returns a list of dataset tags available on data.cdc.gov.
#' Use these tag names with `cdc_datasets_tag()`.
#'
#' @param limit Integer. Maximum number of datasets to sample for extracting
#'   tags (default 100). Higher values give more complete tag lists but are slower.
#'
#' @return A data.frame with columns:
#'   - `tag`: Tag name
#'   - `count`: Number of datasets with this tag
#'
#' @examples
#' \dontrun{
#' # List all tags
#' cdc_tags()
#'
#' # See which tags are most common
#' cdc_tags() |> dplyr::arrange(dplyr::desc(count))
#' }
#'
#' @seealso [cdc_datasets_tag()] to find datasets with a specific tag.
#' @export
cdc_tags <- function(limit = 100) {
  datasets <- cdc_datasets(limit = limit)

  if (nrow(datasets) == 0 || all(datasets$tags == "")) {
    cli::cli_alert_warning("No tags found.")
    return(data.frame(
      tag = character(),
      count = integer()
    ))
  }

  all_tags <- unlist(strsplit(datasets$tags, ", "))
  all_tags <- all_tags[all_tags != ""]

  if (length(all_tags) == 0) {
    return(data.frame(
      tag = character(),
      count = integer()
    ))
  }

  tag_counts <- as.data.frame(table(all_tags), stringsAsFactors = FALSE)
  names(tag_counts) <- c("tag", "count")
  tag_counts <- tag_counts[order(-tag_counts$count), ]

  as.data.frame(tag_counts)
}


#' Search Datasets by Tag
#'
#' @description
#' Finds datasets with a specific tag on data.cdc.gov.
#' Use `cdc_tags()` to see available tags.
#'
#' @param tag Character. The tag name to search for.
#'   Supports partial matching (case-insensitive) by default.
#' @param query Character. Optional additional search terms to filter results.
#' @param limit Integer. Maximum number of results (default 20, max 100).
#' @param exact Logical. If `TRUE`, requires exact tag match. If `FALSE`
#'   (default), uses partial matching.
#'
#' @return A data.frame with columns:
#'   - `id`: Dataset identifier for use with `cdc_query()`
#'   - `name`: Dataset title
#'   - `description`: Brief description
#'   - `category`: Dataset category
#'   - `tags`: Comma-separated list of tags
#'   - `updated_at`: Last update timestamp
#'   - `rows`: Approximate row count (if available)
#'   - `url`: Direct link to dataset page
#'
#' @examples
#' \dontrun{
#' # Find datasets tagged with "covid-19"
#' cdc_datasets_tag("covid-19")
#'
#' # Find mortality-related datasets
#' cdc_datasets_tag("mortality")
#'
#' # Search within tagged datasets
#' cdc_datasets_tag("vaccination", query = "children")
#'
#' # Exact tag match
#' cdc_datasets_tag("brfss", exact = TRUE)
#' }
#'
#' @seealso [cdc_tags()] to list available tags,
#'   [cdc_datasets()] for general keyword search.
#' @export
cdc_datasets_tag <- function(tag,
                                query = NULL,
                                limit = 20,
                                exact = FALSE) {

  if (!is.character(tag) || length(tag) != 1 || nchar(tag) == 0) {
    cli::cli_abort("{.arg tag} must be a non-empty string.")
  }

  if (limit > 100) {
    cli::cli_warn("Maximum limit is 100. Setting to 100.")
    limit <- 100
  }

  params <- list(
    domains = "data.cdc.gov",
    search_context = "data.cdc.gov",
    tags = tag,
    only = "datasets",
    limit = limit
  )

  if (!is.null(query)) {
    params[["q"]] <- query
  }

  req <- httr2::request("https://api.us.socrata.com") |>
    httr2::req_url_path("/api/catalog/v1") |>
    httr2::req_url_query(!!!params) |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_retry(max_tries = 3)

  resp <- httr2::req_perform(req)
  data <- httr2::resp_body_json(resp)

  if (length(data$results) == 0) {
    cli::cli_alert_warning("No datasets found with tag {.val {tag}}.")
    return(data.frame(
      id = character(),
      name = character(),
      description = character(),
      category = character(),
      tags = character(),
      updated_at = character(),
      url = character()
    ))
  }

  results <- lapply(data$results, function(r) {
    resource <- r$resource %||% list()
    link <- r$link %||% NA
    domain_cat <- paste(r$classification$domain_category %||% "", collapse = ", ")
    tags_list <- r$classification$domain_tags %||% character()

    data.frame(
      id = resource$id %||% NA,
      name = resource$name %||% NA,
      description = substr(resource$description %||% "", 1, 200),
      category = domain_cat,
      tags = paste(tags_list, collapse = ", "),
      updated_at = resource$updatedAt %||% NA,
      url = link
    )
  })

  result <- do.call(rbind, results)

  if (exact) {
    has_exact_tag <- sapply(strsplit(result$tags, ", "), function(tags) {
      tolower(tag) %in% tolower(tags)
    })
    result <- result[has_exact_tag, ]
  }

  if (nrow(result) == 0) {
    cli::cli_alert_warning(
      "No datasets found with exact tag match for {.val {tag}}."
    )
  }

  as.data.frame(result)
}

