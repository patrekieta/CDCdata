# Get Row Count for a Dataset

Returns the number of rows in a dataset (or matching a filter). Useful
for checking dataset size before fetching.

## Usage

``` r
cdc_count(dataset_id, where = NULL, ...)
```

## Arguments

- dataset_id:

  Character. The unique dataset identifier (e.g., "swc5-untb" for PLACES
  data). You can find this in the dataset URL or via
  [`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md).

- where:

  Character. SoQL WHERE clause for filtering rows. Example:
  `"year = '2023' AND stateabbr = 'MN'"`

## Value

Integer. The row count.

## Examples

``` r
if (FALSE) { # \dontrun{
cdc_count("swc5-untb")

cdc_count("swc5-untb", where = "stateabbr = 'MN'")
} # }
```
