#' Marine UI Function
#'
#' @description Marine UI Module, show dropdowns to select a vessel and show in
#' a map.
#'
#' @param id Internal parameters for {shiny}.
#' @importFrom shiny NS div
#' @importFrom leaflet leafletOutput
#' @importFrom DT dataTableOutput
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

#' Marine Server Function
#' @param input Internal parameters for {shiny}.
#' @param output Internal parameters for {shiny}.
#' @param session Internal parameters for {shiny}.
#' @param ships - Data.frame with ships information
#' @import dplyr
#' @import leaflet
#' @importFrom shiny validate reactive callModule
#' @importFrom DT renderDataTable
#' @import shiny.semantic
#' @importFrom rlang .data
#' @author Pablo Pagnone
#' @export
mod_marine_server <- function(input, output, session, ships){

  dropdowns_mod <- callModule(mod_dropdown_server, "dropdown_ui_1", ships = ships)

  getData <- reactive({
    data <- ships
    if(dropdowns_mod$vessel_type != "All") {
      data <- data %>% filter(.data$ship_type == dropdowns_mod$vessel_type)
    }
    if(dropdowns_mod$vessel_id != "All") {
      data <- data %>% filter(.data$SHIP_ID == dropdowns_mod$vessel_id)
    }

    data
  })

  output$shipstable <- renderDataTable(
    getData() %>% select(.data$SHIP_ID,
                         .data$SHIPNAME,
                         .data$DATETIME,
                         .data$LAT,
                         .data$LON,
                         .data$prev_datetime,
                         .data$prev_lat,
                         .data$prev_lon,
                         .data$advanced_meters,
                         .data$seconds_btw_obs),
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

