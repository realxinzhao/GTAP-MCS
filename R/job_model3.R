model <- "model3"


SCENS <- paste0("mcet", seq(51, 60))

for (scen in SCENS) {
  cmd_command <- paste0("gtap -cmf ../cmf/cmf_mcet_etl_ydel/", scen, ".cmf -log ../log/log_mcet_etl_ydel/", scen, ".log")
  
  shell(paste0("cd gtap/",model,"&", cmd_command))
  
}