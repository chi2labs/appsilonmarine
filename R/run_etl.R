#' Run Appsilon ETL process
#'
#' @importFrom readr read_csv
#' @importFrom readr write_rds
#' @return Save a RDS called ships.RDS
#' @export
run_etl <- function(){

  ships_data <- read_csv("inst/data/ships.csv")
  final <- etl_appsilon_requirement(ships_data)
  write_rds(final, "inst/data/ships.RDS")

}
