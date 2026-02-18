# Add climate variable trends to range shift dataframe

`add_trends()` supplements the range shifts dataframe with annual change
in climate trends (temperature and/or precipitation) within the study
areas or species-specific study areas of the shift detection over the
study duration.

## Usage

``` r
add_trends(
  data,
  type = "SA",
  stat = c("mean"),
  res = c(LAT = "25km", ELE = "1km")
)
```

## Arguments

- data:

  dataframe of BioShifts range shifts from
  [`get_shifts()`](https://bioshifts.github.io/BioShiftR/reference/get_shifts.md)
  function

- type:

  Type of area over which trends are calculated: Article study areas
  ("SA"), or study areas cropped to species' range polygons ("SP").

- stat:

  Statistic of climate trends to add c("mean","sd").

- res:

  Spatial resolution of climate grid cells with which the climate trends
  were calculated c("1km","25km","50km","110km"). Note that terrestrial
  latitudinal study areas are calculated at 1, 25, 50, 110km, marine
  latitudinal studies are calculated at 25, 50, 110km, and elevation
  studies are calculated only at 1km.

## Value

range shift dataframe supplemented with selected trends in temperature
(°C/year) or precipitation (inches ???!? / year) within study areas or
species-specific study areas throughout the duration of the original
study.

## Examples

``` r
get_shifts() |> add_trends() |> dplyr::glimpse()
#> Rows: 31,761
#> Columns: 16
#> $ id                  <chr> "A002_P1_LAT_LE_M01", "A002_P1_LAT_LE_M01", "A002_…
#> $ article_id          <chr> "A002", "A002", "A002", "A002", "A002", "A002", "A…
#> $ poly_id             <chr> "P1", "P1", "P1", "P1", "P1", "P1", "P1", "P1", "P…
#> $ method_id           <chr> "M01", "M01", "M01", "M01", "M01", "M01", "M01", "…
#> $ eco                 <chr> "Ter", "Ter", "Ter", "Ter", "Ter", "Ter", "Ter", "…
#> $ type                <chr> "LAT", "LAT", "LAT", "LAT", "LAT", "LAT", "LAT", "…
#> $ param               <chr> "LE", "LE", "LE", "LE", "LE", "LE", "LE", "LE", "L…
#> $ sp_name_publication <chr> "Ambloplites_rupestris", "Ameiurus_nebulosus", "Ch…
#> $ sp_name_checked     <chr> "Ambloplites_rupestris", "Ameiurus_nebulosus", "Ch…
#> $ subsp               <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ calc_rate           <dbl> 0.4579, 4.8519, -0.4789, 0.9116, 3.1590, 0.9326, 0…
#> $ calc_unit           <chr> "km/year", "km/year", "km/year", "km/year", "km/ye…
#> $ direction           <chr> "Expansion", "Expansion", "Contraction", "Expansio…
#> $ trend_temp_mean     <dbl> 0.01524297, 0.01524297, 0.01524297, 0.01524297, 0.…
#> $ trend_temp_var      <chr> "Mean Air Temperature", "Mean Air Temperature", "M…
#> $ trend_res           <chr> "25km", "25km", "25km", "25km", "25km", "25km", "2…
```
