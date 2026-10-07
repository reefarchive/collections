# Header ----------------------------------------------------------------
# Project: Reef Archive
# File name: 02_process_images.R
# Last updated: 2026-09-19
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/reefarchive/collections

# Load libraries --------------------------------------------------------
# install.packages("magick", "exiftoolr", "tidyverse", "stringr")
library(magick)
library(exiftoolr)
library(tidyverse)
library(stringr)

# First-time setup: downloads ExifTool if not already installed
# This should work (but I had to use a manual, local installation, L17)
# install_exiftool()
# install_exiftool(local_exiftool = "/Users/lewis/Downloads/ExifTool-13.59.pkg")
# Verify ExifTool is working
# exiftoolr::exif_version()

# Load media data
dat <- read.csv("DiscoveryBay-Jamaica-1966-1968-EileenGraham/processed/media.csv")
# Extract raw file name
OriginalRawFileName <- dat$OriginalRawFileName
# Remove and save
dat <- dat |>
  select(-OriginalRawFileName)
write_excel_csv(
       dat,
       "DiscoveryBay-Jamaica-1966-1968-EileenGraham/processed/media.csv",
       na = ""
)

# 0. Set up EXIF tags ---------------------------------------------------
# Resolve EXIF-specific format for tags
dat <- dat |>
  mutate(
    # Copyright
    Copyright = str_c("-Copyright=", rightsHolder, " (", license, ")"),

    # DateTimeOriginal
    DateTimeOriginal = format(
      as.Date(str_c(year, "-", month, "-", day)),
      "%Y:%m:%d 00:00:00"
    ),

    # If DateTimeOriginal not available, use placeholder of earliest date
    DateTimeOriginal = if_else(is.na(DateTimeOriginal), "1966:01:06 00:00:00", DateTimeOriginal),

    # Geographic coordinates
    GPSLongitude = abs(decimalLongitude),
    GPSLongitudeRef = if_else(decimalLongitude >= 0, "E", "W"),
    GPSLatitude = abs(decimalLatitude),
    GPSLatitudeRef = if_else(decimalLatitude >= 0, "N", "S"),

    # Water depth (row-wise mean of min/max, ignoring NAs; "" if both missing)
    WaterDepth = if_else(
      is.na(maximumDepthInMetres) & is.na(minimumDepthInMetres),
      "",
      as.character(rowMeans(cbind(maximumDepthInMetres, minimumDepthInMetres), na.rm = TRUE))
    ),

    # Subject Area
    GPSAreaInformation = pmap_chr(
      across(waterBody:locality),
      ~ str_c(unique(discard(c(...), \(x) is.na(x) | x == "")), collapse = " | ")
    ),

    # User comment
    UserComment = pmap_chr(
      across(c(georeferenceRemarks, mediaComments)),
      ~ str_c(unique(discard(c(...), \(x) is.na(x) | x == "")), collapse = " | ")
    )
  )

# 1. Directories --------------------------------------------------------
# Collection name
collection <- "DiscoveryBay-Jamaica-1966-1968-EileenGraham"
# Input directory
input_dir <- paste0(collection, "/source/img/")
# Output directory
output_dir <- paste0(collection, "/processed/media/")

# 2. Find all files -----------------------------------------------------
# Report number of files to process
message(length(OriginalRawFileName), " file(s) to process.")

# 3. Process image ------------------------------------------------------
# Run across data
for (i in seq_len(nrow(dat))) { 
  # Get file name
  fn <- dat$fileName[i]
  # Get file path
  fp <- paste0(input_dir, OriginalRawFileName[i])
  
  # If file doesn't exist, go to next image 
  # Some images are missing from the NHM repository. Cross referencing 
  # these with the sharepoint repository, these are mostly
  # completely dark images (assuming discarded for lack of use)
  if ( !file.exists(fp) ) next
  
  # Create image paths
  png_path <- paste0(output_dir, fn)
  
  # --- Build image derivatives first (data-free) ---
  # Load image
  img <- image_read(fp)
  # Remove existing exif data
  img <- image_strip(img)
  # Convert image depth, results in size reduction by ~75% without
  # notable changes in image quality
  img <- image_convert(img, format = "png", colorspace = "sRGB", depth = 8)
  # Save as PNG
  image_write(img, path = png_path, format = "png")
  
  # --- Build the full tag argument set ---
  tag_args <- c(
    "-all=",  # clear all existing metadata first
    paste0("-ImageUniqueID=", dat$mediaID[i]),
    paste0("-OriginalRawFileName=", dat$OriginalRawFileName[i]),
    paste0("-ImageDescription=", dat$collectionName[i]),
    paste0("-Copyright=", dat$Copyright[i]),
    paste0("-Artist=", dat$capturedBy[i]),
    paste0("-DateTimeOriginal=", dat$DateTimeOriginal[i]),
    paste0("-GPSAreaInformation=", dat$GPSAreaInformation[i]),
    paste0("-GPSLatitude=", abs(dat$GPSLatitude[i])),
    paste0("-GPSLatitudeRef=", dat$GPSLatitudeRef[i]),
    paste0("-GPSLongitude=", abs(dat$GPSLongitude[i])),
    paste0("-GPSLongitudeRef=", dat$GPSLongitudeRef[i]),
    # WaterDepth not available for this collection
    #paste0("-WaterDepth=", dat$WaterDepth[i], 
    paste0("-UserComment=", dat$UserComment[i]),
    "-overwrite_original"
    )

  # --- Apply tags to each output file (one exiftool call per file) ---
  exif_call(path = png_path,  args = tag_args)

}

# Report
message("Done. ", length(dat$fileName), " file(s) processed.")
