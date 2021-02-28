#' marine UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @importFrom shiny NS tagList
#' @import dplyr
#' @import leaflet
#' @import shiny
#' @import DT
#' @import shiny.semantic
#' @author Pablo Pagnone
#' @export
mod_marine_ui <- function(id){
  ns <- NS(id)
  semanticPage(
    tags$head(
      tags$link(rel = "stylesheet", href = "css/styles.css")
    ),
    title = "Appsilon Marine",
    # Defining grid
    grid(
      id = "marine_grid",
      grid_template = grid_template(
        default = list(
          areas = rbind(
            c("title", "map"),
            c("dropdowns", "map")
          ),
          cols_width = c("400px", "1fr"),
          rows_height = c("50px", "auto")
        ),
        mobile = list(
          areas = rbind(
            "title",
            "map",
            "dropdowns"
          ),
          rows_height = c("70px", "400px", "auto"),
          cols_width = c("100%")
        )
      ),
      area_styles = list(title = "margin: 20px;",
                         dropdowns = "margin: 20px;",
                         map = ""),

      # Defining UI for each grid element
      title = h2(class = "ui header",
                 icon("ship"),
                 div(class = "content", "Appsilon Marine")),
      dropdowns = mod_dropdown_ui(id = ns("dropdown_ui_1")),
      map = div(leaflet::leafletOutput(ns("map"), width = "auto"),
                DT::dataTableOutput(ns("shipstable"), width = "auto")
                ),
    ),
  )
}

#' marine Server Function
#' @param id,input,output,session Internal parameters for {shiny}.
#' @param ships - Data.frame with ships information
#' @import dplyr
#' @import leaflet
#' @import shiny
#' @import DT
#' @import shiny.semantic
#' @import readr
#' @import geosphere
#' @author Pablo Pagnone
#' @export
mod_marine_server <- function(input, output, session, ships){

  dropdowns_mod <- callModule(mod_dropdown_server, "dropdown_ui_1", ships = ships)

  getData <- reactive({
    data <- ships
    if(dropdowns_mod$vessel_type != "All") {
      data <- data %>% filter(ship_type == dropdowns_mod$vessel_type)
    }
    if(dropdowns_mod$vessel_id != "All") {
      data <- data %>% filter(SHIP_ID == dropdowns_mod$vessel_id)
    }

    data
  })

  output$shipstable <- DT::renderDataTable(
    getData() %>% select(SHIP_ID, SHIPNAME, DATETIME, LAT, LON, prev_datetime, prev_lat, prev_lon, advanced_meters, seconds_btw_obs),
    options = list(scrollX = TRUE),
    selection = "none",
    rownames = FALSE
  )

  output$map <- leaflet::renderLeaflet({
    data <- getData()
    validate(need(nrow(data) > 0, "Doesn't exist observations for this ship."))
    ship_position_map(data,
                      show_previous_position = ifelse(dropdowns_mod$vessel_id != "All", TRUE, FALSE))
  })

}

## To be copied in the UI
# mod_marine_ui("marine_ui_1")

## To be copied in the server
# callModule(mod_marine_server, "marine_ui_1")

