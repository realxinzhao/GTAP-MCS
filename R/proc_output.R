
unique(OutDB_land_cet$variable)

Proc_outdata("7USGRNA") -> OutDB_land_cet

Proc_outdata(paste0("default"), Pathfolder = "gtap/outDB/") -> OutDB_mcet_default
OutDB_mcet_default %>% 
  left_join(OutDB_land_cet %>% mutate(scenario = "cet") %>% 
              spread(scenario, value)) %>% 
  filter(variable != "prod") %>% 
  transmute(scenario, variable, region, crop, mcet = value/1000, cet = cet/1000, unit = "kha") %>% 
  group_by(scenario) %>% 
  summarise(RMSE = mean((mcet - cet)^2)^0.5, 
            AE = sum(abs(mcet - cet)), 
            MAE = mean(abs(mcet - cet)) ) %>% 
  arrange(RMSE) -> metric_default


Proc_outdata(paste0("mcet", 1:50), Pathfolder = "gtap/outDB/outDB_mcet_etl/") -> OutDB_mcet_etl

OutDB_mcet_etl %>% 
  left_join(OutDB_land_cet %>% mutate(scenario = "cet") %>% 
              spread(scenario, value)) %>% 
  filter(variable != "prod") %>% 
  transmute(scenario, variable, region, crop, mcet = value/1000, cet = cet/1000, unit = "kha") %>% 
  group_by(scenario) %>% 
  summarise(RMSE = mean((mcet - cet)^2)^0.5, 
            AE = sum(abs(mcet - cet)), 
            MAE = mean(abs(mcet - cet)) ) %>% 
  arrange(RMSE) -> metric_mcet_etl


Proc_outdata(paste0("mcet", 1:50), Pathfolder = "gtap/outDB/outDB_mcet_ydel/") -> OutDB_mcet_ydel
OutDB_mcet_ydel %>% 
  left_join(OutDB_land_cet %>% mutate(scenario = "cet") %>% 
              spread(scenario, value)) %>% 
  filter(variable != "prod") %>% 
  transmute(scenario, variable, region, crop, mcet = value/1000, cet = cet/1000, unit = "kha") %>% 
  group_by(scenario) %>% 
  summarise(RMSE = mean((mcet - cet)^2)^0.5, 
            AE = sum(abs(mcet - cet)), 
            MAE = mean(abs(mcet - cet)) ) %>% 
  arrange(RMSE) -> metric_mcet_ydel

Proc_outdata(paste0("mcet", 1:50), Pathfolder = "gtap/outDB/outDB_mcet_etl_ydel/") -> OutDB_mcet_etl_ydel
OutDB_mcet_etl_ydel %>% 
  left_join(OutDB_land_cet %>% mutate(scenario = "cet") %>% 
              spread(scenario, value)) %>% 
  filter(variable != "prod") %>% 
  transmute(scenario, variable, region, crop, mcet = value/1000, cet = cet/1000, unit = "kha") %>% 
  group_by(scenario) %>% 
  summarise(RMSE = mean((mcet - cet)^2)^0.5, 
            AE = sum(abs(mcet - cet)), 
            MAE = mean(abs(mcet - cet)) ) %>% 
  arrange(RMSE) -> metric_mcet_etl_ydel
