library(HARr)
library(dplyr)
library(tidyr)

################################################
#generate parameters
# ET11, ET12, ETL5 = ETL2; ETL6 fixed
# ET11 < ET12 < ETL2 = ETL5

nruns = 500

id_start = 1

runif(nruns, 0.1, 1.9) -> ET11_factor
runif(nruns, 0.1, 1.9) -> ET12_factor
runif(nruns, 0.8, 1.2) -> ETL2_factor
runif(nruns, 0.5, 1.5) -> YDEL_factor
data.frame(ET11 = ET11_factor, 
           ET12 = ET12_factor, 
           ETL2 = ETL2_factor, 
           YDEL = YDEL_factor,
           id = id_start:(id_start + nruns - 1)
           ) -> trial_factor

Prmnm <- "gtap/parameter/par_default.prm"

baseadjust <- data.frame(parameter = c("ET11", "ET12", "ETL2", "YDEL"), 
                         basescaler = c(0.2, 0.26, 1, 1) ) # from first round id#169

as.data.frame(read_har(Prmnm)[c("ET11", "ET12", "ETL2")] ) %>% 
  tibble::rownames_to_column("region") %>% left_join(
    data.frame(YDEL = read_har(Prmnm)[[c("YDEL")]]["Wheat",]) %>% 
      tibble::rownames_to_column("region"), by = "region"
  ) %>% 
  gather(parameter, basevalue, -region) %>% right_join(
    trial_factor %>% 
      gather(parameter, factor, -id), by = "parameter"
  ) %>% left_join(baseadjust, by = "parameter") %>% 
  mutate(value = basevalue * basescaler * factor ) %>% 
  select(-basevalue, -basescaler, -factor) %>% 
  spread(parameter, value) %>% 
  filterout_group("ET11 < ET12 |  ET12 < ETL2", "id") -> trial_para

trial_para %>% gather(parameter, value, -region, -id) %>% 
  left_join(trial_factor %>% gather(parameter, factor, -id) ) %>% 
  left_join(baseadjust) %>% 
  group_by(region, parameter) %>% mutate(ID = seq.int(1:length(unique(trial_data$id)))) %>% 
  ungroup() %>%  #redo id
  select(-id) %>% rename(id = ID) %>% 
  mutate(total_factor = factor * basescaler) -> trial_data

unique(trial_data$id)

write.csv(trial_para, "gtap/parameter/trial_data.csv")  

trial_data %>% filter(region == "USA") %>% 
  select(id, parameter, total_factor) %>% 
  spread(parameter, total_factor) -> trial_data_factor



Prmnm <- "gtap/parameter/par_default.prm"
Prmnm_default = read_har(Prmnm)[c("ET11", "ET12", "ETL2", "ETL5", "ETL6", "YDEL")]
cmf_default <- readLines(file("gtap/cmf/mcet_default.cmf"))

id_start = 1
nruns = 100
for (id in c(id_start:(id_start + nruns - 1))) {
  
  data = Prmnm_default
  #update parameter
  data$ET11 = data$ET11 * trial_data_factor$ET11[match(id, trial_data_factor$id)]   
  data$ET12 = data$ET12 * trial_data_factor$ET12[match(id, trial_data_factor$id)]   
  data$ETL2 = data$ETL2 * trial_data_factor$ETL2[match(id, trial_data_factor$id)]   
  data$ETL5 = data$ETL2 
  data$ETL6 = data$ETL6 
  data$YDEL = data$YDEL * trial_data_factor$YDEL[match(id, trial_data_factor$id)]   
  
  write_har(data, paste0("gtap/parameter/", "par_mcet", id, ".prm")) }

#mcet_etl
for (id in c(id_start:(id_start + nruns - 1))) {  
  #update cmf
  cmf = cmf_default
  cmf[19] = paste0("Updated file gtapDATA = ../outDB/outDB_mcet/mcet", id, ".upd;")
  cmf[20] = paste0("Solution file = mcet",id, ";")
  cmf[22] = paste0("file gtapPARL = ../parameter/par_mcet", id, ".prm;")
  #cmf[23] = paste0("file gtapPARY = ../parameter/par_mcet", id, ".prm;")
  cmf[23] = paste0("file gtapPARY = default3.prm;") 
  writeLines(cmf, file(paste0("gtap/cmf/cmf_mcet/mcet", id, ".cmf") ))
}

#mcet_ydel
for (id in c(id_start:(id_start + nruns - 1))) {  
  #update cmf
  cmf = cmf_default
  cmf[19] = paste0("Updated file gtapDATA = ../outDB/outDB_mcet_ydel/mcet", id, ".upd;")
  cmf[20] = paste0("Solution file = mcet",id, ";")
  #cmf[22] = paste0("file gtapPARL = ../parameter/par_mcet", id, ".prm;")
  cmf[22] = paste0("file gtapPARL = default3.prm;")
  cmf[23] = paste0("file gtapPARY = ../parameter/par_mcet", id, ".prm;")
  #cmf[23] = paste0("file gtapPARY = default3.prm;") 
  writeLines(cmf, file(paste0("gtap/cmf/cmf_mcet_ydel/mcet", id, ".cmf") ))
}

#mcet_etl_ydel
for (id in c(id_start:(id_start + nruns - 1))) {  
  #update cmf
  cmf = cmf_default
  cmf[19] = paste0("Updated file gtapDATA = ../outDB/outDB_mcet_etl_ydel/mcet", id, ".upd;")
  cmf[20] = paste0("Solution file = mcet",id, ";")
  cmf[22] = paste0("file gtapPARL = ../parameter/par_mcet", id, ".prm;")
  #cmf[22] = paste0("file gtapPARL = default3.prm;")
  cmf[23] = paste0("file gtapPARY = ../parameter/par_mcet", id, ".prm;")
  #cmf[23] = paste0("file gtapPARY = default3.prm;") 
  writeLines(cmf, file(paste0("gtap/cmf/cmf_mcet_etl_ydel/mcet", id, ".cmf") ))
}




