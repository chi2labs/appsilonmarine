#' Run Appsilon ETL process
#'
#' @param Path to origin csv with ships observations.
#' @importFrom readr read_csv
#' @importFrom readr write_rds
#' @return Save a RDS called ships.RDS
#' @noRd
run_etl <- function(path_ship_csv){

  ships_data <- read_csv(path_ship_csv)
  final <- etl_appsilon_requirement(ships_data)
  write_rds(final, system.file("data/ships.RDS", package="appsilonmarine"))

}
