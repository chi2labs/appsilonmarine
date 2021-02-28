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
    selectInput(inputId = ns("vessel_id"), label = "Name", choices = c("All"))
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
  values$vessel_id <- "All"

  observe({
    # Change vessel_type input.
    opt_type <- ships %>% ungroup() %>% distinct(ship_type) %>% arrange(ship_type) %>% pull()
    updateSelectInput(session = session, inputId = "vessel_type", choices = c("All", opt_type))
  })

  observeEvent(input$vessel_type, {

    values$vessel_type <- input$vessel_type

    vessel <- ships
    if(!is.null(input$vessel_type) && input$vessel_type != "All") {
      vessel <- vessel %>% filter(ship_type == input$vessel_type)
    }

    vessel_unique <- vessel %>% distinct(SHIPNAME, SHIP_ID) %>%
      arrange(SHIPNAME) %>%
      mutate(label = paste(SHIPNAME, sprintf("(%s)",SHIP_ID)))

    all <- "All"
    names(all) <- "All"
    opt_name <- vessel_unique$SHIP_ID
    names(opt_name) <- vessel_unique$label

    updateSelectInput(session = session, inputId = "vessel_id", choices =  c(all, opt_name))
  })

  observeEvent(input$vessel_id, {
    values$vessel_id <- input$vessel_id
  })

  # Return reactive inputs
  return(values)
}

## To be copied in the UI
# mod_dropdown_ui("dropdown_ui_1")

## To be copied in the server
# callModule(mod_dropdown_server, "dropdown_ui_1")

