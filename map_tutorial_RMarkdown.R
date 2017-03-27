---
title: 'Plotting Wisconsin ACT Scores with Geospatial Heatmap'
author: 'Sam Veverka'
date: '25 March 2017'
output:
  html_document:
    keep_md: true
    number_sections: true
    toc: true
    fig_width: 6.5
    fig_height: 4
    theme: cerulean
    highlight: pygments
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

#Introduction
This script is an attempt to utilize geospatial maps to display information. I will be using data from the Wisconsin Department of Public Instruction. The DPI has posted the Wisconsin school district geospatial files (GIS Shapefiles) which are necessary. 

The GIS shapefiles can be found at:
https://dpi.wi.gov/gis/school-district-boundaries/data


#Set Working Directory and Load Map Data
```{r, echo = FALSE, message = FALSE}
setwd("C:\\Users\\Samuel\\Documents\\R\\Excel Practice Sheets\\maps_tutorial\\WPI")
library(rgdal)
library(rgeos)

district_map <- readOGR(dsn = ".", layer = "tl_2013_55_unsd_scsd_harn")
```

The idea that

It's a good idea to check the map data. 

```{r}
names(district_map)
plot(district_map)
```



The map data includes the school district codes, which are unique identifies which can be used to tie data sets to this map data.
```{r}
head(district_map$DIST_CODE)
```


#Load Data to Display on Map

I will use the District average ACT scores for this exercise.

The ACT data can be found at:
https://dpi.wi.gov/wisedash/download-files/type?field_wisedash_upload_type_value=ACT&field_wisedash_data_view_value=All

```{r}
act <- read.csv("act.csv", stringsAsFactors = FALSE, header = TRUE)
head(act)
```


The ACT data has the district codes, which we can use to match the ACT scores to the appropriate school districts on the map.


To verify that all data matches, use the R operator %in%.

```{r}
district_map$DIST_CODE %in% act$DISTRICT_CODE
```


Use dplyr to add ACT data to map data.
```{r}
library(dplyr)

district_map@data <- left_join(district_map@data, act, by = c('DIST_CODE' = 'DISTRICT_CODE'))
```

Now I will check to verify that data is merged. Also, I want to verify that we have average act scores for all districts.
```{r}
names(district_map)
district_map$AVERAGE_SCORE
```

There are missing ACT scores, which are marked with asterisks. We will have to impute values, or in this case, NA values.

```{r}
district_map$AVERAGE_SCORE[district_map$AVERAGE_SCORE == "*"] <- NA
district_map$AVERAGE_SCORE <- as.numeric(district_map$AVERAGE_SCORE)
```

I will use classInt to create intervals.

```{r}
library(classInt)
breaks_quant <- classIntervals(district_map$AVERAGE_SCORE, n = 5, style = "quantile")
breaks <- breaks_quant$brks
```

We are now about ready to create the plot. First, however, I will use latticeExtra so that I can plot district with NA values in a different colors than those with average scores.

```{r}
library(latticeExtra)
spplot(district_map, "AVERAGE_SCORE", col.regions = pal, at = breaks, main = "Wisconsin ACT Scores by School District") +   layer_(sp.polygons(district_map, fill='black'))
```


Splitting scores into five quantiles is informative, but most scores will be around the national composite average, 21, so the first and fifth quantile will incorporate a much larger amount of scores than the middle three quantiles.


So in addition to plotting quantiles, I would also like to plot scores split by fixed intervals.

```{r}
pal <- brewer.pal(8, "BuGn")  # select 9
breaks_quant <- classIntervals(district_map$AVERAGE_SCORE, n = 8, style = "fixed",
                               fixedBreaks = c(14,16,18,20,22,24,26,28))
breaks <- breaks_quant$brks
breaks
spplot(district_map, "AVERAGE_SCORE", col.regions = pal, at = breaks, main = "Wisconsin ACT Scores by School District",
       colorkey = list(labels = list(labels= c("14","16","18","20","22","24","26","28"), width =2, cex = 1))) + 
  layer_(sp.polygons(district_map, fill='black'))
```






