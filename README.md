# Collections

This repository contains the code and structure for processing Reef Archive Data Packages.

## Structure

Each image collection receives its own designated folder and is structured accordingly:

```
collections/ # This repository
├── collection/          Name of specific collection (e.g. "RADP0001")
│ ├── README.md/         High-level metadata about the collection
│ ├── datapackage.json   Machine-readable description of the package and data dictionary
│ ├── media.csv          Metadata table, one row per image (1,447 rows, 31 columns)
│ └── media/             Image files, named <fileName>.<extension> (e.g. IMG0001.png)
```

