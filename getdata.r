library(raster)
library(rgdal)

setwd("~/maptime-r")

dem <- getData('SRTM', download=T, "data", lon=-121, lat=47)
shp <- readOGR(dsn="data", layer="mtrainier")
projection(dem)
projection(shp)
shp.ll <- spTransform(shp, CRS(projection(dem)))

r <- crop(dem, shp.ll)
r
plot(r)
plot(shp.ll, add=T)
writeRaster(r, "mora_dem.tif")

library(rasterVis)
levelplot(r)

levelplot(r, margin=F)


library(rgbif)
head(name_lookup(query='Aves', rank="class", return="data"))
key <- name_suggest(q='Aves', rank='class')$key
occ_search(taxonKey=key, limit=20)
occ <- occ_search(limit=50000, taxonKey=212, hasCoordinate = T, geometry=c(-122.1295, 46.7078, -121.4428, 47.0011))
dat <- occ$data
write.csv(dat, "data/birds2.csv", row.names=F)

dat <- read.csv("data/birds2.csv", header=T)

names(dat)
dat2 <- dat[,c(1:4,22:29,34,69)]
dat3 <- dat2[,c(2:4,8:11,13:14)]
names(dat3)[2:3] <- c("lat", "lon")
write.csv(dat3, "data/birds.csv", row.names=F)


