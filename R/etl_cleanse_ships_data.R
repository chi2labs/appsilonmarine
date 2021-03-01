#' Cleanse shipping data
#' 
#' Applies necessary cleansing of the ships_data provided by Appsilon. 
#' For internal use to update the pre-calculated data in the package. 
#' Currently the requirements are:
#' 
#' * Removing duplicates
#' * Removing instances of [SAT-AIS] and "SAT AIS"
#' * Adding FLAG to the names of twenty-six ships with similar names, but different flags.
#' * Correcting the presumed misspellings of certain ship-names.
#' * Adding FLAG designation to "ARGO" and "C".
#' * Arbitrarily adding a I & II designation to about ten ships with similar names, same flag, but different types and/or other characteristics.
#' * Arbitrarily treating GAZPROM WEST and VOVAN as separate vessels (although we have our doubts).
#'
#' @param df_raw_data raw data provided by Appsilon
#' @import dplyr
#' @return data.frame
#' 
#' @export 
etl_cleanse_ships_data <- function(df_raw_data){
  
  # Remove duplicated rows
  myData <- df_raw_data[!duplicated(df_raw_data),]
  
  # * Removing instances of "[SAT-AIS]" and "SAT AIS"
  myData <- myData %>% 
    filter(!SHIPNAME %in% c("[SAT-AIS]","SAT AIS"))
  
  
  # Adding FLAG to the names of twenty-six ships with similar names, but different flags.
  # We will me manipulating the "SHIPNAME" column, so we'll store the original name elsewhere
  myData <- myData %>% 
    mutate(original_SHIPNAME = SHIPNAME)
  
  tmpDF1 <- myData %>% 
    group_by(SHIPNAME) %>% 
    summarize(
      n_ids = n_distinct(SHIP_ID),
      n_flags = n_distinct(FLAG)
    ) %>% filter(n_ids>1, n_flags>1)
  myData <- myData %>% 
    mutate(SHIPNAME = if_else(SHIPNAME %in% tmpDF1$SHIPNAME,
                              paste0(SHIPNAME," (",FLAG,")" ),# Add flag
                              SHIPNAME)# Leave as is
    )
  
  # Add a I & II designation to about ten ships with similar names, same flag, but different types and/or other characteristics.
  tmpDF2 <- myData %>% 
    group_by(SHIPNAME) %>% 
    summarize(n_ids = n_distinct(SHIP_ID)) %>% 
    filter(n_ids>1)
  
  tmpDF3 <- myData %>% 
    filter(SHIPNAME %in% tmpDF2$SHIPNAME) %>% 
    group_by(SHIPNAME,SHIP_ID) %>% 
    summarize() %>% 
    mutate(SHIPNAME = paste0(SHIPNAME," ",c("I","II")))
  
  lapply(tmpDF3$SHIP_ID,function(sid){
    new_name <- tmpDF3 %>% 
      filter(SHIP_ID==sid) %>% 
      pull(SHIPNAME)
    myData <<- myData %>% # <<- for assignment in the parent function
      mutate(SHIPNAME = if_else(SHIP_ID==sid,
                                new_name,
                                SHIPNAME)
      )
  }) -> devnull
  rm(devnull)
  
  # Correct the presumed misspellings of certain ship-names.
  # This necessarily requires some rather ugly hard-coding
  
  myData <- myData %>% 
    mutate(
      SHIPNAME = if_else(SHIPNAME == "ODYS", "BBAS",SHIPNAME),
      SHIPNAME = if_else(SHIPNAME == ".WLA-311", "WLA-311",SHIPNAME),
      SHIPNAME = if_else(SHIPNAME == "KM ,TAN BORCHARDT", "KAPITAN BORCHARDT" ,SHIPNAME),
      SHIPNAME = if_else(SHIPNAME == "WXA A SZCZESCIA", "WYSPA SZCZESCIA",SHIPNAME),
      SHIPNAME = if_else(SHIPNAME == "ZBASTAR ENDURANCE", "SEASTAR ENDURANCE",SHIPNAME),
      SHIPNAME = if_else(SHIPNAME == "NBAAR MOON", "BOMAR MOON",SHIPNAME),
      SHIPNAME = if_else(SHIPNAME == ". PRINCE OF WAVES", "PRINCE OF WAVES",SHIPNAME)
    )
  
  # Add FLAG designation to "ARGO" and "C". 
  # Argo was already assigned (as it was duplicated) as such there may be no need.
  
  # {no code}
  
  
  # Treattreating GAZPROM WEST and VOVAN as separate vessels
  
  # {no code}
  
  myData
}
