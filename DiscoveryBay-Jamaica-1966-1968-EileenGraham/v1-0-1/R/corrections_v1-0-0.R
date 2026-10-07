# Header ----------------------------------------------------------------
# Project: Reef Archive
# File name: corrections_v1-0-0.R
# Last updated: 2026-09-26
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/reefarchive/collections

# Load libraries
library(dplyr)
library(tidygeocoder)
library(readr)

# Set file paths
collection <- "DiscoveryBay-Jamaica-1966-1968-EileenGraham"
file_name <- paste0(collection, ".zip")

# Unzip collection
unzip(zipfile = file.path(collection, "v1-0-0", "processed", file_name), 
      exdir = file.path(collection, "v1-0-1"))

# Read media file
media <- read.csv(file.path(collection, "v1-0-1", "media.csv"))

# Modify contents of media file
# Drop file extension
media$mediaID <- gsub(pattern = ".png", replacement = "", x = media$mediaID)
# Update collectionID
media$mediaID <- gsub(pattern = "10.5281/zenodo.22663465", replacement = "10.5281/zenodo.22663464", x = media$mediaID)
media$collectionID <- "10.5281/zenodo.22663464"
# Update reference
media$bibliographicCitation <- "Johnson, K. and Jones, L.A. (2026) Eileen Graham Collection, Discovery Bay, Jamaica (1966 to 1968). https://doi.org/10.5281/zenodo.22663464."

# Create locationIDs for mapping
media <- media |>
  group_by(decimalLongitude, decimalLatitude) |>
  mutate(locationID = cur_group_id()) |>
  ungroup()
# Geocode
locations <- media |> 
  select(locationID, decimalLongitude, decimalLatitude) |>
  distinct() |>
  reverse_geocode(long = "decimalLongitude", lat = "decimalLatitude", full_results = TRUE)
# Get matches
id <- match(x = media$locationID, table = locations$locationID)
# Update values
media <- media |>
  # Update with true values
  mutate(
    stateProvince = locations$state_district[id],
    county = locations$county[id],
    municipality = locations$city_district[id],
    municipality = if_else(is.na(municipality), locations$town[id], municipality),
    municipality = if_else(is.na(municipality), locations$village[id], municipality),
    municipality = if_else(is.na(municipality), locations$hamlet[id], municipality)
  ) |>
  select(-locationID) |>
  mutate(modified = Sys.Date())
  
# Create version 1.0.1 data package
dir.create(file.path(collection, "v1-0-1", "datapackage"))

# Write media data
write_excel_csv(media, 
  paste0(file.path(collection, "v1-0-1", "datapackage"), "/media.csv"),
  na = ""
)

# Move files
# datapackage.json
file.rename(from = paste0(file.path(collection, "v1-0-1"), "/datapackage.json"),
            to = paste0(file.path(collection, "v1-0-1", "datapackage"), "/datapackage.json"))
# README.md
file.rename(from = paste0(file.path(collection, "v1-0-1"), "/README.md"),
          to = paste0(file.path(collection, "v1-0-1", "datapackage"), "/README.md"))
# Media folder
file.rename(from = file.path(collection, "v1-0-1", "media"),
            to = file.path(collection, "v1-0-1", "datapackage", "media"))
# Delete old media file
unlink(paste0(file.path(collection, "v1-0-1"), "/media.csv"))






