# Search Datasets by Tag

Finds datasets with a specific tag on data.cdc.gov. Use
[`cdc_tags()`](https://patrekieta.github.io/CDCdata/reference/cdc_tags.md)
to see available tags.

## Usage

``` r
cdc_datasets_tag(tag, query = NULL, limit = 20, exact = FALSE)
```

## Arguments

- tag:

  Character. The tag name to search for. Supports partial matching
  (case-insensitive) by default.

- query:

  Character. Optional additional search terms to filter results.

- limit:

  Integer. Maximum number of results (default 20, max 100).

- exact:

  Logical. If `TRUE`, requires exact tag match. If `FALSE` (default),
  uses partial matching.

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

[`cdc_tags()`](https://patrekieta.github.io/CDCdata/reference/cdc_tags.md)
to list available tags,
[`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md)
for general keyword search.

## Examples

``` r
if (FALSE) { # \dontrun{
# Find datasets tagged with "covid-19"
cdc_datasets_tag("covid-19")

# Find mortality-related datasets
cdc_datasets_tag("mortality")

# Search within tagged datasets
cdc_datasets_tag("vaccination", query = "children")

# Exact tag match
cdc_datasets_tag("brfss", exact = TRUE)
} # }
```
