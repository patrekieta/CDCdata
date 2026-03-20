# Preview Dataset Sample

Returns a small sample of rows from a dataset for quick inspection.

## Usage

``` r
cdc_preview(dataset_id, n = 10, ...)
```

## Arguments

- dataset_id:

  Character. The unique dataset identifier (e.g., "swc5-untb" for PLACES
  data). You can find this in the dataset URL or via
  [`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md).

- n:

  Integer. Number of rows to return (default 10).

- ...:

  Arguments passed to
  [`cdc_query()`](https://patrekieta.github.io/CDCdata/reference/cdc_query.md)

## Value

A data.frame with the sample rows.

## Examples

``` r
if (FALSE) { # \dontrun{
cdc_preview("swc5-untb")
} # }
```
