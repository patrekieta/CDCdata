# List Available Tags

Returns a list of dataset tags available on data.cdc.gov. Use these tag
names with
[`cdc_datasets_tag()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets_tag.md).

## Usage

``` r
cdc_tags(limit = 100)
```

## Arguments

- limit:

  Integer. Maximum number of datasets to sample for extracting tags
  (default 100). Higher values give more complete tag lists but are
  slower.

## Value

A data.frame with columns:

- `tag`: Tag name

- `count`: Number of datasets with this tag

## See also

[`cdc_datasets_tag()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets_tag.md)
to find datasets with a specific tag.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all tags
cdc_tags()

# See which tags are most common
cdc_tags() |> dplyr::arrange(dplyr::desc(count))
} # }
```
