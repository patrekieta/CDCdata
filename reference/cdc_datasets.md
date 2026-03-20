# Search CDC Datasets

Searches the CDC data portal catalog to discover available datasets.
Uses the Socrata Discovery API to find datasets by keyword.

## Usage

``` r
cdc_datasets(query = NULL, category = NULL, limit = 20, only_datasets = TRUE)
```

## Arguments

- query:

  Character. Search terms to find datasets. If `NULL`, returns
  recent/popular datasets.

- category:

  Character. Filter by category (e.g., "Health Statistics",
  "Vaccination"). Case-insensitive partial matching.

- limit:

  Integer. Maximum number of results (default 20, max 100).

- only_datasets:

  Logical. If `TRUE` (default), excludes maps, charts, and other
  non-tabular resources.

## Value

A data.frame with columns:

- `id`: Dataset identifier for use with
  [`cdc_query()`](https://patrekieta.github.io/CDCdata/reference/cdc_query.md)

- `name`: Dataset title

- `description`: Brief description

- `category`: Dataset category

- `tags`: Comma-separated list of tags

- `updated_at`: Last update timestamp

- `rows`: Approximate row count (if available)

- `url`: Direct link to dataset page

## Examples

``` r
if (FALSE) { # \dontrun{
cdc_datasets("PLACES")

cdc_datasets("mortality", limit = 10)

cdc_datasets("vaccination", category = "COVID-19")
} # }
```
