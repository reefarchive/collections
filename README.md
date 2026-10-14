# Collections

This repository contains the code and structure for processing Reef Archive Data Packages.

## Structure

Each image collection receives its own designated folder and is structured accordingly:

```
collections/ # This repository
├── collection/ # Name of specific collection
│ ├── v1-0-0/ # Version of the collection release
│ │ ├── R/ # Related R scripts for processing/updating collection
│ │ ├── source/ # Original images, data, and associated files (if version 1.0.0)
│ │ ├── processed/ # Processed images, data, and associated files (if version 1.0.0)
│ │ └── collection.zip # Compressed zip file of the collection i.e. processed (a Reef Archive Data Package)
│ ├── v1-0-1/ # Version of the collection release
│ │ ├── R/ # Related R scripts for processing/updating collection
│ │ ├── collection/ # Collection images, data, and associated files
│ │ └── collection.zip # Compressed zip file of the collection (a Reef Archive Data Package)
```

## Naming convention

[Location]-[Country]-[From]-[To]-[Author]

 > DiscoveryBay-Jamaica-1966-1968-EileenGraham

