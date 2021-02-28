library(testthat)
library(dplyr)
library(geosphere)

####  Example ships with same name and different id.
testdata <- data.frame(SHIPNAME = c("SHIP1","SHIP1","SHIP1","SHIP2","SHIP2","SHIP1",".SHIP1"),
                       SHIP_ID = c(1,1,1,2,2,3,1),
                       DATETIME = Sys.time() - 7200,
                       LON = -34.58314818145433,
                       LAT = -58.357619518450505,
                       stringsAsFactors = FALSE)

# Analyze data
result <- etl_appsilon_requirement(testdata)

testthat::test_that("Analysis must to group by SHIP_ID and not by SHIPNAME", {
  expect_that(result, is_a("data.frame"))
  expect_equal(nrow(result), 3) # We have 3 different SHIP_ID.
})


#### Example 3 observations between Buenos Aires - Montevideo (Distance 245,76 km).
testdata <- data.frame(SHIPNAME = "SHIP1",
                       SHIP_ID = 1,
                       DATETIME = c("2021-02-27 12:00:00",
                                    "2021-02-27 12:00:01",
                                    "2021-02-27 12:10:00",
                                    "2021-02-27 14:00:00"),
                       LAT = c(-34.577827898652885,
                               -34.577827898652885,
                               -34.57648324212437,
                               -34.934930200099174),
                       LON = c(-58.37163958455984,
                               -58.37163958455984,
                               -58.368577469322986,
                               -56.169396094665714),
                       stringsAsFactors = FALSE)

# Analyze data
result <- etl_appsilon_requirement(testdata)
testthat::test_that("Return the  longest distance between two consecutive observations. Must return in meters ", {
  expect_equal(nrow(result), 1) # We have only 1 different SHIP_ID.
  expect_identical(round(result[1,]$advanced_meters,0), 205050) # The expected distance between longest observation between Bs.As - Montevideo.
  expect_equal(as.integer(result[1,]$seconds_btw_obs), 6600) # The expected time in longest observations.
  expect_equal(round(result[1,]$speed_kmh, 0), 112) # Expected speed for longest observation.
})
