# Header ----------------------------------------------------------------
# Project: Reef Archive
# File name: 01_process_media_data.R
# Last updated: 2026-09-26
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/reefarchive/collections

# Load libraries --------------------------------------------------------
library(readr)
library(dplyr)
library(lubridate)
library(stringr)

# Load data -------------------------------------------------------------
# Path to original collection metadata
dat <- read.csv("DiscoveryBay-Jamaica-1966-1968-EileenGraham/source/data.csv")
# Filter out images to NOT archive (poor quality images, images of people)
dat <- dat |>
       filter(Upload == TRUE)
# Define DOI (must be created via Zenodo first)
DOI <- "10.5281/zenodo.22663465"

# Process data ----------------------------------------------------------
dat <- dat |>
       # Add new file name
       mutate(fileName = sprintf("IMG%04d.png", 1:nrow(dat))) |>
       # Add mediaID
       mutate(mediaID = paste0(DOI, "-", fileName)) |>
       # Add collection Identifier
       mutate(collectionID = DOI) |>
       # Add collection name
       mutate(
              collectionName = "The Eileen Graham Collection (Discovery Bay, Jamaica, 1966 to 1968)."
       ) |>
       # Add type
       mutate(type = "StillImage") |>
       # Add citation
       mutate(
              bibliographicCitation = "Johnson, K. and Jones, L.A. (2026) Eileen Graham Collection, Discovery Bay, Jamaica (1966 to 1968). https://doi.org/10.5281/zenodo.22663465."
       ) |>
       # Add license
       mutate(
              license = "http://creativecommons.org/licenses/by/4.0/legalcode"
       ) |>
       # Add rights holder
       mutate(rightsHolder = "Trustees of the Natural History Museum") |>
       # Add captured by
       mutate(capturedBy = "Eileen Graham") |>
       # Add digitised by
       mutate(digitisedBy = "Kenneth Johnson") |>
       # Add processed by
       mutate(processedBy = "Lewis A. Jones") |>
       # Format timestamp
       mutate(
              DateTimeOriginal = if_else(
                     DateTimeOriginal == "",
                     NA,
                     DateTimeOriginal
              )
       ) |>
       # Add year
       mutate(year = year(DateTimeOriginal)) |>
       # Add month
       mutate(month = month(DateTimeOriginal)) |>
       # Add day
       mutate(day = day(DateTimeOriginal)) |>
       # Add habitat
       mutate(habitat = NA) |>
       # Add water body
       mutate(waterBody = "Caribbean Sea") |>
       # Add islandGroup
       mutate(islandGroup = "Greater Antilles") |>
       # Add island
       mutate(island = "Jamaica") |>
       # Add country
       mutate(country = "Jamaica") |>
       # Add countryCode
       mutate(countryCode = "JM") |>
       # Add state Province
       mutate(stateProvince = NA) |>
       # Add county
       mutate(county = "Saint Ann Parish, Middlesex County") |>
       # Add municipality
       mutate(municipality = "Discovery Bay") |>
       # Add locality
       mutate(locality = Locality) |>
       # Add longitude
       mutate(decimalLongitude = GPSLongitude) |>
       # Add latitude
       mutate(decimalLatitude = GPSLatitude) |>
       # Add georeference remarks
       mutate(
              georeferenceRemarks = "Exact coordinates unknown. Inferred from site map. Coordinates precise to approximately 0.0025 degress (~250 m)."
       ) |>
       # Add minimum depth in metres
       mutate(minimumDepthInMetres = NA) |>
       # Add maximum depth in metres
       mutate(maximumDepthInMetres = NA) |>
       # Add media comments
       mutate(mediaComments = NA) |>
       # Add modified
       mutate(modified = format(Sys.Date(), "%Y-%m-%d")) |>
       # Flag and infer year (1966)
       mutate(
              mediaComments = if_else(
                     is.na(year),
                     "Exact date unknown, likely between 1966 and 1968. 1966 used as inferred year.",
                     mediaComments
              )
       ) |>
       mutate(year = if_else(is.na(year), 1966, year)) |>
       # Flag and infer coordinates
       mutate(
              georeferenceRemarks = if_else(
                     decimalLongitude == 0 | is.na(decimalLongitude),
                     "Exact coordinates unknown, Discovery Bay Marine Lab used as point of reference.",
                     georeferenceRemarks
              )
       ) |>
       # Set invalid coordinates to match location of Discovery Bay Marine Lab
       mutate(
              decimalLongitude = if_else(
                     decimalLongitude == 0 | is.na(decimalLongitude),
                     -77.41543,
                     decimalLongitude
              ),
              decimalLatitude = if_else(
                     decimalLatitude == 0 | is.na(decimalLatitude),
                     18.468618,
                     decimalLatitude
              )
       ) |>
       # Select variables
       select(
              mediaID,
              fileName,
              collectionID,
              collectionName,
              type,
              bibliographicCitation,
              license,
              rightsHolder,
              capturedBy,
              digitisedBy,
              processedBy,
              year,
              month,
              day,
              habitat,
              waterBody,
              islandGroup,
              island,
              country,
              countryCode,
              stateProvince,
              county,
              municipality,
              locality,
              decimalLongitude,
              decimalLatitude,
              georeferenceRemarks,
              minimumDepthInMetres,
              maximumDepthInMetres,
              mediaComments,
              modified,
              OriginalRawFileName # Should be removed after image processing
       )
# Save data -------------------------------------------------------------
write_excel_csv(
       dat,
       "DiscoveryBay-Jamaica-1966-1968-EileenGraham/processed/media.csv",
       na = ""
)
