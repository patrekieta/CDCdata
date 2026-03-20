# Set and Get App token from CDC

Helper function for setting and getting your CDC App token for use
throughout the package. This is not strictyly necessary as data.cdc.gov
allows anonymous requests. App tokens are useful for security reasons
and to bypass the rate limits that are forced with anonymous API
requests.

## Usage

``` r
cdc_app_token(token = NULL, quiet = FALSE)

cdc_set_token(token)

cdc_get_token()
```

## Arguments

- token:

  App token from [data.cdc.gov](https://data.cdc.gov/). This should be a
  character string which gets attached to your system environment for
  security.

- quiet:

  Boolean. Whether to include console outputs when running function.

## Value

Character. The app token.

## Details

To receive your app token, you can go to <https://data.cdc.gov/signup>.
After setting up your account, you can go to the [developer
settings](https://data.cdc.gov/profile/edit/developer_settings) to
create a new app token.

## Examples

``` r
cdc_app_token()
#> ℹ No app token set. Anonymous requests have lower rate limits.
#> ℹ Get a token at <https://data.cdc.gov/signup>

cdc_app_token(token = "APP_TOKEN")
#> ✔ CDC app token set for this session.

cdc_set_token(token = "APP_TOKEN")
#> ✔ CDC app token set for this session.

cdc_get_token()
#> [1] "APP_TOKEN"
```
