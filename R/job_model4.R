model <- "model4"

SCENS <- paste0("mcet", seq(311,320))

for (scen in SCENS) {
  cmd_command <- paste0("gtap -cmf ../cmf/", scen, ".cmf -log ../log/", scen, ".log")
  
  shell(paste0("cd gtap/",model,"&", cmd_command))
  
}
