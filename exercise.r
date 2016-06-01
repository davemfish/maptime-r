# Install packages if needed:

# packages <- c("rgdal", "rgeos", "leaflet", "RColorBrewer", "raster")
# install.packages(packages)

## load packages:
library(rgdal)
library(rgeos)
library(leaflet)
library(RColorBrewer)
library(raster)

## set a working directory
setwd("/home/dmf/maptime-r")

## load species data from a csv file
birds <- read.csv("data/birds.csv", header=T, stringsAsFactors=F)
## explore data
head(birds)
dim(birds)
names(birds)
## make a crude map by plotting xy coordinates
plot(x=birds$lon, y=birds$lat)

##############
# LEAFLET MAPS
##############

## 1) make a more useful map with leaflet:

# make sure the map centers on your data
# store the mean lon and lat to use in leaflet's setView()
x1 <- mean(birds$lon)
y1 <- mean(birds$lat)

## make a leaflet map
## high quality R leaflet tutorial: https://rstudio.github.io/leaflet/
m1 <- leaflet() %>% 
  setView(lng=x1, lat=y1, zoom=10) %>% 
  ## notice notation below: 
  ## '~' means "look for this name in the birds dataframe"  
  addCircleMarkers(data=birds, lng=~lon, lat=~lat,
                   fill=T,
                   fillColor="red",
                   fillOpacity=0.8,
                   opacity=0.8,
                   radius=5,
                   color="black",
                   weight=1) %>%
  addTiles()
print(m1)

## QUESTION: how many corvids in the dataset?
## use a conditional statement to identify rows where family == 'Corvidae'
ids <- which(birds$family == "Corvidae")
length(ids)
## the 'ids' object now holds the row numbers 
## for all elements of birds$family that met the condition
head(ids)
## use those row numbers to subset the birds dataframe:
corv <- birds[ids, ]


## 2) make leaflet map of the corvids & color the dots by species.

## how many different colors do I need?
unique(corv$species) # lists the unique values in the species column
ncol <- length(unique(corv$species))
ncol

## create a function to assign colors to species
# get the right number of colors from a palette
bpal <- brewer.pal(ncol, "Set2") 
bpal
# create a custom function for choropleth mapping:
# leaflet provides the useful colorFactor function
?colorFactor
spal <- colorFactor(palette=bpal, domain=corv$species)


m2 <- leaflet(data=corv) %>% 
  setView(lng=x1, lat=y1, zoom=10) %>% 
  addCircleMarkers(lng=~lon, lat=~lat,
                   fill=T,
                   fillColor=~spal(species), # here we call the color function
                   fillOpacity=0.8,
                   opacity=0.8,
                   radius=5,
                   color="black",
                   weight=1) %>%
  addTiles() %>%
  addLegend(pal = spal, values = ~species, opacity = 1)
print(m2)


##################
# OVERLAY ANALYSIS
##################

## Which watershed in Mt. Rainier has the most bird observations?
## we will intersect the bird points with watershed polygons
## and count number of points in each polygon

## load watershed boundary shapefile
watersheds <- readOGR(dsn="data", layer="mora_sheds")
## NOTE: if you were unable to install the rgdal package,
## use this line below instead of the readOGR line above:
# watersheds <- readRDS("data/watersheds.rds")

class(watersheds)
## plot the shapefile 
## the plot function recognizes the sp class object and knows what to do:
plot(watersheds)

## check the projection of the watersheds
watersheds@proj4string
## store projection for use later
wgs84ll <- watersheds@proj4string

## In order to do an 'intersection' with the polygons
## the points must also be an sp class object
## make the points into a sp class object
pts <- SpatialPointsDataFrame(coords=birds[,c("lon", "lat")], 
                              data=birds, 
                              proj4string = wgs84ll)
plot(pts)

## do overlay
pts.sheds <- over(pts, watersheds)

## now we have a table with same # of rows as the points, 
## but with the polygon attributes
head(pts.sheds)
dim(pts.sheds)

## count records in each watershed
table(pts.sheds$Name)
## improve the format:
freq <- data.frame(table(pts.sheds$Name))
names(freq) <- c("Name", "frequency")
freq

## CHALLENGE: which watershed has the most "Pileated Woodpecker" observations

#################
# RASTER ANALYSIS
#################

## use a digital elevation model to 
## find the elevation of each bird observation

## load a DEM:
dem <- raster("data/mora_dem.tif")
dem

## make the points into a sp class object
## you already did this if completed the "Overlay" section above.
pts <- SpatialPointsDataFrame(coords=birds[,c("lon", "lat")], 
                              data=birds, 
                              proj4string = wgs84ll)

## map the points on top of the DEM
plot(dem)
plot(pts, add=T)

## use the extract function to extract DEM values at each point:
?extract

el <- extract(dem, pts)
## explore the result:
summary(el)
class(el)
length(el)
hist(el, breaks=40)

## attach this new elevation vector to the birds dataframe
## confirm the vector has same number of elements as the dataframe has rows:
nrow(birds) == length(el)
## if so, it is safe to add the elevation vector as a column:
birds.el <- cbind(birds, el)
names(birds.el)
## rename that column:
names(birds.el)[10] <- "elevation"

## explore the new dataset with a boxplot:
boxplot(elevation ~ order, data=birds.el)

## try out ggplot for fancier plots:
library(ggplot2)
## ggplot help docs:
# http://docs.ggplot2.org/current/

ggbox <- ggplot(data=birds.el) +
  geom_boxplot(aes(x=order, y=elevation)) +
  theme(axis.text.x=element_text(angle=-45, vjust=0.5, size=10))
  
ggbox


