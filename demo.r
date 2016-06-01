aa <- seq(1:5)
aa
bb <- c("a", "b", "c", "d", "e")
bb
cc <- rep(10, 5)
cc
length(aa)
length(cc)
class(aa)
class(bb)
c(aa, bb, cc)

mat <- matrix(data=c(aa, bb, cc))
mat
mat <- matrix(data=c(aa, bb, cc), nrow = 5)
mat

mat[5, 2]
bb[3]

dat <- data.frame(x1=aa, x2=bb, x3=cc)

dat
str(dat)
names(dat)
names(dat) <- c("num", "letter", "count")
head(dat)

r <- runif(n=5, min=-180, max=180)
r
r2 <- runif(n=5, min=-90, max=90)

dat$X <- r
dat$Y <- r2
head(dat)

head(dat)
dim(dat)

plot(dat$X, dat$Y)

library(sp)

xy <- dat[ ,c("X", "Y")]

pts <- SpatialPointsDataFrame(coords=xy, data=dat)
pts
class(pts)
str(pts)

pts@proj4string <- CRS("+proj=longlat +datum=WGS84 +no_defs")
pts@proj4string

plot(pts)
pts@data

birds.df <- read.csv("/home/dmf/maptime-r/data/birds.csv", header=T)
head(birds.df)
birds <- SpatialPointsDataFrame(coords=birds.df[,c("lon", "lat")], 
                              data=birds.df, 
                              proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
plot(birds)

library(rgdal)
ogrDrivers()
setwd("maptime-r")
shp <- readOGR(dsn="data", layer="mtrainier")
str(shp)
plot(shp)

library(raster)
dem <- raster("extradata/srtm_12_03.tif")
# dem <- getData('SRTM', download=T, "data", lon=-121, lat=47)
plot(dem)
dem
projection(dem)
projection(shp)
shp.ll <- spTransform(shp, CRS(projection(dem)))

r <- crop(dem, shp.ll)
r
plot(r)
plot(shp.ll, add=T, border="red")

library(rasterVis)
levelplot(r)

levelplot(r, margin=F)
