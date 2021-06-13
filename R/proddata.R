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


SCEN_MCET <- paste0("mcet", 1:10)
SCEN_MCET <- "7USGRNA"
################################################
#read data from output database



Proc_outdata("7USGRNA") -> OutDB_land_cet

Proc_outdata(paste0("mcet", 1:320)) -> OutDB_land_mcet
Proc_outdata(paste0("mcet", 321:450)) -> OutDB_land_mcet
OutDB_land_mcet %>% 
  left_join(OutDB_land_cet %>% mutate(scenario = "cet") %>% 
              spread(scenario, value)) %>% 
  transmute(scenario, variable, region, crop, mcet = value/1000, cet = cet/1000, unit = "kha") %>% 
  group_by(scenario) %>% 
  summarise(RMSE = mean((mcet - cet)^2)^0.5, 
            AE = sum(abs(mcet - cet)), 
            MAE = mean(abs(mcet - cet)) ) -> A
A %>% arrange(RMSE) %>% 
  write.csv("output/metric_321_450.csv") 

   
##############################################
#Second round: around mcet172

################################################
#generate parameters
# ET11, ET12, ETL5 = ETL2; ETL6 fixed
nruns = 100
id_start = 501

runif(nruns, 0, 2) -> ET11_factor
runif(nruns, 0, 2) -> ET12_factor
runif(nruns, 0.9, 1.1) -> ETL2_factor
data.frame(ET11_factor = ET11_factor, 
           ET12_factor = ET12_factor, 
           ETL2_factor = ETL2_factor, id = id_start:(id_start + nruns - 1)) -> trial_para
write.csv(trial_para, "gtap/parameter/trial_para_round2.csv")
#############
#generate cmf and prm files
Prmnm <- "gtap/parameter/par_mcet169.prm"
Prmnm_default = read_har(Prmnm)[c("ET11", "ET12", "ETL2", "ETL5", "ETL6")]
cmf_default <- readLines(file("gtap/cmf/mcet_default.cmf"))

for (id in c(id_start:(id_start + nruns - 1))) {
  
  data = Prmnm_default
  #update parameter
  data$ET11 = data$ET11 * trial_para$ET11_factor[match(id, trial_para$id)]   
  data$ET12 = data$ET12 * trial_para$ET12_factor[match(id, trial_para$id)]
  data$ETL2 = data$ETL2 * trial_para$ETL2_factor[match(id, trial_para$id)]
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

Proc_outdata(paste0("mcet", 501:522)) -> OutDB_land_mcet

Proc_outdata("7USGRNA") -> OutDB_land_cet
OutDB_land_mcet %>% 
  left_join(OutDB_land_cet %>% mutate(scenario = "cet") %>% 
              spread(scenario, value)) %>% 
  transmute(scenario, variable, region, crop, mcet = value/1000, cet = cet/1000, unit = "kha") %>% 
  group_by(scenario) %>% 
  summarise(RMSE = mean((mcet - cet)^2)^0.5, 
            AE = sum(abs(mcet - cet)), 
            MAE = mean(abs(mcet - cet)) ) -> A
A %>% arrange(RMSE) %>% 
  write.csv("output/metric_501_560.csv") 


