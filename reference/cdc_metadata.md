# Get Dataset Metadata

Retrieves detailed metadata for a specific CDC dataset, including column
names, types, descriptions, and dataset-level information.

## Usage

``` r
cdc_metadata(
  dataset_id,
  include_columns = TRUE,
  include_rowcount = TRUE,
  cleaned = TRUE,
  progress = interactive()
)
```

## Arguments

- dataset_id:

  Character. The dataset identifier.

- include_columns:

  Logical. If `TRUE` (default), includes column-level metadata.

- include_rowcount:

  Logical. If `TRUE` (default), creates row count metadata. Row count is
  not available in the api metadata so this has to be created manually
  using
  [`cdc_count()`](https://patrekieta.github.io/CDCdata/reference/cdc_count.md).

- cleaned:

  Logical. If `TRUE` (default), returns the cleaned metadata. If
  `FALSE`, provides the raw metadata including row_count (unless
  `include_rowcount = FALSE`).

- progress:

  Logical. If `TRUE` (default), shows function progress outputs in
  console.

## Value

A list containing:

- `id`: Dataset identifier

- `name`: Dataset title

- `description`: Full description

- `attribution`: Data source attribution

- `category`: Dataset category

- `tags`: Associated tags

- `created_at`: Creation timestamp

- `updated_at`: Last update timestamp

- `row_count`: Row count (if `include_rowcount = TRUE`)

- `columns`: data.frame of column metadata (if `include_columns = TRUE`)

## Examples

``` r
if (FALSE) { # \dontrun{
cdc_metadata("swc5-untb")
} # }
```
