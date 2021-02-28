library(testthat)
library(dplyr)
library(geosphere)
library(leaflet)
library(vdiffr)
# Run vdiffr::manage_cases() to create template figures.

#### Example 3 observations between Buenos Aires - Montevideo (Distance 205 km).
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
plot_map <- ship_position_map(result, TRUE)

testthat::test_that("Return the  longest distance between two consecutive observations. Must return in meters ", {
  expect_that(plot_map, is_a("leaflet"))
  expect_doppelganger("bsasmontevideo", plot_map)
})
