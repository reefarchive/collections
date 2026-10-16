# install.packages("zip")
library(zip)

# Set file path
collection <- "DiscoveryBay-Jamaica-1966-1968-EileenGraham"
version <- "v1-0-2"
pkg_dir <- file.path(collection, version, collection)
cur_dir <- getwd()
setwd(pkg_dir)

# Set file name
zip_file <- paste0(collection, ".zip")

# List every file, including hidden ones
files <- list.files(".", recursive = TRUE, all.files = TRUE, include.dirs = FALSE)

# Drop macOS junk
junk <- grepl("(^|/)\\.DS_Store$", files) |
        grepl("(^|/)\\._", files) |
        grepl("(^|/)__MACOSX/", files)
files <- files[!junk]

# Overwrite any existing zip, keep paths relative to the folder's parent
if (file.exists(zip_file)) file.remove(zip_file)
zip::zip(
  zipfile = file.path("..", zip_file),
  files = files,
  mode = "mirror"
)

# Check the contents
zip::zip_list(file.path("..", zip_file))$filename

setwd(cur_dir)
