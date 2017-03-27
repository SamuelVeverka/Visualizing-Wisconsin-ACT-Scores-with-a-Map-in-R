setwd("C:\\Users\\Samuel\\Documents\\R\\Excel Practice Sheets\\maps_tutorial\\WPI")

library(rgdal)
district_map <- readOGR(dsn = ".", layer = "tl_2013_55_unsd_scsd_harn")
names(district_map)
plot(district_map)
head(district_map$DIST_CODE)
# Load the library
library(RColorBrewer)

#display all sequential color schemes now available
display.brewer.all(type = "seq")

pal <- brewer.pal(8, "OrRd")  # we select 5 colors from the palette
spplot(district_map, "LOGRADE", col.regions = pal, cuts = 4)


act <- read.csv("act.csv", stringsAsFactors = FALSE, header = TRUE)
head(act)

district_map$DIST_CODE %in% act$DISTRICT_CODE

library(dplyr)

district_map@data <- left_join(district_map@data, act, by = c('DIST_CODE' = 'DISTRICT_CODE'))

names(district_map)
district_map$AVERAGE_SCORE


district_map$AVERAGE_SCORE[district_map$AVERAGE_SCORE == "*"] <- NA
district_map$AVERAGE_SCORE <- as.numeric(district_map$AVERAGE_SCORE)

library(classInt)

# determine the breaks
breaks_quant <- classIntervals(district_map$AVERAGE_SCORE, n = 5, style = "quantile")

# add a very small value to the top breakpoint, and subtract from the bottom
# for symmetry
breaks <- breaks_quant$brks

# plot

library(latticeExtra)
spplot(district_map, "AVERAGE_SCORE", col.regions = pal, at = breaks, main = "Wisconsin ACT Scores by School District") +   layer_(sp.polygons(district_map, fill='black'))








pal <- brewer.pal(8, "BuGn")  # select 9
breaks_quant <- classIntervals(district_map$AVERAGE_SCORE, n = 8, style = "fixed",
                               fixedBreaks = c(14,16,18,20,22,24,26,28))
breaks <- breaks_quant$brks
breaks
spplot(district_map, "AVERAGE_SCORE", col.regions = pal, at = breaks, main = "Wisconsin ACT Scores by School District",
       colorkey = list(labels = list(labels= c("14","16","18","20","22","24","26","28"), width =2, cex = 1))) + 
  layer_(sp.polygons(district_map, fill='black'))


