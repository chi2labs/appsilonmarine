#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @importFrom shiny callModule
#' @importFrom readr read_rds
#' @noRd
app_server <- function( input, output, session ) {
  # Load data previously analyzed.
  ships <- read_rds(system.file("data/ships.RDS", package="appsilonmarine"))
  callModule(mod_marine_server, "marine_ui_1", ships = ships)
}
