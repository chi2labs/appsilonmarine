Evaluation of Some Data-Related Issues
================
Aleksander Dietrichson, PhD
2/28/2021

## Purpose

The purpose of this document is to evaluate certain aspects related to
when, how and where in the code data is accessed in the Appsilon Marine
application.

## Location of Data

The github repository contains a folder called “raw\_data”, which
contains the zip-file from he specifications. This needs to be unzipped
in the same directory.

``` r
raw_data_path <- here::here("raw_data","ships.csv")

if(!file.exists(raw_data_path)){
  #Unzip
  utils::unzip(here::here("raw_data","ships_data.zip"),exdir=here::here("raw_data"))
}
```

## Performance considerations

### Initial latency

Initial latency refers to the initial time it takes to load/connect to
the data. Our main options are:

  - Load from CSV with readr or data.table
  - Save and load raw data as uncompressed RDS
  - Use a DB back-end (e.g. sqlite)
  - Pre-Calculate summary values and save as RDS

#### Load from CSV

We are measuring the load times on laptop, which is significantly faster
than the standard setup on shinyapps.io, however, for comparative
purposes, and in the interest of time, we will use this as our baseline.

``` r
system.time(
  df_csv_with_readr <- readr::read_csv(raw_data_path, col_types = cols())
)
```

    ##    user  system elapsed 
    ##  10.448   0.236  10.683

This approach will clearly add significant latency.

#### Load from CSV with data.table

``` r
system.time(
  df_csv_with_data_table <- data.table::fread(raw_data_path)
)
```

    ##    user  system elapsed 
    ##   9.770   0.292   3.277

Significantly faster in terms of “elapsed”, however, we know that the
package takes advantage of underlying multithreaded code, which may not
be available on a standard shinyapps.io Linux box.

#### Save as RDS and retrieve

``` r
tempfile1 <- tempfile()
tempfile2 <- tempfile()
readr::write_rds(df_csv_with_readr,file = tempfile1)
readr::write_rds(df_csv_with_data_table,file = tempfile2)

system.time(readr::read_rds(tempfile1))
```

    ##    user  system elapsed 
    ##   4.341   0.232   4.573

``` r
system.time(readr::read_rds(tempfile2))
```

    ##    user  system elapsed 
    ##   5.084   0.168   5.252

Reading raw-data from an RDS cuts initial latency in half.

#### Use DB back-end

For this test we are assuming sqlite, since it is single file, and
easily deployed to shipnyapps.io. There are two caveats using sqlite:

  - There is no native DATETIME datatype (which means we will need to
    deal this this programatically)
  - Column names are not natively case-sensitive

<!-- end list -->

``` r
tempfile3 <- tempfile(fileext = ".sqlite")

system.time({
  library(RSQLite, quietly = TRUE)
  library(DBI)
})
```

    ## Warning: package 'RSQLite' was built under R version 3.5.3

    ## Warning: package 'DBI' was built under R version 3.5.3

    ##    user  system elapsed 
    ##   0.106   0.000   0.107

``` r
con <- dbConnect(RSQLite::SQLite(),tempfile3)

dbWriteTable(con, "ships", df_csv_with_readr %>% 
               rename(port2 = port) #To avoid duplicate column names
)
system.time(
  con <- dbConnect(RSQLite::SQLite(),tempfile3)
)
```

    ##    user  system elapsed 
    ##   0.018   0.000   0.018

This approach leads essentially to zero-latency. However, two packages
(DBI and RSQLite) need to be loaded, which add back some latency.

#### Pre-Calculated RDS

``` r
system.time(
  df_pre_calculated <- readr::read_rds(system.file("data/ships.RDS", package="appsilonmarine"))
)
```

    ##    user  system elapsed 
    ##   0.004   0.000   0.005

Again, near zero latency, and no additional packages to load.

### Discussion

For the purposes of this exercise we will use the *pre-calculation*
approach. We recognize that this may not be ideal solution for a
production environment, since we will surely be dealing with new
incoming data on a continuous basis. However, this will surely
necessitate a data-base back-end, and a pipeline for data-cleansing,
both of which are beyond the scope of the current requirement.

### Memory management

``` r
format(object.size(df_csv_with_readr), units = "Mb")
```

    ## [1] "615.6 Mb"

``` r
format(object.size(df_csv_with_data_table), units = "Mb")
```

    ## [1] "428.7 Mb"

``` r
format(object.size(df_pre_calculated), units = "Mb")
```

    ## [1] "0.6 Mb"

Again, data.table is somewhat more efficient than the tibble (this is
likely due to their intelligent use of pointers), but the precalculated
data, not surprisingly, takes up a small fraction of the RAM occupied by
the alternative data-structures. At any rate, all of the numbers
reported are small enough so as not to cause any concern of the
application running out of resources, even with the smallest available
shipnyapps.io setup.

### Speed of calculations

We will deal with the actual speed of calculations in the post-hoc
analysis.
