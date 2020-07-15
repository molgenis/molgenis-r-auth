[![Build Status](https://jenkins.dev.molgenis.org/buildStatus/icon?job=molgenis%2Fmolgenis-r-auth%2Fmaster)](https://jenkins.dev.molgenis.org/job/molgenis/job/molgenis-r-auth/job/master/)
[![codecov](https://codecov.io/gh/molgenis/molgenis-r-auth/branch/master/graph/badge.svg)](https://codecov.io/gh/molgenis/molgenis-r-auth)

# Molgenis R Authentication library
This library can be used to discover and authenticate against an OpenID server. We have tested it using [fusionauth](https://fusionauth.io/).

## Installation
You can install the package using the following code.

```{r}
install.packages("MolgenisAuth", repos = "https://registry.molgenis.org", dependencies = TRUE)
```

## Usage
You can use 2 endpoints
- `discover`
  
  Is a discovery endpoint which should serve and issuer URL and a client ID
  
- `device_flow_auth`

  At this moment we support only the `device_flow`, Which means authentication using a code, which in return resolves a JWT token.
  
You can run these commands using the following examples:

```{r, eval = FALSE}
# request endpoint
endpoint <- discover("https://auth.molgenis.org")

# request JWT token
device_flow_auth(endpoint, "b396233b-cdb2-449e-ac5c-a0d28b38f791")
```

## Support
We appreciate help, so do not be shy and file pull-requests on things that are broken or file a bug report.
