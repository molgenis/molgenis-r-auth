---
title: "MolgenisAuth"
date: "2020-10-31"
output: 
  github_document
---

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
#> [1] "We're opening a browser so you can log in with code GNLYRS"
credentials$id_token
#> [1] "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlcwbmltejhpYU9DLW16OXNaTVRiVzRfbFdMMCJ9.eyJhdWQiOiJiMzk2MjMzYi1jZGIyLTQ0OWUtYWM1Yy1hMGQyOGIzOGY3OTEiLCJleHAiOjE2MDQxNjgwODMsImlhdCI6MTYwNDE2NDQ4MywiaXNzIjoiaHR0cHM6Ly9hdXRoLm1vbGdlbmlzLm9yZyIsInN1YiI6ImQ4OTk1OTc2LWU4ZDgtNDM5MC04MzliLTAwN2EzODJmYzEyYiIsImp0aSI6IjI2ODZlYzhhLWY5YTctNDc3Ni1hODdhLTU4NDY3ZGZmZDUzYiIsImF1dGhlbnRpY2F0aW9uVHlwZSI6IlBBU1NXT1JEIiwiZW1haWwiOiJmLmtlbHBpbkB1bWNnLm5sIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJieGRfRjE2OElhWlRfajZzQ1BNV2xnIiwiYXBwbGljYXRpb25JZCI6ImIzOTYyMzNiLWNkYjItNDQ5ZS1hYzVjLWEwZDI4YjM4Zjc5MSIsInJvbGVzIjpbIlNVIl0sInBvbGljeSI6InJlYWR3cml0ZSJ9.b11vq77fEc7GEA57dxNv2XhelcfHjDgGHrH5v7SiSlWdEdQjZwQzL8MBUjBvRuLzKNOrG02mxMr2sXYb_WqT_6qzz8InaGR5sR5KarA7OZnrkfHn6jPHtQ_fm9eXd4OVHNGoAVh9sUtVSNYF9qa7BGw4DYPiTYihUM4Jk0GWxqhxB0_RbxAQ7ipA0v4RNXeo1Z1a2S9HTLvi07af7_p80NZFE999LId86QC5r49_8osuMoCHLSNrwQw18zI4L_UpTgtZhiyONm_r5f5uvJqBqHC8TbZl8L7k8LFiqdkTgnQZDJNcJ7r6dgQnwAbdvy_mar0xd_en5noA6ve-9t3zUA"
```

## Support
We appreciate help, so do not be shy and file pull-requests for things that are
broken or file a bug report.
