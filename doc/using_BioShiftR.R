## ----include = FALSE, message=FALSE-------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE, warning=FALSE--------------------------------------
library(BioShiftR)
library(dplyr)

## ----get shifts 1-------------------------------------------------------------
get_shifts() %>% glimpse()

## ----get shifts 2-------------------------------------------------------------
get_shifts(group = "Birds", 
           type = "LAT", 
           continent = "North America") %>% 
  glimpse()

## ----get shifts 3-------------------------------------------------------------
# count how many have positive rates (moving towards the poles)
get_shifts(group = "Birds", 
           type = "LAT", 
           continent = "North America") %>% 
  count(calc_rate > 0)

