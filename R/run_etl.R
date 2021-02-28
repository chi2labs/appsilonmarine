#' Run Appsilon ETL process
#'
#' @param path_ship_csv Path to original csv with ships observations.
#' @param output_path where the resulting RDS goes
#' @importFrom readr read_csv
#' @importFrom readr write_rds
#' @return Save a RDS called ships.RDS
#' @noRd
run_etl <- function(path_ship_csv,  output_path = here::here("inst","data","ships.RDS")){
  output_path <- here::here("inst","data","ships.RDS")
  if(!dir.exists(output_path)){
    stop("Output directory not found.", output_path)
  }
  
  if(!file.exists(path_ship_csv)){
    stop("Input file not found.")
  }
  
  ships_data <- read_csv(path_ship_csv)
  final <- etl_appsilon_requirement(ships_data)
  write_rds(final, output_path)

}
