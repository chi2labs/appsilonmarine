#' dropdown UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @noRd
#' @importFrom shiny NS tagList
mod_dropdown_ui <- function(id){
  ns <- NS(id)
  div(
    selectInput(inputId = ns("vessel_type"),label = "Type", choices = c("All")),
    selectInput(inputId = ns("vessel_name"),label = "Name", choices = c("All"))
  )
}

#' dropdown Server Function
#' @param input Shiny Input
#' @param output Shiny Output
#' @param session Shiny session
#' @param ships - Data.frame with data to show in selects inputs.
#' @import dplyr
#' @import shiny
#' @author Pablo Pagnone
#' @noRd
mod_dropdown_server <- function(input, output, session, ships){
  values <- reactiveValues()
  values$vessel_type <- "All"
  values$vessel_name <- "All"

  observe({
    opt_type <- ships %>% distinct(ship_type) %>% arrange(ship_type) %>% pull()
    opt_name <- ships %>% distinct(SHIPNAME) %>% arrange(SHIPNAME) %>% pull()
    updateSelectInput(session = session, inputId = "vessel_type", choices = c("All", opt_type))
    updateSelectInput(session = session, inputId = "vessel_name", choices = c("All", opt_name))
  })

  observeEvent(input$vessel_type, {

    values$vessel_type <- input$vessel_type
    opt_name <- ships
    if(!is.null(input$vessel_type) && input$vessel_type != "All") {
      opt_name <- opt_name %>% filter(ship_type == input$vessel_type)
    }
    opt_name <- opt_name %>% distinct(SHIPNAME) %>% arrange(SHIPNAME) %>% pull()
    updateSelectInput(session = session, inputId = "vessel_name", choices = c("All", opt_name))
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
