# CDCdata

`CDCdata` provides a modern R interface to the CDC's open data portal ([data.cdc.gov](https://data.cdc.gov)), which runs on the Socrata platform. Built on `httr2`, it offers:

- **Dataset discovery** - Search and browse available CDC datasets
- **Flexible querying** - Full SoQL ([Socrata Query Language](https://dev.socrata.com/docs/queries/)) support
- **Automatic pagination** - Fetch large datasets with progress indicators
- **Rate limiting** - Built-in throttling to respect API limits
- **Authentication** - Optional app tokens for higher rate limits

## Installation

```r
devtools::install_github("https://github.com/patrekieta/CDCdata")
```

## Authentication

Anonymous requests are limited to ~1,000/hour. Register for an app token at [data.cdc.gov](https://data.cdc.gov/signup) to increase rate limits.

```r
# Set for current session
cdc_app_token("your-token-here")
```


## Quick Start

```r
library(CDCdata)

# Set for current session
cdc_app_token("your-token-here")

# Search for datasets
cdc_datasets("PLACES")

# Preview a dataset
cdc_preview("swc5-untb")  # PLACES: Local Data for Better Health

# Query with filters
cdc_query(
  "swc5-untb",
  select = c("stateabbr", "locationname", "data_value"),
  where = "stateabbr = 'MN' AND year = '2023'"
)

# Fetch large datasets with pagination
places_mn <- cdc_fetch(
  "swc5-untb",
  where = "stateabbr = 'MN'"
)

```

## Popular CDC Datasets

| ID | Name | Description |
|----|------|-------------|
| `swc5-untb` | PLACES | Local health data at county/census tract level |
| `eav2-2dfu` | BRFSS | Behavioral Risk Factor Surveillance |
| `9mfq-cb36` | COVID-19 Cases | Case surveillance data |
| `bi63-dtpu` | Mortality | Multiple cause of death data |
| `n8mc-b4w4` | Vaccinations | Vaccination coverage data |

Find more at [data.cdc.gov](https://data.cdc.gov) or use `cdc_datasets()`.

> **Disclaimer**: This is an independent, open-source project and is not affiliated with, endorsed by, or representative of the Centers for Disease Control and Prevention (CDC) or the U.S. Government. The original author is a federal contractor supporting CDC but developed this package independently. All data accessed through this package is publicly available via [data.cdc.gov](https://data.cdc.gov).


