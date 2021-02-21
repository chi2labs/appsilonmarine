#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {

  ships <- read_csv("inst/data/ships.csv")

  # Taking first and last row for ship and calculating distance(meters) sailed.
  ships <- ships %>% group_by(SHIPNAME) %>% arrange(DATETIME) %>% filter(row_number()==1 | row_number()== n()) %>%
    mutate(prevLON = lag(LON, default = NA),
           prevLAT = lag(LAT, default = NA)) %>%
    rowwise() %>%
    mutate(distance_sailed = ifelse(!is.na(prevLON),
                                    first(distm(c(prevLON, prevLAT),
                                                c(LON, LAT),
                                                fun=distHaversine),
                                    ),
                                    NA)) %>%
    ungroup() %>% arrange(SHIPNAME, DATETIME)

  callModule(mod_marine_server, "marine_ui_1", ships = ships)
}
