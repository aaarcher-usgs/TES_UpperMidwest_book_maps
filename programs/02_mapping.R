#' # Merge data with county shapefile for TES book maps
#' 
#' Data downloaded from the Environmental Conservation Online System
#' 
#' County and state shapefiles from ggplot2
#' 
#' ### Document Preamble
#+ library
library(ezknitr)
library(knitr)
library(ggplot2) # ggplot2 for mapping
library(ggmap) # For theme_nothing
library(dplyr)
remove(list=ls())

#' ## Load data
#+ loadData
load("data/output_data/map_data.R")
head(map.data)
map.data$region <- tolower(map.data$State)
map.data$subregion <- tolower(map.data$County)

#' ## Download spatial data
#+ spatData
states <- as.character(unique(map.data$State))
# State outlines
states.shp <- map_data("state", region=states)
# County outlines 
counties.shp <- map_data("county", region = states)

#' ## Join polygon data and species data by species
#+ join
by.species.list <- split(map.data, f = map.data$Species)
for(ii in 1:length(by.species.list)){
  temp <- inner_join(counties.shp, by.species.list[[ii]], by="subregion")
  name <- as.character(by.species.list[[ii]]$Species[1])
  assign(name, temp)
  
  temp.states <- unique(temp$region.x)
  states.species.temp <- states.shp[states.shp$region %in% temp.states,]
  name.state <- as.character(paste("state", name, sep=" "))
  assign(name.state, states.species.temp)
}

#' ## Basemap
#+ basemap
p <- ggplot(data=counties.shp)+
  geom_polygon(aes(x=long,y=lat, group=group), fill=NA, colour="#E0E0E0")+
  geom_polygon(data=states.shp, aes(x=long,y=lat, group=group), fill=NA, colour="#C0C0C0")+
  coord_fixed()+
  theme_nothing()

#' fanshell
#+ fanshell
p +
  geom_polygon(data=fanshell, aes(x=long, y=lat, group=group), fill="#A0A0A0", colour="#808080")+ 
  geom_polygon(data=`state fanshell`, aes(x=long, y=lat, group=group), fill=NA, colour="#404040")

#' northern long-eared bat
#+ northern_long_eared_bat
p +
  geom_polygon(data=`Northern long-eared Bat`, aes(x=long, y=lat, group=group), fill="#A0A0A0", colour="#808080")+ 
  geom_polygon(data=`state Northern long-eared Bat`, aes(x=long, y=lat, group=group), fill=NA, colour="#404040")

#' tumbling creek cavesnail
#+ tumbling_creek_cavesnail
p +
  geom_polygon(data=`Tumbling Creek cavesnail`, aes(x=long, y=lat, group=group), fill="#A0A0A0", colour="#808080")+ 
  geom_polygon(data=`state Tumbling Creek cavesnail`, aes(x=long, y=lat, group=group), fill=NA, colour="#404040")

#' neosho madtom
#+ neosho_madtom
p +
  geom_polygon(data=`Neosho madtom`, aes(x=long, y=lat, group=group), fill="#A0A0A0", colour="#808080")+ 
  geom_polygon(data=`state Neosho madtom`, aes(x=long, y=lat, group=group), fill=NA, colour="#404040")

#' ### Document Footer
#' 
#' ezspin("programs/02_mapping.R", out_dir = "output", fig_dir="figures", keep_md=F)
#' 
#+ footer
sessionInfo()

