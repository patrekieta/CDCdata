# Search Datasets by Category

Finds datasets within a specific category on data.cdc.gov. Use
[`cdc_categories()`](https://patrekieta.github.io/CDCdata/reference/cdc_categories.md)
to see available categories.

## Usage

``` r
cdc_datasets_category(category, query = NULL, limit = 20, exact = FALSE)
```

## Arguments

- category:

  Character. The category name to search for. Supports partial matching
  (case-insensitive).

- query:

  Character. Optional additional search terms to filter within the
  category.

- limit:

  Integer. Maximum number of results (default 20, max 100).

- exact:

  Logical. If `TRUE`, requires exact category match. If `FALSE`
  (default), uses partial matching.

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

## See also

[`cdc_categories()`](https://patrekieta.github.io/CDCdata/reference/cdc_categories.md)
to list available categories,
[`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md)
for general keyword search.

## Examples

``` r
if (FALSE) { # \dontrun{
# Find all vaccination datasets
cdc_datasets_category("Vaccination")

# Find COVID-19 related datasets
cdc_datasets_category("COVID-19")

# Search within a category
cdc_datasets_category("Vaccination", query = "influenza")

# Exact category match
cdc_datasets_category("NCHS", exact = TRUE)
} # }
```
