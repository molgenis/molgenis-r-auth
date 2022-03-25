# CRAN Comments

## 0.0.21: Fix authors
* Fix order of authors

## 0.0.20: Fix maintainer
* Add Mariska to authors

## 0.0.19: Change maintainer
* Make Mariska maintainer

## 0.0.18: Remove LazyData is true
* Remove LazyData is true. There is no data directory to load.

## 0.0.17: Fix codecov links
* Remove redirect from codecov badge link

## 0.0.16: Fix travis links
* Remove redirect from travis badge link

## 0.0.15: Change maintainer
* Make Sido maintainer
* Fix travis badge location

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
