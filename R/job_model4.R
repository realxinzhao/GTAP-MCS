model <- "model_ydel"

#SCENS <- "mcet_default"
SCENS <- paste0("mcet", 1)

for (scen in SCENS) {
  cmd_command <- paste0("gtap -cmf ../cmf/", scen, ".cmf -log ../log/", scen, ".log")
  
  shell(paste0("cd gtap/",model,"&", cmd_command))
  
}
