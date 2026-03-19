# Package-level constants
.cdc_base_url <- "https://data.cdc.gov"
.cdc_api_path <- "/api/views"
.cdc_resource_path <- "/resource"

# Default configuration
.cdc_defaults <- list(

  page_size = 1000,
  max_retries = 3,

  rate_limit = 10
)

# NULL check and replacement
`%||%` <- function(x, y){
  if(is.null(x)){
    y
  } else{
    x
  }
}
