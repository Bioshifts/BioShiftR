# Download spatial data from OSF

BioShiftR relies on data from multiple sources. Spatial polygon datasets
of all study areas, or species ranges within study areas are available
on \[Open Science Framework\]https://osf.io/tp4hv/files/osfstorage, but
need to be downloaded locally in order to use provided helper functions.
This function only needs to be run once

## Usage

``` r
download_polygons(type = "SA", directory = ".", timeout = 500, replace = F)
```

## Arguments

- type:

  choice of study area ("SA") polygons, or species range polygons
  clipped to individual study areas ("SP"). Species range polygons will
  be more resolute in large study areas, but will take longer to
  download and use more disc space.

- directory:

  directory within the project folder for polygon storage.

- timeout:

  timeout option if download fails. Increasing timeout may result in
  more stable downloads.

## Value

data folder for polygon storage

## Examples

``` r
if (FALSE) download_polyons(type = "SA") # \dontrun{}
```
