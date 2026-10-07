# Enhancements to version v1-0-2

library(readr)
library(dplyr)

inDir <- "DiscoveryBay-Jamaica-1966-1968-EileenGraham/v1-0-1"
outDir <- "DiscoveryBay-Jamaica-1966-1968-EileenGraham/v1-0-2"
zipFile <- "DiscoveryBay-Jamaica-1966-1968-EileenGraham.zip"

unzip(file.path(inDir, zipFile), exdir = outDir)

media <- read.csv(file.path(outDir, "DiscoveryBay-Jamaica-1966-1968-EileenGraham", "media.csv"))

media <- media |>
  mutate(time = "", .after = day) |>
  mutate(depthRemarks = "No depth information available.", .after = maximumDepthInMetres) |>
  mutate(modified = Sys.Date())

# Write media data
write_excel_csv(media, 
  paste0(file.path(outDir, "DiscoveryBay-Jamaica-1966-1968-EileenGraham"), "/media.csv"),
  na = ""
)
