# maptime-r
This repo includes materials for an R tutorial for the Maptime Seattle group. If you are another Maptime group and would like to re-use these materials, please do so.

# Follow these steps to get setup for Maptime
## Install R
See the download links at the top of this page:

https://cran.r-project.org/

## Install Rstudio Desktop
make sure you have already installed R (see above)

https://www.rstudio.com/products/rstudio/download/

## Install the packages we will use
Start RStudio (or R) and copy/paste these commands into the command prompt:

`packages <- c("rgdal", "rgeos", "leaflet", "RColorBrewer", "raster", "ggplot2")`

`install.packages(packages)`

The first time you install a package, you will get a prompt to select a 'mirror' from which to download the files.
There is always one or two options in 'USA (WA)', so select one of those.

You may also get a prompt that asks if you wish to create a new directory in which to store the package files. Say yes.

If any particular package fails to install (in particular rgdal or rgeos) don't worry. 
We can complete most of the tutorial without these packages if necessary.

## Download the contents of this repository 
