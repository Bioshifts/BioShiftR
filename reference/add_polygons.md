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
add_polygons(data, type = "SA", directory = ".")
```

## Arguments

- data:

  range shift dataframe. Output of get_shifts() function.

- type:

  choice of study area ("SA") or species-level ("SP"; species range
  cropped to study area) polygons

## Value

range shift dataframe with a geometry column containing the study-level
or, when available, the species-specific polygon for each shift.

## Examples

``` r
if (FALSE) get_shifts(continent = "Africa") |> add_polygons() # \dontrun{}
```
