# Fetch Large CDC Datasets with Pagination

Retrieves large datasets by automatically paginating through all
results. Shows a progress bar for long-running queries.

## Usage

``` r
cdc_fetch(
  dataset_id,
  select = NULL,
  where = NULL,
  order = NULL,
  q = NULL,
  max_rows = Inf,
  page_size = 1000,
  progress = interactive(),
  as_csv = FALSE
)
```

## Arguments

- dataset_id:

  Character. The unique dataset identifier (e.g., "swc5-untb" for PLACES
  data). You can find this in the dataset URL or via
  [`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md).

- select:

  Character vector. Columns to return. Use `NULL` for all columns.

- where:

  Character. SoQL WHERE clause for filtering rows. Example:
  `"year = '2023' AND stateabbr = 'MN'"`

- order:

  Character. Column(s) to sort by. Use `"column DESC"` for descending.

- q:

  Character. Full-text search query across all text fields.

- max_rows:

  Integer. Maximum total rows to fetch. Use `Inf` for all rows.

- page_size:

  Integer. Rows per API request (default 1000, max 50000).

- progress:

  Logical. Show progress bar? Default `TRUE` for interactive sessions.

- as_csv:

  Logical. If `TRUE`, requests data in CSV format instead of JSON. CSV
  can be faster for large datasets and may handle some data types
  differently. Default is `FALSE`.

## Value

A data.frame containing all fetched rows.

## See also

[`cdc_query()`](https://patrekieta.github.io/CDCdata/reference/cdc_query.md)

## Examples

``` r
if (FALSE) { # \dontrun{
places_mn <- cdc_fetch(
  "swc5-untb",
  where = "stateabbr = 'MN'",
  max_rows = 5000
)

all_data <- cdc_fetch("swc5-untb", where = "year = '2023'")

# Use CSV format for faster downloads
cdc_fetch("swc5-untb", where = "stateabbr = 'CA'", as_csv = TRUE)
} # }
```
