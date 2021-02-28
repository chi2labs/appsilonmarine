#' ETL for Appsilon requirement
#'
#' Objective:
#' Return one observation by each ship filtering by:
#' - The longest distance between two consecutive observations.(In meters).
#'
#' and including:
#' - The previous and current coord.
#' - The time between the both observations (in seconds).
#'
#' @param ships_data Data.frame with columns (SHIPNAME, DATETIME, LON,LAT)
#' @return data.frame
#' @import dplyr
#' @import geosphere
#' @export
etl_appsilon_requirement <- function(ships_data) {

  data <- ships_data %>%
    group_by(SHIP_ID) %>%
    arrange(DATETIME, .by_group = TRUE) %>% mutate(prev_lon = lag(LON, default = NA),
                                                   SHIPNAME = first(SHIPNAME), # We found SHIPS with same ID and different name.
                                                   prev_lat = lag(LAT, default = NA),
                                                   prev_datetime = lag(DATETIME, default = NA),
                                                   seconds_btw_obs = difftime(DATETIME, prev_datetime, units = "secs")) %>%
    rowwise() %>%
    mutate(advanced_meters = ifelse(!is.na(prev_lat),
                                    round(first(distm(c(prev_lon, prev_lat),
                                                      c(LON, LAT),
                                                      fun=distHaversine),
                                    ), 2),
                                    0)) %>%
    ungroup() %>%
    arrange(SHIP_ID, DATETIME)

  data %>% arrange(desc(advanced_meters), prev_datetime) %>%
    group_by(SHIP_ID, SHIPNAME) %>%
    slice(1) %>%
    mutate(speed_kmh = advanced_meters / (as.integer(seconds_btw_obs) / 3.6))
}
