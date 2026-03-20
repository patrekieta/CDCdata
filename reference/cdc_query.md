# Query a CDC Dataset

Fetches data from a CDC dataset on data.cdc.gov using the Socrata API.
Supports flexible querying via SoQL ([Socrata Query
Language](https://dev.socrata.com/docs/functions/#,)).

## Usage

``` r
cdc_query(
  dataset_id,
  select = NULL,
  where = NULL,
  order = NULL,
  group = NULL,
  having = NULL,
  q = NULL,
  limit = 1000,
  offset = NULL,
  as = c("dataframe", "list", "raw"),
  as_csv = FALSE,
  progress = interactive(),
  quiet_token = FALSE
)
```

## Arguments

- dataset_id:

  Character. The unique dataset identifier (e.g., "swc5-untb" for PLACES
  data). You can find this in the dataset URL or via
  [`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md).

- select:

  Character vector. Columns to return. Use `NULL` for all columns.

- where:

  Character. SoQL WHERE clause for filtering rows. Example:
  `"year = '2023' AND stateabbr = 'MN'"`

- order:

  Character. Column(s) to sort by. Use `"column DESC"` for descending.

- group:

  Character. Column(s) to group by for aggregation.

- having:

  Character. SoQL HAVING clause for filtering aggregated results.

- q:

  Character. Full-text search query across all text fields.

- limit:

  Integer. Maximum rows to return. Default 1000, max 50000 per request.

- offset:

  Integer. Number of rows to skip (for manual pagination).

- as:

  Character. Output format: "dataframe" (default), "list", or "raw".

- as_csv:

  Logical. If `TRUE`, requests data in CSV format instead of JSON. CSV
  can be faster for large datasets and may handle some data types
  differently. Default is `FALSE`.

- progress:

  Logical. If `TRUE`, shows progress messages in the console.

- quiet_token:

  Logical. If `TRUE`, will not show console alerts for
  [`cdc_app_token()`](https://patrekieta.github.io/CDCdata/reference/cdc_app_token.md).

## Value

A data.frame (default), list, or raw string depending on `as`.

## Details

### SoQL Reference

Common WHERE clause operators:

- Comparison: `=`, `!=`, `<`, `>`, `<=`, `>=`

- Logical: `AND`, `OR`, `NOT`

- Text: `LIKE '%pattern%'`, `starts_with()`, `contains()`

- Null checks: `IS NULL`, `IS NOT NULL`

- Lists: `IN ('a', 'b', 'c')`

Aggregation functions (use with `group`):

- `count(*)`, [`sum()`](https://rdrr.io/r/base/sum.html), `avg()`,
  [`min()`](https://rdrr.io/r/base/Extremes.html),
  [`max()`](https://rdrr.io/r/base/Extremes.html)

### JSON vs CSV

JSON (default) preserves data types and handles nested structures. CSV
may be faster for large flat datasets but converts everything to
strings.

## See also

[`cdc_fetch()`](https://patrekieta.github.io/CDCdata/reference/cdc_fetch.md)
for paginated retrieval of large datasets.

## Examples

``` r
if (FALSE) { # \dontrun{
cdc_query("swc5-untb", limit = 100)

cdc_query(
  "swc5-untb",
  select = c("stateabbr", "locationname", "access2_crudeprev"),
  where = "stateabbr = 'MN' AND year = '2023'",
  order = "access2_crudeprev DESC",
  limit = 50
)

cdc_query(
  "swc5-untb",
  select = c("stateabbr", "count(*) as n"),
  group = "stateabbr",
  order = "n DESC"
)

# Use CSV format for potentially faster downloads
cdc_query("swc5-untb", limit = 100, as_csv = TRUE)
} # }
```
