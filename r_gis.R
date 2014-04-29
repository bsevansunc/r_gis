#############################################################################
# R Workshop: Using R as a GIS
#############################################################################
# Date: 4/30/2014
# Author: Brian Evans
#
# Description: This file guides workshop participants through some simple
# and common GIS tasks. We will download and explore 4 km resolution minimum 
# temperature data from the PRISM climate group.
# (http://prism.oregonstate.edu/) 

#----------------------------------------------------------------------------
# Basic-setup
#============================================================================

# Install necessary packages (skip if present on your computer):

install.packages(c('gstat','raster','dismo','maps'), dependencies = T)


# Load libraries:

library(raster)
library(dismo)
library(gstat)
library(maps)


#----------------------------------------------------------------------------
# Acquiring and formatting data
#============================================================================

# Get a shapefile of the United States:

us = data('state')

#-----------------------------------------------------------------------
# Download a raster file from PRISM website:
# Note: These are minimum temperature data for 4/27/2014
# Steps in preparing the file for using in R:
#	a. Create an empty temp file for storage
#	b. Provide the website from which the data are retrieved
#	c. Download the file into the temp slot
#	d. PRISM data are provided as zip files, these must be unzipped
#	d. Convert to raster format
#	e. Specify projection information

# Create temporary storage location:

tmin = tempfile()

# Specify website:

ftp = 'ftp://prism.oregonstate.edu/daily/tmin/2014/PRISM_tmin_early_4kmD1_20140427_bil.zip'

# Download file:

download.file(ftp,tmin)

# Unzip:

tmin = unzip(tmin)

# Convert to raster format:

tmin = raster(tmin[1])

# Provide projection information:

crs(tmin) = "+proj=longlat +datum=WGS84"

#----------------------------------------------------------------------------
# Exploring the temperature raster
#============================================================================

# View raster summary data:

tmin

# Calculate a few descriptive statistics:

cellStats(tmin, 'mean')
cellStats(tmin, 'min')
cellStats(tmin, 'max')
cellStats(tmin, 'sd')
ncell(tmin)

# How are the temperature data distributed?

hist(tmin)

# Or ... for a better looking histogram that includes all cell values:

hist(tmin, maxpixels = ncell(tmin), freq = F,
	xlab = expression('Temperature ('*degree*C*')'),
	main = 'Minimum temperatures, 4/27/2014',
	cex.lab = 1.5, cex.main = 2,
	col = rev(rainbow(19)))

# Add a density lines to the plot

lines(density(tmin, plot = F), lwd = 3)

# Plot the raster:
# Note: If you aren't using RStudio, be sure to turn on the plot history

plot(tmin, ext = extent(tmin))

# Note: Does your plot have lots of white space?
# Just reshape your plot window!

# Add the states file as an overlay:

map(us, add = T)

# Change the color scheme:

plot(tmin, ext = extent(tmin), col = terrain.colors(255))

plot(tmin, ext = extent(tmin), col = rev(rainbow(100)), addfun = map(us, add=T))

# Note in the above: I added the states layer to the map in one function

# Calculate the value at a given point:

click(tmin)

# Hit 'Escape' to exit turn off the clicker

# Zoom into the map by clicking the upper left
# and lower right hand corner of a bounding box:

zoom(tmin,col = rev(rainbow(100)))

# Add the states again:

map(us, add = T)


#----------------------------------------------------------------------------
# Cropping the raster
#============================================================================

# Zoom back out to previous extent:

zoom(tmin, extent(tmin), addfun = map(us, add= T))

# Draw a new extent around the Southeastern US by clicking the upper left
# and lower right hand corner of a bounding box that contains the 
# Southeastern states:

e2 = drawExtent()

# Crop the raster to the new extent:

tmin_se = crop(tmin,e2)

# Plot the new reduced raster:

plot(tmin_se,col = rev(rainbow(100)), addfun = map(us, add= T))


#----------------------------------------------------------------------------
# Extracting data to points
#============================================================================

# Generate random points within the raster:

pts = randomPoints(tmin_se,500)

# These points can be converted to spatial points:

pts = SpatialPoints(pts)
crs(pts) = crs(tmin)

# Add the points to the map:

points(pts, pch = 21, cex = .75, col = 1, bg = 'white')

# You can extract at a given point location:

ext.1 = extract(tmin_se, pts)

# This can be directly appeneded to the points data frame:

pts = extract(tmin_se, pts, sp = T)

# View the data temperature data for the points:

head(pts)

# Terrible naming convention, so let's change it:

names(pts) = 'tmin'

# Or within a given radius (in meters) around the points:
# Not run:
# pts = extract(tmin_se, pts,buffer = 3000, sp = T, na.rm = T)


#----------------------------------------------------------------------------
# A simple interpolation (IDW)
#============================================================================

# Let's try to see how well our point data can do at predicting temperatures
# outside of the points (interpolation between point locations):

tmin_se.grid = as(tmin_se,'SpatialGridDataFrame')
tmin.idw = idw(tmin~1,pts, tmin_se.grid) 

tmin.idw.r = raster(tmin.idw)

# How did we do?

plot(tmin.idw.r,col = rev(rainbow(100)),addfun = map(us, add= T))

# Looks pretty terrible like most IDW!

# Compare with the real data:

plot(tmin_se,col = rev(rainbow(100)),addfun = map(us, add= T))


#----------------------------------------------------------------------------
# But you want to view the file more interactively?
#============================================================================

# There are lots of ways to explore maps interactively, one way that's fun
# is to share maps via Google Earth:

KML(tmin_se, 'tmin_se.kml', col = rev(rainbow(100)), colNA=NA)


#============================================================================

# This is, of course, just a few basic GIS tasks and really represents the
# tip-of-the-iceburg of what R can do as a GIS.
# Check out the following website to see the variety of packages and
# analyses available: http://cran.r-project.org/web/views/Spatial.html



