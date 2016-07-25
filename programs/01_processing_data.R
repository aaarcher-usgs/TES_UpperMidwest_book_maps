#' # Process data for TES book maps
#' 
#' Data downloaded from the Environmental Conservation Online System
#' 
#' ### Document Preamble
#+ library
library(ezknitr)
library(knitr)
library(dplyr)
remove(list=ls())

#' ## Download raw data from .csv
#+ downloadCSV
# Downloaded 20160722
species.list1 <- c("American Burying beetle", "Canada Lynx", "clubshell",
                  "Copperbelly Water snake", "Curtis pearlymussel",
                  "Dakota Skipper", "eastern Massasauga","fanshell",
                  "Fat pocketbook", "Gray bat", "Grotto Sculpin", "Higgins eye",
                  "Hines emerald dragonfly", "Hungerfords Crawling Water Beetle",
                  "Indiana bat", "Iowa Pleistocene snail", "Karner Blue butterfly",
                  "Kirtlands Warbler", "Least tern", "Mitchells Satyr Butterfly",
                  "Neosho madtom", "Neosho mucket", "Niangua darter", 
                  "Northern long-eared Bat", "Northern riffleshell", 
                  "Orangefoot pimpleback", "Ozark Big-Eared bat","Ozark cavefish",
                  "Ozark Hellbender", "Pallid sturgeon", "Pink mucket",
                  "Piping Plover", "Poweshiek skipperling", "purple cats paw",
                  "rabbitsfoot", "Rayed Bean", "Red Knot", "Rough pigtoe",
                  "Scaleshell mussel", "Scioto madtom", "Sheepnose Mussel",
                  "Snuffbox mussel", "Spectaclecase (mussel)", "Topeka shiner",
                  "Tumbling Creek cavesnail", "White catspaw", "Whooping crane",
                  "Winged Mapleleaf")
# Downloaded 20160725
species.list2 <- c("American HartS-Tongue fern", "Arkansas River shiner",
                   "Black-Footed ferret", "Blowout penstemon", "Cave crayfish",
                   "Colorado Butterfly", "Decurrent False aster", "Dwarf Lake iris",
                   "Eastern Prairie Fringed orchid", "Fassetts locoweed",
                   "Geocarpon", "Gray wolf", "Houghtons goldenrode",
                   "Illinois Cave amphipod", "Leafy prairie-clover", 
                   "Lakeside daisy", "Least tern", "Leedys rosefoot",
                   "Lesser prairie-chicken", "Meads milkweed", 
                   "Michigan monkey-flower", "Minnesota Dwarf Trout lily",
                   "Missouri bladderpod", "Northern Wild monkshood", 
                   "Pitchers thistle", "pondberry", "Prairie bush-clover",
                   "Prices potato-bean", "Running Buffalo clover", 
                   "Salt Creek Tiger beetle", "Shorts bladderpod", 
                   "Small Whorled pogonia", "Ute ladies-tresses",
                   "Virginia sneezeweed", "Virginia spiraea", 
                   "Western Prairie Fringed orchid")
species.list <- c(species.list1, species.list2)
# Download all from these folders
path <- "data/downloaded20160722"
fs <- list.files(path, pattern = glob2rx("*.csv"))
path.2 <- "data/downloaded20160725"
fs.2 <- list.files(path.2, pattern = glob2rx("*.csv"))

# Places to store records
species.each.item <- NULL
state.each.item <- NULL
county.each.item <- NULL
for(ii in fs){
  # Read in raw data table
  fname <- file.path(path, ii) 
  temp <- read.table(fname, fileEncoding = "UCS-2LE", sep="\t", head=T, quote = "")
  temp$StateF <- as.character(temp$State)
  temp$CountyF <- as.character(temp$County)
  
  # Determine the species for each table as extracted from table name
  ii.species <- gsub("\\,.*","",fname)
  ii.species <- gsub("data/downloaded20160722/US Counties in which the ", "", ii.species)
  
  # Species-specific data into a new data.frame
  assign(ii.species, temp[,3:4])
  
  # Record the data in new vectors
  state.each.item <- c(state.each.item, temp$StateF)
  county.each.item <- c(county.each.item, temp$CountyF)
  species.each.item <- c(species.each.item, rep(ii.species, nrow(temp)))
}
for(ii in fs.2){
  # Read in raw data table
  fname <- file.path(path.2, ii) 
  temp <- read.table(fname, fileEncoding = "UCS-2LE", sep="\t", head=T, quote = "")
  temp$StateF <- as.character(temp$State)
  temp$CountyF <- as.character(temp$County)
  
  # Determine the species for each table as extracted from table name
  ii.species <- gsub("\\,.*","",fname)
  ii.species <- gsub("data/downloaded20160722/US Counties in which the ", "", ii.species)
  
  # Species-specific data into a new data.frame
  assign(ii.species, temp[,3:4])
  
  # Record the data in new vectors
  state.each.item <- c(state.each.item, temp$StateF)
  county.each.item <- c(county.each.item, temp$CountyF)
  species.each.item <- c(species.each.item, rep(ii.species, nrow(temp)))
}

#' ## Combine all data together
#+ dataComb
all.data <- as.data.frame(cbind(state.each.item, county.each.item, species.each.item))
colnames(all.data) <- c("State", "County", "Species")
summary(all.data)

#' States for mapping
#+ stateList
states <- as.data.frame(c("North Dakota", "South Dakota",
            "Nebraska", "Kansas", "Minnesota",
            "Iowa", "Missouri", "Wisconsin", "Illinois",
            "Indiana", "Ohio", "Michigan"))
colnames(states) <- "State"
# Add state-level FIPS code
states$STATEFP <- as.character(c(38, 46, 31, 20, 27, 19, 29, 55, 17, 18, 39, 26))

#' Subset data 
#+ subsetStates
# Only data from states that will be mapped
map.data <- all.data[all.data$State %in% states$State,]
# Remove factor levels from states not mapped
map.data <- droplevels(map.data)
# View results (number of records per state)
table(map.data$State)
# Add FIPS code
map.data <- left_join(map.data, states)

#' ## Save data
#+ save data 
save(map.data, species.list, file = "data/output_data/map_data.R")

#' ### Document Footer
#' 
#' ezspin("programs/01_processing_data.R", out_dir = "output", fig_dir="figures", keep_md=F)
#' 
#+ footer
sessionInfo()