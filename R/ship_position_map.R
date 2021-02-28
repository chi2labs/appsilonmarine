#' Map to show the ships position
#'
#' @param data Ships data.frame
#' @param show_previous_position IF is true the map will show the previous place too.
#' @import dplyr
#' @import leaflet
#' @importFrom htmltools HTML
#' @importFrom rlang .data
#' @return leaflet plot
#' @export
ship_position_map <- function(data, show_previous_position = FALSE){

  # Labels for each ship in map.
  data$labels <- sprintf(
    "<strong>%s</strong> <br />Distance Sailed (meters): %s",
    data$SHIPNAME, data$advanced_meters
  ) %>% lapply(HTML)

  data$labels_prev <- sprintf(
    "<strong>%s</strong> <br />Previous position",
    data$SHIPNAME
  ) %>% lapply(HTML)

  mapplot <- leaflet(data = data) %>%
    addTiles() %>%
    addMarkers(lng = ~LON,
               lat = ~LAT,
               icon = icons(
                 iconUrl = system.file("app/www/images/ship.png", package="appsilonmarine"),
                 iconWidth = 38,
                 iconHeight = 38
               ),
               popup = ~as.character(SHIPNAME),
               label = ~labels)

  if(show_previous_position) {
    mapplot <- mapplot %>% addMarkers(lng = ~prev_lon,
                                      lat = ~prev_lat,
                                      icon = icons(
                                        iconUrl = system.file("app/www/images/star.png", package="appsilonmarine"),
                                        iconWidth = 38,
                                        iconHeight = 38
                                      ),
                                      label = ~labels_prev,
    )
  }

  mapplot
}
