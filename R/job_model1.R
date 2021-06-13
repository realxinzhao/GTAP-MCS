model <- "model1"

#SCENS <- "mcet_default"

SCENS <- paste0("mcet", seq(61,80))

for (scen in SCENS) {
  cmd_command <- paste0("gtap -cmf ../cmf/cmf_mcet_etl/", scen, ".cmf -log ../log/log_mcet_etl/", scen, ".log")
  
  shell(paste0("cd gtap/",model,"&", cmd_command))
  
}
