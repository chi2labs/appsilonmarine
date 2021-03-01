appsilonmarine
================

## Description

This package contain a Shiny application to visualize the marine
datasets for Appsilon company.

The code is structured under the Golem Framework specifications.

## Credits

This package is developed and mantained by the
<a href="https://www.chi2labs.com/">Chi2Labs</a> team.

## Installation

You can install from github with:

``` r
devtools::install_github("chi2labs/appsilonmarine")
```

## Run Marine app

``` r
appsilonmarine::run_app()
```

## Test and Check

Running unit-testing and package check is done in the traditional way

### From Rstudio

  - Ctrl + Shift + T and
  - Ctrl + Shift + E

respectively.

### From command line

  - devtools::test()
  - R CMD check

## R & D Documentation

Some of the research and rationale for decisions made are documented in
these three documents:

  - [Initial Look at the Raw
    Data](https://github.com/chi2labs/appsilonmarine/blob/master/dev_docs/data_initial_look.md)
  - [Evaluation of Some Data-Related
    Issues](https://github.com/chi2labs/appsilonmarine/blob/master/dev_docs/data_considerations.md)
  - [Post-hoc Analysis of Pre-Calculated
    Data](https://github.com/chi2labs/appsilonmarine/blob/master/dev_docs/post_hoc_analysis.md)

These are available in the *dev\_doc* folder at the root level, along
with the corresponding .Rmd files for reproducibility.

## Caveat

All distance calculations were made using the
[geosphere](https://cran.r-project.org/package=geosphere) package. We
have not independenlty verified the accuracy of these calculations.
