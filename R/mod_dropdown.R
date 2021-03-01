#' dropdown UI Function
#'
#' @description A shiny Module.
#'
#' @param id Internal parameters for {shiny}.
#' @importFrom shiny NS tagList div
#' @import shiny.semantic
#' @export
mod_dropdown_ui <- function(id){
  ns <- NS(id)
  div(
    selectInput(inputId = ns("vessel_type"),label = "Vessel Type", choices = c("All")),
    selectInput(inputId = ns("vessel_name"), label = "Vessel Name", choices = c("All"))
  )
}

#' Dropdown Server Function
#' @param input Shiny Input
#' @param output Shiny Output
#' @param session Shiny session
#' @param ships - Data.frame with data to show in selects inputs.
#' @import dplyr
#' @importFrom shiny observe observeEvent reactiveValues
#' @importFrom rlang .data
#' @import shiny.semantic
#' @author Pablo Pagnone
#' @export
mod_dropdown_server <- function(input, output, session, ships){

  values <- reactiveValues()
  values$vessel_type <- "All"
  values$vessel_name <- "All"

  observe({
    # Change vessel_type input.
    opt_type <- ships %>% ungroup() %>% distinct(.data$ship_type) %>% arrange(.data$ship_type) %>% pull()
    updateSelectInput(session = session, inputId = "vessel_type", choices = c("All", opt_type))
  })

  observeEvent(input$vessel_type, {

    values$vessel_type <- input$vessel_type

    vessel <- ships
    if(!is.null(input$vessel_type) && input$vessel_type != "All") {
      vessel <- vessel %>% filter(.data$ship_type == input$vessel_type)
    }

    vessel_names <- vessel %>% distinct(.data$SHIPNAME) %>%
      arrange(.data$SHIPNAME) %>% pull

    updateSelectInput(session = session, inputId = "vessel_name", choices =  c("All", vessel_names))
  })

  observeEvent(input$vessel_name, {
    values$vessel_name <- input$vessel_name
  })

  # Return reactive inputs
  return(values)
}

## To be copied in the UI
# mod_dropdown_ui("dropdown_ui_1")

## To be copied in the server
# callModule(mod_dropdown_server, "dropdown_ui_1")

