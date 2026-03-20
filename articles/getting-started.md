# Getting Started with CDCdata

The `cdcdata` package provides a modern R interface to the CDC’s open
data portal ([data.cdc.gov](https://data.cdc.gov)), which runs on the
Socrata platform. While similar packages exist such as
[CDCPLACES](https://github.com/brendensm/CDCPLACES) and
[RSocrata](https://github.com/Chicago/RSocrata), these are either too
limited in scope or too generic for data.cdc.gov usage. The hope for
this package is to provide a way to programmatically access the
data.cdc.gov site in a user friendly way.

## Installation

``` r
devtools::install_github("https://github.com/patrekieta/CDCdata")
```

``` r
library(CDCdata)
```

## Discovering Datasets

The CDC data portal hosts hundreds of public health datasets. You can
search for datasets by keyword, browse by category, or explore by tag.

### Search by Keyword

Use
[`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md)
to search for datasets:

``` r
# Search for PLACES data
cdc_datasets("PLACES")

# Search for mortality data
cdc_datasets("mortality", limit = 10)
```

The function returns a data frame with dataset IDs, names, descriptions,
categories, tags, and row counts. The `id` column contains the
identifier you’ll use to query the data.

### Browse by Category

Datasets are organized into categories. Use
[`cdc_categories()`](https://patrekieta.github.io/CDCdata/reference/cdc_categories.md)
to see what’s available:

``` r
# List all categories
cdc_categories()

# Find datasets in a specific category
cdc_datasets_by_category("Vaccination")

# Search within a category
cdc_datasets_by_category("COVID-19", query = "cases")
```

### Browse by Tag

Tags provide more granular classification. Use
[`cdc_tags()`](https://patrekieta.github.io/CDCdata/reference/cdc_tags.md)
and `cdc_datasets_by_tag()`:

``` r
# List common tags
cdc_tags()

# Find datasets with a specific tag
cdc_datasets_by_tag("mortality")

# Exact tag matching
cdc_datasets_by_tag("brfss", exact = TRUE)
```

## Querying Data

Once you’ve found a dataset, use
[`cdc_query()`](https://patrekieta.github.io/CDCdata/reference/cdc_query.md)
to fetch data. The function supports SoQL (Socrata Query Language) for
flexible filtering, sorting, and aggregation.

### Basic Queries

``` r
# Fetch first 100 rows from PLACES dataset
cdc_query("swc5-untb", limit = 100)

# Preview a dataset (shortcut for small samples)
cdc_preview("swc5-untb")
```

### Selecting Columns

Use the `select` parameter to return only specific columns:

``` r
cdc_query(
  "swc5-untb",
  select = c("stateabbr", "locationname", "access2_crudeprev"),
  limit = 50
)
```

### Filtering with WHERE

The `where` parameter accepts SoQL filter expressions:

``` r
# Filter by state
cdc_query(
  "swc5-untb",
  where = "stateabbr = 'MN'",
  limit = 100
)

# Multiple conditions
cdc_query(
  "swc5-untb",
  where = "stateabbr = 'MN' AND year = '2023'",
  limit = 100
)

# Numeric comparisons
cdc_query(
  "swc5-untb",
  where = "access2_crudeprev > 20",
  limit = 100
)

# List of values
cdc_query(
  "swc5-untb",
  where = "stateabbr IN ('MN', 'WI', 'IA')",
  limit = 100
)

# Text pattern matching
cdc_query(
  "swc5-untb",
  where = "locationname LIKE '%Minneapolis%'",
  limit = 100
)
```

### Sorting

Use the `order` parameter to sort results:

``` r
# Sort by prevalence (descending)
cdc_query(
  "swc5-untb",
  select = c("stateabbr", "locationname", "access2_crudeprev"),
  where = "year = '2023'",
  order = "access2_crudeprev DESC",
  limit = 20
)
```

### Aggregation

Combine `select` and `group` for aggregated queries:

``` r
# Count records by state
cdc_query(
  "swc5-untb",
  select = c("stateabbr", "count(*) as n"),
  group = "stateabbr",
  order = "n DESC"
)

# Average prevalence by state
cdc_query(
  "swc5-untb",
  select = c("stateabbr", "avg(access2_crudeprev) as mean_access"),
  where = "year = '2023'",
  group = "stateabbr",
  order = "mean_access DESC"
)
```

### Full-Text Search

Use the `q` parameter to search across all text fields:

``` r
cdc_query("swc5-untb", q = "diabetes prevention", limit = 50)
```

## Fetching Large Datasets

For datasets larger than 50,000 rows (the API limit per request), use
[`cdc_fetch()`](https://patrekieta.github.io/CDCdata/reference/cdc_fetch.md)
which handles pagination automatically:

``` r
# Fetch all Minnesota data (with progress indicator)
places_mn <- cdc_fetch(
  "swc5-untb",
  where = "stateabbr = 'MN'"
)

# Limit total rows
places_sample <- cdc_fetch(
  "swc5-untb",
  where = "year = '2023'",
  max_rows = 5000
)

# Adjust page size for performance
places_large <- cdc_fetch(
  "swc5-untb",
  where = "stateabbr = 'CA'",
  page_size = 10000
)
```

## CSV Format

By default, queries return JSON which preserves data types. For
potentially faster downloads of large flat datasets, use
`as_csv = TRUE`:

``` r
# JSON (default) - preserves types
data_json <- cdc_query("swc5-untb", limit = 1000)

# CSV - may be faster for large datasets
data_csv <- cdc_query("swc5-untb", limit = 1000, as_csv = TRUE)

# CSV with fetch
data_csv_large <- cdc_fetch(
  "swc5-untb",
  where = "stateabbr = 'TX'",
  as_csv = TRUE
)
```

Note that CSV converts all values to character strings, so you may need
to convert numeric columns after retrieval.

## Working with Metadata

### Dataset Metadata

Use
[`cdc_metadata()`](https://patrekieta.github.io/CDCdata/reference/cdc_metadata.md)
to get detailed information about a dataset:

``` r
meta <- cdc_metadata("swc5-untb")

# Dataset info
meta$name
meta$description
meta$rows
meta$tags

# Column information
meta$columns
```

### Quick Helpers

Several helper functions make common tasks easier:

``` r
# Get row count (useful before fetching large datasets)
cdc_count("swc5-untb")
cdc_count("swc5-untb", where = "stateabbr = 'MN'")

# List column names
cdc_columns("swc5-untb")

# Get distinct values for a column
cdc_distinct("swc5-untb", "stateabbr")
cdc_distinct("swc5-untb", "year")

# Open dataset in browser
cdc_browse("swc5-untb")
```

## Authentication

Anonymous API requests are limited to approximately 1,000 requests per
hour. For higher limits (~40,000/hour), register for a free app token at
[data.cdc.gov](https://data.cdc.gov/profile/edit/developer_settings).

``` r
# Set token for current session
cdc_app_token("your-app-token-here")

# Or set in .Renviron for persistence across sessions
# CDC_APP_TOKEN=your-app-token-here
```

## SoQL Quick Reference

SoQL (Socrata Query Language) is similar to SQL. Here’s a quick
reference:

### Comparison Operators

- `=`, `!=`, `<`, `>`, `<=`, `>=`
- `IS NULL`, `IS NOT NULL`

### Logical Operators

- `AND`, `OR`, `NOT`

### Text Functions

- `LIKE '%pattern%'` - wildcard matching
- `starts_with(column, 'prefix')`
- `contains(column, 'substring')`
- `upper(column)`, `lower(column)`

### Aggregation Functions

- `count(*)`, `count(column)`
- `sum(column)`, `avg(column)`
- `min(column)`, `max(column)`

### Date Functions

- `date_trunc_y(date_column)` - truncate to year
- `date_trunc_ym(date_column)` - truncate to month

## Common Datasets

Here are some popular CDC datasets to explore:

| ID          | Name           | Description                                    |
|-------------|----------------|------------------------------------------------|
| `swc5-untb` | PLACES         | Local health data at county/census tract level |
| `5hvh-ygtt` | BRFSS          | Behavioral Risk Factor Surveillance            |
| `9mfq-cb36` | COVID-19 Cases | Case surveillance public use data              |
| `bi63-dtpu` | NCHS Mortality | Multiple cause of death data                   |
| `n8mc-b4w4` | Vaccinations   | Vaccination coverage data                      |

Discover more at [data.cdc.gov](https://data.cdc.gov) or use
[`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md).

## Example Workflow

Here’s a complete example analyzing health access data:

``` r
library(cdcdata)

# 1. Find the dataset
cdc_datasets("PLACES health")

# 2. Check the metadata
meta <- cdc_metadata("swc5-untb")
print(meta$columns)

# 3. Check how much data we're dealing with
cdc_count("swc5-untb", where = "year = '2023' AND stateabbr = 'MN'")

# 4. Fetch the data
mn_health <- cdc_fetch(
  "swc5-untb",
  select = c("locationname", "access2_crudeprev", "checkup_crudeprev"),
  where = "year = '2023' AND stateabbr = 'MN'",
  order = "access2_crudeprev DESC"
)

# 5. Analyze
summary(mn_health$access2_crudeprev)
```

## Disclaimer

This is an independent, open-source project and is not affiliated with,
endorsed by, or representative of the Centers for Disease Control and
Prevention (CDC) or the U.S. Government. The author is a federal
contractor supporting the CDC but developed this package independently.
All data accessed through this package is publicly available via
[data.cdc.gov](https://data.cdc.gov).
