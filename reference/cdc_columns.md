# Get Column Names for a Dataset

Returns the column (field) names for a dataset. Useful for building
queries.

## Usage

``` r
cdc_columns(dataset_id)
```

## Arguments

- dataset_id:

  Character. The dataset identifier.

## Value

Character vector of column names.

## Examples

``` r
if (FALSE) { # \dontrun{
cdc_columns("swc5-untb")
} # }
```
