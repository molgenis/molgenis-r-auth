---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# MolgenisAuth

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/molgenis/molgenis-r-auth.svg?branch=master)](https://travis-ci.org/molgenis/molgenis-r-auth)
[![CRAN status](https://www.r-pkg.org/badges/version/MolgenisAuth)](https://CRAN.R-project.org/package=MolgenisAuth)
[![codecov](https://codecov.io/gh/molgenis/molgenis-r-auth/branch/master/graph/badge.svg)](https://codecov.io/gh/molgenis/molgenis-r-auth)
<!-- badges: end -->

The goal of MolgenisAuth is to discover and authenticate against an OpenID
Connect server. We have tested it using [fusionauth](https://fusionauth.io/).

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
#> [1] "We're opening a browser so you can log in with code PB55N6"
credentials$id_token
#> [1] "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlcwbmltejhpYU9DLW16OXNaTVRiVzRfbFdMMCJ9.eyJhdWQiOiJiMzk2MjMzYi1jZGIyLTQ0OWUtYWM1Yy1hMGQyOGIzOGY3OTEiLCJleHAiOjE2MDQwODY5ODIsImlhdCI6MTYwNDA4MzM4MiwiaXNzIjoiaHR0cHM6Ly9hdXRoLm1vbGdlbmlzLm9yZyIsInN1YiI6ImQ4OTk1OTc2LWU4ZDgtNDM5MC04MzliLTAwN2EzODJmYzEyYiIsImp0aSI6ImVkNDAyYzg2LTYyYWUtNGM3Ny1iYTI2LWUxODdlNjlmMTc3MyIsImF1dGhlbnRpY2F0aW9uVHlwZSI6IlBBU1NXT1JEIiwiZW1haWwiOiJmLmtlbHBpbkB1bWNnLm5sIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJmMU5vSHdVc2JKbGRIUDdYcWdLb3pBIiwiYXBwbGljYXRpb25JZCI6ImIzOTYyMzNiLWNkYjItNDQ5ZS1hYzVjLWEwZDI4YjM4Zjc5MSIsInJvbGVzIjpbIlNVIl0sInBvbGljeSI6InJlYWR3cml0ZSJ9.alXoUguaB8j1Oj4n42KI7INfYC3Vit-8rgpdl2qm-6DB3A3afTomqLx_D4VEENaVEjeiGGpqTvxkVaBUKrYf09mgASF35vK1-fNWMKl2yKxy4JppBc916B9PVoacmNvZ7gez_LWXX_ZLKl4EzYd836_fwenW8RtfQbGsoIR9tRL-2c0cJOOz0lln9FlP4gG3JYf1Leq_hVA168qos7SuXWZiyk38eE-VvjcR2PxNf9hAZ8XraFiWvbEMfwaynhtfWTJBT74jY_tEuyiKQiFB-O76sr-gUWrMtsYQCLLrz_3R_txvF--suIr9AnEfRECvIgW8CjiSq-kGIFPO3Ogq3w"
```

## Support
We appreciate help, so do not be shy and file pull-requests for things that are
broken or file a bug report.
