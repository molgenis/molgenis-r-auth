# CRAN Comments

## 0.0.14: Fourth attempt at initial submission

* Updated Authors in DESCRIPTION
* Fixed README.Rmd which was complaining about a missing title

## 0.0.13: Third attempt at initial submission

Added copyright holder

## 0.0.12: Second attempt at initial submission

The URLs in the DESCRIPTION were missing trailing `/`-es.
Fixed them.

## 0.0.11: Initial submission
### Test environments
* local OS X install, R 4.0.2
* Travis CI xenial
  * oldrel: R 3.6.3
  * release: R 4.0.2
  * devel: R Under development (unstable) (2020-10-29 r79387)
* win-builder (release)

### R CMD check results
There were no ERRORs and WARNINGs.
There was one NOTE:
```
Maintainer: ‘Fleur Kelpin <f.kelpin@umcg.nl>’
  
  New submission
```  
This is the first of three new submissions of our MOLGENIS Armadillo
DataSHIELD packages. This submission contains the authentication methods
that both other packages use to allow the user to authenticate.

### Reverse dependencies
There are currently no downstream dependencies for this package.
The other two packages, depending on this package, will be:
* DSMolgenisArmadillo
Used by researchers to perform federated statistical analysis on MOLGENIS
Armadillo DataSHIELD servers. It implements the DataSHIELD interface defined in https://CRAN.R-project.org/package=DSI
* MolgenisArmadillo
Used by data managers to manage datasets on MOLGENIS Armadillo
DataSHIELD servers.
