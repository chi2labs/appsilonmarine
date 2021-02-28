#' Run Appsilon ETL process
#'
#' @param path_ship_csv Path to original csv with ships observations.
#' @param output_path where the resulting RDS goes
#' @importFrom readr read_csv
#' @importFrom readr write_rds
#' @return Save a RDS called ships.RDS
#' @noRd
run_etl <- function(path_ship_csv,  output_path = here::here("inst","app","shipsdata","ships.RDS")){
 
  if(!dir.exists(dirname(output_path))){
    stop("Output directory not found: ", dirname(output_path))
  }
  
  if(!file.exists(path_ship_csv)){
    stop("Input file not found.")
  }
  
  ships_data <- readr::read_csv(path_ship_csv)
  # cleanse
  ships_data <- etl_cleanse_ships_data(ships_data)
  # Do the pre-calculations
  final <- etl_appsilon_requirement(ships_data)
  
  readr::write_rds(final, output_path)
}
