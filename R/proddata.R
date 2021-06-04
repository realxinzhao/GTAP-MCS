library(HARr)
library(dplyr)
library(tidyr)


################################################
#generate parameters
# ET11, ET12, ETL5 = ETL2; ETL6 fixed
nruns = 500

runif(nruns, 0, 2) -> ET11_factor
runif(nruns, 0, 2) -> ET12_factor
runif(nruns, 0, 2) -> ETL2_factor
data.frame(ET11_factor = ET11_factor, 
           ET12_factor = ET12_factor, 
           ETL2_factor = ETL2_factor, id = 1:nruns) -> trial_para
write.csv(trial_para, "gtap/parameter/trial_para.csv")
#############
#generate cmf and prm files
Prmnm <- "gtap/parameter/par_default.prm"
Prmnm_default = read_har(Prmnm)[c("ET11", "ET12", "ETL2", "ETL5", "ETL6")]
cmf_default <- readLines(file("gtap/cmf/mcet_default.cmf"))

for (id in c(1:nruns)) {
  
  data = Prmnm_default
  #update parameter
  data$ET11 = data$ET11 * trial_para$ET11_factor[id]
  data$ET12 = data$ET12 * trial_para$ET12_factor[id]
  data$ETL2 = data$ETL2 * trial_para$ETL2_factor[id]
  data$ETL5 = data$ETL2 
  data$ETL6 = data$ETL6 
  
  write_har(data, paste0("gtap/parameter/", "par_mcet", id, ".prm"))
  
  #update cmf
  cmf = cmf_default
  cmf[19] = paste0("Updated file gtapDATA = ../outDB/mcet", id, ".upd;")
  cmf[20] = paste0("Solution file = mcet",id, ";")
  cmf[22] = paste0("file gtapPARL = ../parameter/par_mcet", id, ".prm;")
  
  writeLines(cmf, file(paste0("gtap/cmf/mcet", id, ".cmf") ))
  
}



scen <- "mcet1"
################################################
#read data from output database

DBnm <- paste0("gtap/outDB/", scen, ".upd")
data = read_har(DBnm) 
data %>% 
  purrr::pluck("AREA") %>% 
  as.data.frame() %>% 
  gather(area, value) %>% 
  separate(col = area, into = c("crop", "region"), sep = "\\.") %>% 
  mutate(variable = "area") %>% bind_rows(
    data%>% 
      purrr::pluck("PRDN") %>% 
      as.data.frame() %>% 
      gather(area, value) %>% 
      separate(col = area, into = c("crop", "region"), sep = "\\.") %>% 
      mutate(variable = "prod")
  ) %>% bind_rows(
    data%>% 
      purrr::pluck("COVR") %>% 
      as.data.frame() %>% 
      gather(area, value) %>% 
      separate(col = area, into = c("crop", "region"), sep = "\\.") %>% 
      mutate(variable = "cover")
  ) %>% 
  mutate(scenario = gsub(".upd", "", DBnm)) -> A
   
##############################################

