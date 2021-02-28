#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Load data previously analyzed.
  ships <<- read_rds("inst/data/ships.RDS")
  callModule(mod_marine_server, "marine_ui_1", ships = ships)
}
