

#' Proc_outdata
#'
#' @param A set of scenario names in characters 
#' @param Pathfolder The folder contains the har files (default "gtap/outDB/")
#' @param Harfile  .upd is the default. others e.g., .har can be used 
#'
#' @return A dataframe of results including Area, Cover, and Production
#' @export
#'
#' @examples 
#' 
Proc_outdata <- function(SCENs, Pathfolder = "gtap/outDB/", Harfile = ".upd"){
  assertthat::assert_that(is.character(SCENs))
  
  lapply(SCENs, function(scen){
    
    DBnm <- paste0(Pathfolder, scen, Harfile)
    data = read_har(DBnm) 
    data %>% 
      purrr::pluck("AREA") %>% 
      as.data.frame() %>% 
      gather(area, value) %>% group_by(area) %>%  summarize(value = sum(value)) %>% 
      separate(col = area, into = c("crop", "region"), sep = "\\.") %>% 
      mutate(variable = "area") %>% bind_rows(
        data%>%
          purrr::pluck("PRDN") %>%
          as.data.frame() %>%
          gather(area, value) %>% group_by(area) %>%  summarize(value = sum(value)) %>%
          separate(col = area, into = c("crop", "region"), sep = "\\.") %>%
          mutate(variable = "prod")
      ) %>% bind_rows(
        data%>% 
          purrr::pluck("COVR") %>% 
          as.data.frame() %>% 
          gather(area, value) %>% group_by(area) %>%  summarize(value = sum(value)) %>%  
          separate(col = area, into = c("crop", "region"), sep = "\\.") %>% 
          mutate(variable = "cover")
      ) %>% 
      mutate(scenario = scen)
    
  }) %>% bind_rows() 
}



#' filterout_group
#'
#' @param .df A data frame input 
#' @param Condition A condition for obs. to be removed
#' @param ID_colname The column (ID) name where the whole group including the obs. will be removed 
#'
#' @return A clean data frame 
#' @export

filterout_group <- function(.df, Condition, ID_colname){
  
  assertthat::assert_that(is.data.frame(.df))
  assertthat::assert_that(is.character(Condition))
  assertthat::assert_that(is.character(ID_colname))
  
  .df %>% 
    filter(eval(parse(text = Condition))) %>% 
    pull(get(ID_colname)) %>% unique() -> ID_rm
  
  .df %>% 
    filter(! get(ID_colname) %in% ID_rm)
}

