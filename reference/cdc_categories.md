# List Available Categories

Returns a list of dataset categories available on data.cdc.gov. Use
these category names with
[`cdc_datasets_category()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets_category.md).

## Usage

``` r
cdc_categories(limit = 100)
```

## Arguments

- limit:

  Integer. Maximum categories to return (default 100).

## Value

A data.frame with columns:

- `category`: Category name

- `count`: Number of datasets in this category

## Examples

``` r
if (FALSE) { # \dontrun{
# List all categories
cdc_categories()

# See which categories have the most datasets
cdc_categories() |> dplyr::arrange(dplyr::desc(count))
} # }
```
