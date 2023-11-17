# Compile Streamflow and Energy Data for Hydropower facilities along the Snake River
# Kendra Kaiser
# November 16, 2023

library(tidyverse)
library(dataRetrieval)

gages <- c("13010065", "13011000", "13022500", "13032500", "13069500", "13075910", "13077000")
# 13010065 above jackson laker
#13011000 Moran WY - outflow from Jackson Lake
# 13022500 Alpine Wy, above palisades 
# 13032500 Irwin ID, below palisades
# 13069500 Blackfoot, ID, above amerian Falls
# 13075910 Portneuf near Tyhee, ID; above amerian Falls
# no data from Ross fork or Bannock Creek entering american falls?
#13077000 Neeley, ID; below american falls
pCode = "00060" # USGS code for streamflow
# sCode = "00054" # USGS code for reservoir storage (acre-feet)

site_info<- whatNWISdata(sites= gages, parameterCd = pCode, outputDataTypeCd ='uv')
start_date<- min(site_info$begin_date)
end_date<- Sys.Date()
# get site metadata
site_meta <- gages %>%
  map_df(.f = function(x){
    df <- readNWISsite(x)
    return(df)
  })

# gather flow data
flows <- gages %>%
  map_df(.f = function(x){
    df <- readNWISuv(siteNumbers = x,
                     parameterCd = "00060", # discharge code
                     startDate = start_date,
                     endDate = end_date)
    return(df)
  }) %>% 
  renameNWISColumns() %>% 
  left_join(site_meta %>%
              select(site_no, station_nm, lat_va, long_va, coord_datum_cd)
  )
