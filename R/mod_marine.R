#' Marine UI Function
#'
#' @description Marine UI Module, show dropdowns to select a vessel and show in
#' a map.
#'
#' @param id Internal parameters for {shiny}.
#' @importFrom shiny NS div h2 tags
#' @importFrom leaflet leafletOutput
#' @import shiny.semantic
#' @author Pablo Pagnone
#' @export
mod_marine_ui <- function(id){
  ns <- NS(id)
  semanticPage(
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
      dropdowns = div(mod_dropdown_ui(id = ns("dropdown_ui_1")),
                      br(),
                      uiOutput(ns("shipinfo"))),
      map = div(leaflet::leafletOutput(ns("map"), width = "auto")),
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
#' @importFrom shiny validate reactive callModule need br
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

  output$map <- leaflet::renderLeaflet({
    data <- getData()
    validate(need(nrow(data) > 0, "Doesn't exist observations for this ship."))
    ship_position_map(data,
                      show_previous_position = ifelse(dropdowns_mod$vessel_id != "All", TRUE, FALSE))
  })


  output$shipinfo <- renderUI({

    if(dropdowns_mod$vessel_id == "All") {
      return()
    }
    data <- getData()

    cards(
      card(
        div(class="content",
            div(class="header", "Observation"),
            br(),
            div(class="meta", "Distance Sailed (meters)"),
            div(class="description", data[1,]$advanced_meters),
            br(),
            div(class="meta", "Current Ubication"),
            div(class="description", paste0(data[1,]$LAT, ", ", data[1,]$LON)),
            br(),
            div(class="meta", "Previous Ubication"),
            div(class="description", paste0(data[1,]$prev_lat, ", ", data[1,]$prev_lon)),
            br(),
            div(class="meta", "Time between observations (secs)"),
            div(class="description", data[1,]$seconds_btw_obs),
            br(),
            div(class="meta", "Speed between observations (Km/h)"),
            div(class="description", round(data[1,]$speed_kmh, 2)),
        )
      )
    )
  })

}

## To be copied in the UI
# mod_marine_ui("marine_ui_1")

## To be copied in the server
# callModule(mod_marine_server, "marine_ui_1")

