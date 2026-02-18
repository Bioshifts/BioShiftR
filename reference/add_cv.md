# Add Climate Velocity to shifts dataframe

Add Climate Velocity to shifts dataframe

## Usage

``` r
add_cv(data, type = "SA", stat = c("mean"), res = c(LAT = "25km", ELE = "1km"))
```

## Arguments

- data:

  Shifts dataframe from get_shifts() function

- type:

  Choice of climate velocity values from study area (SA) or
  species-speficic study area (SP) polygons

- stat:

  Statistic of climate velocity to add. c("q25", "median", "mean",
  "q75", "sd").

- res:

  Spatial resolution with which climate velocities were calculated
  c("1km","25km","50km","110km"). Note that higher resolutions will
  generally have higher velocities, since climate velocity is calculated
  as climate trend / spatial gradient.

## Value

dataframe of range shifts supplemented with selected columns of climate
velocity.

## Examples

``` r
get_shifts() |> add_cv(stat = c("mean"),res = c("LAT" = "25km", "ELE" = "1km")) |> dplyr::glimpse()
#> Rows: 31,761
#> Columns: 17
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
#> $ along_gradient      <chr> "latitude", "latitude", "latitude", "latitude", "l…
#> $ cv_temp_mean        <dbl> 1.393522, 1.393522, 1.393522, 1.393522, 1.393522, …
#> $ cv_temp_var         <chr> "Mean Air Temperature", "Mean Air Temperature", "M…
#> $ cv_res              <chr> "25km", "25km", "25km", "25km", "25km", "25km", "2…
```
