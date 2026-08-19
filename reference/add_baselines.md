# Add baseline temperatures of species- or study-area polygons for each range shift

Add baseline temperatures of species- or study-area polygons for each
range shift

## Usage

``` r
add_baselines(
  data,
  type = "SA",
  stat = c("mean"),
  res = c(LAT = "25km", ELE = "1km"),
  suffix = FALSE
)
```

## Arguments

- data:

  input data from get_shifts()

- type:

  Choice of baseline temperatures from study area (SA) or species area
  (SP) polygons.

- stat:

  Statistic of the given variable. Choices are "mean" and "sd".

- res:

  Calculation resolution. Baseline temperatures in each species/study
  area were calculated with environmental raster layers at up to four
  resolutions: 1km, 25km, 50km, 110km, resulting in slightly different
  values. Choose a specific resolution with one of: `"1km"`, `"25km"`,
  `"50km"`, `"110km"`.

- suffix:

  Binary choice to add the resolution on to baseline variable columns.
  Use this if you plan to add multiple baseline resolutions to the same
  dataset.

## Value

Shifts database supplemented with selected temperature baseline values
within the study area or species-specific study area.

## Examples

``` r
get_shifts() |> add_baselines()
#> # A tibble: 31,761 × 15
#>    id         article_id poly_id method_id eco   type  param sp_name_publication
#>    <chr>      <chr>      <chr>   <chr>     <chr> <chr> <chr> <chr>              
#>  1 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Ambloplites_rupest…
#>  2 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Ameiurus_nebulosus 
#>  3 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Chrosomus_eos      
#>  4 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Lepomis_gibbosus   
#>  5 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Lepomis_macrochirus
#>  6 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Luxilus_cornutus   
#>  7 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Micropterus_dolomi…
#>  8 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Micropterus_salmoi…
#>  9 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Notemigonus_crysol…
#> 10 A002_P1_L… A002       P1      M01       Ter   LAT   LE    Notropis_atherinoi…
#> # ℹ 31,751 more rows
#> # ℹ 7 more variables: sp_name_checked <chr>, subsp <chr>, calc_rate <dbl>,
#> #   calc_unit <chr>, direction <chr>, baseline_temp_mean <dbl>,
#> #   baseline_res <chr>
get_shifts(eco = "Mar") |> add_baselines(res = "25km")
#> Warning: Note: Marine realm includes intertidal species, to differentiate, further filtering is required.
#> # A tibble: 1,636 × 15
#>    id         article_id poly_id method_id eco   type  param sp_name_publication
#>    <chr>      <chr>      <chr>   <chr>     <chr> <chr> <chr> <chr>              
#>  1 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Cellana_nigrolinea…
#>  2 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Conus_ebraeus      
#>  3 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Diloma_suavis      
#>  4 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Echininus_cumingii 
#>  5 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Eugina_mendicaria  
#>  6 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Hormomya_mutabilis 
#>  7 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Modiolus_auriculat…
#>  8 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Montfortula_picta  
#>  9 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Morula_granulata   
#> 10 A042_P1_L… A042       P1      M01       Mar   LAT   LE    Nerita_albicilla   
#> # ℹ 1,626 more rows
#> # ℹ 7 more variables: sp_name_checked <chr>, subsp <chr>, calc_rate <dbl>,
#> #   calc_unit <chr>, direction <chr>, baseline_temp_mean <dbl>,
#> #   baseline_res <chr>
```
