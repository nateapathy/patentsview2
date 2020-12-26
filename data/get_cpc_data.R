#### Get CPC Data for Reference table, create .rda file for lazy loading
## cpc_subgroup file from https://www.patentsview.org/download/
library(tidyverse)
library(stringr)
# download and unzip the file
temp <- tempfile()
# this link should be steady but may change if file gets updated
download.file("https://s3.amazonaws.com/data.patentsview.org/20200929/download/cpc_subgroup.tsv.zip",temp)
cpc_subgroups <- read.delim(unzip(temp, "cpc_subgroup.tsv"))
unlink(temp)
rm(temp)

# get the ID in to subclass (first 4 characters), group (next 1-3), and subgroup (after the /)
cpc_subgroups %>%
  mutate(cpc_subclass=substr(id,1,4), # get 4 digit cpc subclass
         cpc_group=str_replace(sapply(strsplit(id,"/"),"[",1),cpc_subclass,""),
         cpc_subgroup=sapply(strsplit(id,"/"),"[",2)) -> cpc_subgroups

save(cpc_subgroups,file="data/cpc_subgroups.rda")

# filter down to subclass only
cpc_subgroups %>%
  filter(cpc_subgroup=="00" & cpc_group %in% c("1","10")) %>%
  distinct(cpc_subclass,title) %>%
  dplyr::select(c(2,1)) -> cpc_subclasses

save(cpc_subclasses,file="data/cpc_subclasses.rda")
