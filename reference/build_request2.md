# Build a base request to the CDC API

Internal function to create an httr2 request object with common
configuration: headers, authentication, retry logic, and rate limiting.

## Usage

``` r
build_request2(endpoint, base_url = .cdc_base_url, format = "json")
```

## Arguments

- endpoint:

  Character. The API endpoint path.

- base_url:

  Character. The base URL (default: data.cdc.gov).

- format:

  Character. Response format: "json" or "csv".

## Value

An httr2 request object.
