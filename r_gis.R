# Basic-setup

install.packages(c('gstat','raster','dismo','maps'))

library(raster)
library(dismo)
library(gstat)
library(maps)

# library(spatstat)

# Get a us map:

us = data('state')

# Download a RASTER file from PRISM website:

tmin = tempfile()

download.file('ftp://prism.oregonstate.edu/daily/tmin/2014/PRISM_tmin_early_4kmD1_20140427_bil.zip',tmin)

tmin = unzip(tmin)

# Read the raster file into R:

t2 = raster(tmin[1])

# Add projection information:

crs(t2) = "+proj=longlat +datum=WGS84"

#============================================================================
# Explore the raster
#============================================================================

# View information of the raster:

t2

# Calculate summary statistics:

cellStats(t2, 'mean')


# Plot the raster:

plot(t2, ext = extent(t2))

# Change the color scheme:

plot(t2, ext = extent(t2), col = terrain.colors(255))
plot(t2, ext = extent(t2), col = rev(rainbow(100)))

# Add the states overlay

map(us, add = T)

# Calculate the value at a given point (hit escape to exit):

click(t2)

# Zoom into the map (click 2 pts of a bounding box):

zoom(t2,col = rev(rainbow(100)), addfun = map(us, add= T))

#============================================================================
# Cropping 
#============================================================================

# Zoom back out to previous extent:

zoom(t2, extent(t2), addfun = map(us, add= T))

# Draw a new extent around North Carolina

e2 = drawExtent()

# Crop the raster to the new extent:

t3 = crop(t2,e2)

# Plot the new reduced raster:

plot(t3,col = rev(rainbow(100)), addfun = map(us, add= T))


#============================================================================
# Extracting data to points
#============================================================================

# Generate random points within the raster:

pts = randomPoints(t3,500)

# These points can be converted to spatial points

pts = SpatialPoints(pts)
crs(pts) = crs(t2)

# Add the points to the map:

points(pts, pch = 21, cex = .75, col = 1, bg = 'white')

# You can extract at a given point location:

ext.1 = extract(t3, pts)

# This can be directly appeneded to the points data frame:

pts = extract(t3, pts, sp = T)

# Terrible naming convention, so let's change it:

names(pts) = 'tmin'

# Or within a buffer:
# Not run:
# ext.b = extract(t3, pts, buffer = 10)


#============================================================================
# A simple interpolation (IDW)
#============================================================================

# Let's try to see how well our point data can do at predicting temperatures
# outside of the points (interpolation between point locations):

t3.grid = as(t3,'SpatialGridDataFrame')
tmin.idw = idw(tmin~1,pts, t3.grid) 

tmin.idw.r = raster(tmin.idw)

plot(tmin.idw.r,addfun = map(us, add= T))
plot(t3,addfun = map(us, add= T))


