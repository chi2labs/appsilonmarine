#' marine UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import dplyr
#' @import leaflet
#' @import shiny
#' @import DT
#' @import shiny.semantic
#' @author Pablo Pagnone
mod_marine_ui <- function(id){
  ns <- NS(id)
  semanticPage(
    div(class = "ui raised segment",
        div(
          h1("Ships")
        ),
        div(
          mod_dropdown_ui(ns("dropdown_ui_1"))
        ),
        div(
          h2("Map"),
          leaflet::leafletOutput(ns("map"))
        ),
        div(
          DT::dataTableOutput(ns("shipstable"))
        )
    )
  )
}

#' marine Server Function
#' @param id,input,output,session Internal parameters for {shiny}.
#' @param ships - Data.frame with ships information
#' @noRd
#' @import dplyr
#' @import leaflet
#' @import shiny
#' @import DT
#' @import shiny.semantic
#' @import readr
#' @import geosphere
#' @author Pablo Pagnone
mod_marine_server <- function(input, output, session, ships){

  dropdowns_mod <- callModule(mod_dropdown_server, "dropdown_ui_1", ships = ships)

  getData <- reactive({
    data <- ships
    if(dropdowns_mod$vessel_type != "All") {
      data <- data %>% filter(ship_type == dropdowns_mod$vessel_type)
    }
    if(dropdowns_mod$vessel_name != "All") {
      data <- data %>% filter(SHIPNAME == dropdowns_mod$vessel_name)
    }
    data
  })

  output$shipstable <- DT::renderDataTable(
    getData(),
    options = list(scrollX = TRUE)
  )

  output$map <- leaflet::renderLeaflet({

    data <- getData()
    # Labels for each ship in map.
    data$labels <- sprintf(
      "<strong>%s</strong> <br />Distance Sailed (meters): %s",
      data$SHIPNAME,round(data$distance_sailed, 2)
    ) %>% lapply(htmltools::HTML)

    leaflet(data = data) %>%
      addTiles() %>%
      addCircleMarkers(lng = ~LON,
                       lat = ~LAT,
                       popup = ~as.character(SHIPNAME),
                       label = ~labels,
                       radius = 5,
                       stroke = FALSE,
                       fillOpacity = 1,
                       color = "red"
      )
  })

}

## To be copied in the UI
# mod_marine_ui("marine_ui_1")

## To be copied in the server
# callModule(mod_marine_server, "marine_ui_1")

