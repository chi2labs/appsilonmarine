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
#' @param ships_data Data.frame with columns (SHIPNAME, DATETIME, LON, LAT)
#' @return data.frame
#' @import dplyr
#' @importFrom geosphere distm distHaversine
#' @importFrom rlang .data
#' @export
etl_appsilon_requirement <- function(ships_data) {

  data <- ships_data %>%
    group_by(.data$SHIPNAME) %>%
    arrange(.data$DATETIME, .by_group = TRUE) %>% mutate(prev_lon = lag(.data$LON, default = NA),
                                                   SHIPNAME = first(.data$SHIPNAME), # We found SHIPS with same ID and different name.
                                                   prev_lat = lag(.data$LAT, default = NA),
                                                   prev_datetime = lag(.data$DATETIME, default = NA),
                                                   seconds_btw_obs = difftime(.data$DATETIME, .data$prev_datetime, units = "secs")) %>%
    rowwise() %>%
    mutate(advanced_meters = ifelse(!is.na(.data$prev_lat),
                                    round(first(distm(c(.data$prev_lon, .data$prev_lat),
                                                      c(.data$LON, .data$LAT),
                                                      fun=distHaversine),
                                    ), 2),
                                    0)) %>%
    ungroup() %>%
    arrange(.data$SHIPNAME, .data$DATETIME)

  data %>% arrange(desc(.data$advanced_meters), .data$prev_datetime) %>%
    group_by( .data$SHIPNAME ) %>%
    slice(1) %>%
    mutate(speed_kmh = .data$advanced_meters / (as.integer(.data$seconds_btw_obs) / 3.6))
}
