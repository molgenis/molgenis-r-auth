MolgenisAuth
================
2020-10-31

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/molgenis/molgenis-r-auth.svg?branch=master)](https://travis-ci.org/molgenis/molgenis-r-auth)
[![CRAN
status](https://www.r-pkg.org/badges/version/MolgenisAuth)](https://CRAN.R-project.org/package=MolgenisAuth)
[![codecov](https://codecov.io/gh/molgenis/molgenis-r-auth/branch/master/graph/badge.svg)](https://codecov.io/gh/molgenis/molgenis-r-auth)
<!-- badges: end -->

The goal of MolgenisAuth is to discover and authenticate against an
OpenID Connect server. We have tested it using [Fusion
Auth](https://fusionauth.io/).

Installation
------------

You can install the released version of MolgenisAuth from
[CRAN](https://CRAN.R-project.org) with:

    install.packages("MolgenisAuth")

And the development version from [GitHub](https://github.com/) with:

    # install.packages("devtools")
    devtools::install_github("molgenis/molgenis-r-auth")

Usage
-----

To discover endpoint URLs on an OpenID Connect authentication server:

    library(MolgenisAuth)
    endpoint <- discover("https://auth.molgenis.org")
    endpoint
    #> <oauth_endpoint>
    #>  authorize: https://auth.molgenis.org/oauth2/authorize
    #>  access:    https://auth.molgenis.org/oauth2/token
    #>  user:      https://auth.molgenis.org/oauth2/userinfo
    #>  device:    https://auth.molgenis.org/oauth2/device_authorize
    #>  logout:    https://auth.molgenis.org/oauth2/logout

Using this endpoint, you can then authenticate using the device flow.
This will open a browser window so you can authenticate with the
authentication server.

    credentials <- device_flow_auth(endpoint, "b396233b-cdb2-449e-ac5c-a0d28b38f791")
    credentials$id_token
    #> [1] "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlcwbmltejhpYU9DLW16OXNaTVRiVzRfbFdMMCJ9.eyJhdWQiOiJiMzk2MjMzYi1jZGIyLTQ0OWUtYWM1Yy1hMGQyOGIzOGY3OTEiLCJleHAiOjE2MDQxNjg5MDksImlhdCI6MTYwNDE2NTMwOSwiaXNzIjoiaHR0cHM6Ly9hdXRoLm1vbGdlbmlzLm9yZyIsInN1YiI6ImQ4OTk1OTc2LWU4ZDgtNDM5MC04MzliLTAwN2EzODJmYzEyYiIsImp0aSI6IjcwMjQ4M2VkLTY1ZjYtNDhiNy04ZDU2LTZmNDMzN2FlOTA3ZiIsImF1dGhlbnRpY2F0aW9uVHlwZSI6IlBBU1NXT1JEIiwiZW1haWwiOiJmLmtlbHBpbkB1bWNnLm5sIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJOV0pFQzZNNjAyRUpWQ0h0eHcxbGR3IiwiYXBwbGljYXRpb25JZCI6ImIzOTYyMzNiLWNkYjItNDQ5ZS1hYzVjLWEwZDI4YjM4Zjc5MSIsInJvbGVzIjpbIlNVIl0sInBvbGljeSI6InJlYWR3cml0ZSJ9.fJyj1hBx90HVKuCf5dGmfiRsnPo7gozj2xoZnJUmZbBLpuQnG5hdvMXhcTcgh6kJUy0ozw_tsSdOAivHxxREnN42UnVqNLj5s9cUk9-E75FgfZQnyWkHcosdlOgiw7vD5bLGq4Ma8VZTh98w8UsjTM1zhXJRdKWSZj9YH_qtmXkM4x-JW-IMeWVJQ7UOgXr_lcSUQFEMkwdkJcgQdZCxqQ4aonyKol3LMTnj_nc1XM0Hc1Um1ihD85h4NQ4XEDlP_z261xu7jAxgIpEaD5Rh6_2aWpfaNH8fSk-wDzZf69f_Vc44f5hkFrXeX6q-1FqJuxl5moJIc_QurGvtPdI9vg"

Support
-------

We appreciate help, so do not be shy and file pull-requests for things
that are broken or file a bug report.
