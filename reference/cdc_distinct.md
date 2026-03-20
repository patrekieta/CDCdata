# Get Distinct Values for a Column

Returns unique values for a column in a dataset. Useful for exploring
categorical variables.

## Usage

``` r
cdc_distinct(dataset_id, column, where = NULL, limit = 100, ...)
```

## Arguments

- dataset_id:

  Character. The unique dataset identifier (e.g., "swc5-untb" for PLACES
  data). You can find this in the dataset URL or via
  [`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md).

- column:

  Character. The column name.

- where:

  Character. SoQL WHERE clause for filtering rows. Example:
  `"year = '2023' AND stateabbr = 'MN'"`

- limit:

  Integer. Maximum distinct values to return (default 100).

- ...:

  Arguments passed to
  [`cdc_query()`](https://patrekieta.github.io/CDCdata/reference/cdc_query.md)

## Value

A data.frame with the distinct values and their counts.

## Examples

``` r
if (FALSE) { # \dontrun{
cdc_distinct("swc5-untb", "stateabbr")

cdc_distinct("swc5-untb", "year")
} # }
```
