
# MolgenisAuth

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/molgenis/molgenis-r-auth.svg?branch=master)](https://travis-ci.org/molgenis/molgenis-r-auth)
[![CRAN status](https://www.r-pkg.org/badges/version/MolgenisAuth)](https://CRAN.R-project.org/package=MolgenisAuth)
[![codecov](https://codecov.io/gh/molgenis/molgenis-r-auth/branch/master/graph/badge.svg)](https://codecov.io/gh/molgenis/molgenis-r-auth)
<!-- badges: end -->

The goal of MolgenisAuth is to discover and authenticate against an OpenID
Connect server. We have tested it using [Fusion Auth](https://fusionauth.io/).

## Installation

You can install the released version of MolgenisAuth from [CRAN](https://CRAN.R-project.org) with:


```r
install.packages("MolgenisAuth")
```

And the development version from [GitHub](https://github.com/) with:


```r
# install.packages("devtools")
devtools::install_github("molgenis/molgenis-r-auth")
```
## Usage

To discover endpoint URLs on an OpenID Connect authentication server:


```r
library(MolgenisAuth)
endpoint <- discover("https://auth.molgenis.org")
endpoint
#> <oauth_endpoint>
#>  authorize: https://auth.molgenis.org/oauth2/authorize
#>  access:    https://auth.molgenis.org/oauth2/token
#>  user:      https://auth.molgenis.org/oauth2/userinfo
#>  device:    https://auth.molgenis.org/oauth2/device_authorize
#>  logout:    https://auth.molgenis.org/oauth2/logout
```

Using this endpoint, you can then authenticate using the device flow.
This will open a browser window so you can authenticate with the
authentication server.

```r
credentials <- device_flow_auth(endpoint, "b396233b-cdb2-449e-ac5c-a0d28b38f791")
#> [1] "We're opening a browser so you can log in with code LPRPRL"
credentials$id_token
#> [1] "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlcwbmltejhpYU9DLW16OXNaTVRiVzRfbFdMMCJ9.eyJhdWQiOiJiMzk2MjMzYi1jZGIyLTQ0OWUtYWM1Yy1hMGQyOGIzOGY3OTEiLCJleHAiOjE2MDQxNjY1ODAsImlhdCI6MTYwNDE2Mjk4MCwiaXNzIjoiaHR0cHM6Ly9hdXRoLm1vbGdlbmlzLm9yZyIsInN1YiI6ImQ4OTk1OTc2LWU4ZDgtNDM5MC04MzliLTAwN2EzODJmYzEyYiIsImp0aSI6ImYwNGZhMWU0LWU0MGItNGUwMS1iZGU3LWE0MjRmZWVjMmUyNSIsImF1dGhlbnRpY2F0aW9uVHlwZSI6IlBBU1NXT1JEIiwiZW1haWwiOiJmLmtlbHBpbkB1bWNnLm5sIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJSU1cxOWJSenhXYm1naUp0cXoyOWtRIiwiYXBwbGljYXRpb25JZCI6ImIzOTYyMzNiLWNkYjItNDQ5ZS1hYzVjLWEwZDI4YjM4Zjc5MSIsInJvbGVzIjpbIlNVIl0sInBvbGljeSI6InJlYWR3cml0ZSJ9.NRuQVi1x9uYEOoQUfzDIXkICrFVNcZi0N9p7oHG45x1__FZa9B_udMCJQLcoIrZobgvhw1U0F2aGJ5UGYt2rckNjrs6vafDExJLfwvh_IKaCPL8D78eNRch4-5ss7wBGD_ho_htdT3jaSJgjzeptj46p678vvOSADCr7ZL2-72E4GTd2EItGp_6soaJztOUVKlrs01tl_uhiLKapCOnn32FzocjqKZtZIxwjwu_qTiZSwWo_f1n2gURAX7N4mzNPCUNdl22Ry2KMJkWJhtQN2w9_oAXe-l70LaavYqTfEzoQTfG14u4t2LEDt_CKn5qLG1i4dS7yYI_dPIQKUUlXEA"
```

## Support
We appreciate help, so do not be shy and file pull-requests for things that are
broken or file a bug report.
