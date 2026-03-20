# Package index

## Authenticate

Create and access your CDC API app token.

- [`cdc_app_token()`](https://patrekieta.github.io/CDCdata/reference/cdc_app_token.md)
  [`cdc_set_token()`](https://patrekieta.github.io/CDCdata/reference/cdc_app_token.md)
  [`cdc_get_token()`](https://patrekieta.github.io/CDCdata/reference/cdc_app_token.md)
  : Set and Get App token from CDC

## Metadata

Access and search for metadata from various datasets.

- [`cdc_datasets()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets.md)
  : Search CDC Datasets
- [`cdc_metadata()`](https://patrekieta.github.io/CDCdata/reference/cdc_metadata.md)
  : Get Dataset Metadata
- [`cdc_categories()`](https://patrekieta.github.io/CDCdata/reference/cdc_categories.md)
  : List Available Categories
- [`cdc_datasets_category()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets_category.md)
  : Search Datasets by Category
- [`cdc_tags()`](https://patrekieta.github.io/CDCdata/reference/cdc_tags.md)
  : List Available Tags
- [`cdc_datasets_tag()`](https://patrekieta.github.io/CDCdata/reference/cdc_datasets_tag.md)
  : Search Datasets by Tag
- [`cdc_browse()`](https://patrekieta.github.io/CDCdata/reference/cdc_browse.md)
  : Open Dataset in Browser

## Query

Perform queries to access data.

- [`cdc_query()`](https://patrekieta.github.io/CDCdata/reference/cdc_query.md)
  : Query a CDC Dataset
- [`cdc_fetch()`](https://patrekieta.github.io/CDCdata/reference/cdc_fetch.md)
  : Fetch Large CDC Datasets with Pagination

## Requests

Build and perform httr2 requests

- [`build_request()`](https://patrekieta.github.io/CDCdata/reference/build_request.md)
  : Build a base request to the CDC API
- [`build_request2()`](https://patrekieta.github.io/CDCdata/reference/build_request2.md)
  : Build a base request to the CDC API
- [`perform_request()`](https://patrekieta.github.io/CDCdata/reference/perform_request.md)
  : Perform API request and parse response

## Helpers

Helper functions to view datasets and generate metadata

- [`cdc_count()`](https://patrekieta.github.io/CDCdata/reference/cdc_count.md)
  : Get Row Count for a Dataset
- [`cdc_columns()`](https://patrekieta.github.io/CDCdata/reference/cdc_columns.md)
  : Get Column Names for a Dataset
- [`cdc_distinct()`](https://patrekieta.github.io/CDCdata/reference/cdc_distinct.md)
  : Get Distinct Values for a Column
- [`cdc_preview()`](https://patrekieta.github.io/CDCdata/reference/cdc_preview.md)
  : Preview Dataset Sample
