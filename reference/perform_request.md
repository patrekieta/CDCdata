# Perform API request and parse response

Perform API request and parse response

## Usage

``` r
perform_request(req, as = "dataframe", format = "json")
```

## Arguments

- req:

  An httr2 request object.

- as:

  Character. Output format: "dataframe", "list", or "raw".

- format:

  Character. Response format: "json" or "csv".

## Value

Parsed response in requested format.
