# Add polygons to range shift database

Each individual range shifts in the BioShifts database is associated
with 1-2 spatial polygons. First, all shifts are associated with
polygons of the study area, or the area sampled within the original
article. Second, many shifts are associated with a species-specific
polygon, or a polygon of the study area cropped to the polygon of the
species range, when available. add_polygons allows users to merge
spatial dataframes to selected range shift collections produced by the
get_shifts() function. Requires download_polygons() to be used prior.

## Usage

``` r
add_polygons(data, type = "SA", polygon_folder = "./BioShiftR_polygons")
```

## Arguments

- data:

  range shift dataframe. Output of get_shifts() function.

- type:

  choice of study area ("SA") or species-level ("SP"; species range
  cropped to study area) polygons

- polygon_folder:

  location of locally-downloaded geopackages for BioShifts polygons.
  Defaults to "./BioShiftR_polygons" from the
  [`download_polygons()`](https://bioshifts.github.io/BioShiftR/reference/download_polygons.md)
  function, but requires specification if the user selected a custom
  location in the download function.

## Value

range shift dataframe with a geometry column containing the study-level
or, when available, the species-specific polygon for each shift.

## Examples

``` r
if (FALSE) { # \dontrun{
get_shifts(continent = "Africa") |> add_polygons()
} # }
```
