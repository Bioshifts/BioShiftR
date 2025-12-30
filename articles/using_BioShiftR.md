# Using BioShiftR

## Using BioShiftR

``` r
library(BioShiftR)
library(dplyr)
```

BioShiftR is a helper package to facilitate easy use and manipulation of
the BioShifts database, which includes over 31,000 species’ range shift
documentations from published scientific literature, as well as
methodological, taxonomic, and climate variables within study regions
and, when available, within study regions clipped to species’ ranges.

Use this package’s helper functions to easily merge, subset, and
manipulate the dataset for data organization and hypothesis testing.
This vignette covers the workflow for censusing shifts and adding
relevant parameters.

### Get BioShifts Shifts

All BioShiftR workflows should begin with the
[`get_shifts()`](https://bioshifts.github.io/BioShiftR/reference/get_shifts.md)
function, which uploads all, or a subset of, the 31,759 range shift
observations within the BioShifts database. This function returns a
minimal dataset showing only the range shift rates across latitude or
elevation (`calc_rate`), as calculated in BioShifts in either m/year for
elevational shifts, or km/year for latitudinal shifts (`calc_unit`), and
necessary identifiers which connect to all other datasets.

``` r
get_shifts() %>% glimpse()
#> Rows: 31,759
#> Columns: 13
#> $ id                  <chr> "A001_P1_ELE_O_M1", "A001_P1_ELE_O_M1", "A001_P1_E…
#> $ article_id          <chr> "A001", "A001", "A001", "A001", "A001", "A001", "A…
#> $ poly_id             <chr> "P1", "P1", "P1", "P1", "P1", "P1", "P1", "P1", "P…
#> $ method_id           <chr> "M01", "M01", "M01", "M01", "M01", "M01", "M01", "…
#> $ eco                 <chr> "Ter", "Ter", "Ter", "Ter", "Ter", "Ter", "Ter", "…
#> $ type                <chr> "ELE", "ELE", "ELE", "ELE", "ELE", "ELE", "ELE", "…
#> $ param               <chr> "O", "O", "O", "O", "O", "O", "O", "O", "O", "O", …
#> $ sp_name_publication <chr> "Aegithalos_caudatus", "Certhia_familiaris", "Dend…
#> $ sp_name_checked     <chr> "Aegithalos_caudatus", "Certhia_familiaris", "Dend…
#> $ subsp_or_pop        <chr> "Giffre Valley", "Giffre Valley", "Giffre Valley",…
#> $ calc_rate           <dbl> -2.2128, -0.5106, -7.8723, -3.2340, 4.8511, -1.319…
#> $ calc_unit           <chr> "m/year", "m/year", "m/year", "m/year", "m/year", …
#> $ direction           <chr> "Lower Elevation", "Lower Elevation", "Lower Eleva…
```

[`get_shifts()`](https://bioshifts.github.io/BioShiftR/reference/get_shifts.md)
has some built-in defaults to subset shifts by type, broad taxonomic
groups, or continents. See the function help page for more options.

For example, to select only latitudinal range shifts of birds in North
America, we could use the following arguments.

``` r
get_shifts(group = "Birds", 
           type = "LAT", 
           continent = "North America") %>% 
  glimpse()
#> Rows: 2,382
#> Columns: 13
#> $ id                  <chr> "A009_P1_LAT_LE_M1", "A009_P1_LAT_LE_M1", "A009_P1…
#> $ article_id          <chr> "A009", "A009", "A009", "A009", "A009", "A009", "A…
#> $ poly_id             <chr> "P1", "P1", "P1", "P1", "P1", "P1", "P1", "P1", "P…
#> $ method_id           <chr> "M01", "M01", "M01", "M01", "M01", "M01", "M01", "…
#> $ eco                 <chr> "Ter", "Ter", "Ter", "Ter", "Ter", "Ter", "Ter", "…
#> $ type                <chr> "LAT", "LAT", "LAT", "LAT", "LAT", "LAT", "LAT", "…
#> $ param               <chr> "LE", "LE", "LE", "LE", "LE", "LE", "LE", "LE", "L…
#> $ sp_name_publication <chr> "Accipiter_cooperii", "Accipiter_striatus", "Actit…
#> $ sp_name_checked     <chr> "Accipiter_cooperii", "Accipiter_striatus", "Actit…
#> $ subsp_or_pop        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ calc_rate           <dbl> 13.78, 0.18, 1.92, 0.51, 0.35, 6.48, 14.71, 0.61, …
#> $ calc_unit           <chr> "km/year", "km/year", "km/year", "km/year", "km/ye…
#> $ direction           <chr> "Expansion", "Expansion", "Expansion", "Expansion"…
```

Or we could do the same and quickly assess the number of latitudinal
bird shifts in North America that have positive rates (moving towards
the poles):

``` r
# count how many have positive rates (moving towards the poles)
get_shifts(group = "Birds", 
           type = "LAT", 
           continent = "North America") %>% 
  count(calc_rate > 0)
#> # A tibble: 2 × 2
#>   `calc_rate > 0`     n
#>   <lgl>           <int>
#> 1 FALSE             948
#> 2 TRUE             1434
```

### Understanding IDs

Because the minimal shifts dataframe connects to several other
dataframes (see below), each containing data at different levels (e.g.,
some additional information is at the “source article” level, while some
is at the species or shift level), the minimal database contains five
separate ID columns (`article_id`, `poly_id`, `type`, `param`, and
`method_id`), which collectively make up the `group_id` column. These
identifiers are nested such that each consecutive ID can– but doesn’t
always– contain multiple of the next value. In other words, some
articles contain multiple polygons, some polygons contain range shifts
of multiple types, some range shift of the same type are studied at
multiple range parameters, and so on. Different combinations of these
identifiers merge the minimal shifts dataset to all other BioShifts
data, and they are designed such that within a single group ID, a
species/subspecies will never be represented more than once.

| ID Column    | Format                   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
|--------------|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`         | `AXXX_PX_type_param_MXX` | summary ID value, arranged as `article_poly_type_param_method`.                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `article_id` | `A001`, `A002`, … `A244` | Identifier for the source publication in which the range shifts were originally documented.                                                                                                                                                                                                                                                                                                                                                                                                           |
| `poly_id`    | `P1`, `P2`, … `P9`       | Identifier for the polygon within the source publication in which range shifts were documented. Most publications have one polygon (P1), but can have multiple when a publication detects range shifts in multiple locations (e.g., two separate mountains, three ocean basins, etc.)                                                                                                                                                                                                                 |
| `type`       | `LAT`, `ELE`             | Identifier for the type of range shift – latitudinal or elevational – detected within a polygon. Usually, studies detect only one type of range shift, but in some cases census both.                                                                                                                                                                                                                                                                                                                 |
| `param`      | `LE`, `O`, `TE`          | Identifier for the parameter of the species’ range where the shift was detected: Leading Edge (LE), Trailing edge (TE), or range center (O). Here defined as the poleward or upslope edge, the equatorward or downslope edge, and various definitions of the range center (midpoint, center of gravity, etc.), respectively.                                                                                                                                                                          |
| `method_id`  | `M01`, `M02`, … `M24`    | Identifier for the method, within previous groups, of the range shifts detected. Usually, studies use only one method for all range shifts (M1), but in some cases, studies census range shifts across multiple timeframes (for example, 1950-1975, 1975-2000, 1950-2000), or by two different statistical methods (mean occurrence and median occurrence), resulting in detections with identical values of all preceding columns. Here, these cases will be separated into `_M1`, `_M2`, and so on. |

### Add BioShifts data

`BioShiftR` includes various helper functions – to be used individually
or together – that supplement the dataset from the
[`get_shifts()`](https://bioshifts.github.io/BioShiftR/reference/get_shifts.md)
function with other relevant data. View the table below to see all
funcitons and the respective information that they add to the shifts
dataframe. Each function adds directly to the shifts dataframe by
combinations of ID keys. Some require additional arguments to specify
data requests. See function help pages for details.

| Function                                                                | Description                                                                                                                                                                                                                                                                                                           | New Column Names                                                                                                                                                                                                                                                                                |
|-------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `add_articles(data)`                                                    | Adds information identifying the source article for each specific shift                                                                                                                                                                                                                                               | `article`, `doi`, `id_bioshifts_v1`, `id_core`                                                                                                                                                                                                                                                  |
| `add_author_reported(data)`                                             | BioShifts recalculates range shifts as rates across latitude or elevation, and displays calculated rates in the [`get_shifts()`](https://bioshifts.github.io/BioShiftR/reference/get_shifts.md) function. This function adds columns identifying the original shift as reported by study authors.                     | `author_reported`, `author_reported_unit`, `author_reported_sig`, `author_reported_magnitude`, `author_reported_angle`, `author_source`                                                                                                                                                         |
| `add_methods(data)`                                                     | Shifts are measured using various methods which may affect the variability of detected shift rates. This function adds methodological parameters by which each individual shift was detected                                                                                                                          | `start_firstperiod`, `midpoint_firstperiod`, `end_firstperiod`, `start_secondperiod`, `midpoint_secondperiod`, `end_secondperiod`, `n_periods`, `duration`, `grain_size`, `sampling`, `category`, `obs_type`, `uncertainty_distribution`, `position_definition`, `position_definition_category` |
| `add_baselines(data, type, stat, exp, res)`                             | Adds the average(???) climate variable values (mean temperature or precipitation) within the study area (or the species-specific study area, see \_\_\_), over the study duration.                                                                                                                                    | Variable combinations of statistic and exposure variable formatted as `baseline_stat_exposure` (e.g., `baseline_mean_temp()`). Also `baseline_res` for the spatial resolution over which variables were calculated. See “Adding Climate Variables” for details.                                 |
| `add_trends(data, type, stat, exp, res)`                                | Adds the average change per year of climate variables (temperature or precipitation) in the study area (or species-specific study area) over the study duration. See “Adding climate Variables” vignette for more                                                                                                     | Variable. Combinations of `trend_stat_exposure` (e.g., `trend_mean_temp`) for all requested trends, `trend_temp_var`, and `trend_res`.                                                                                                                                                          |
| [`add_cv()`](https://bioshifts.github.io/BioShiftR/reference/add_cv.md) | Adds the velocity of climate variables (temperature and precipitation) over space in the latitudinal or elevational directions within study area or species-specific study area over the study duration. See “Adding Climate Variables” vignette for more.                                                            | Variable combinations of `VelAlong_stat_exposure` (e.g., `VelAlong_mean_temp`) for all requested climate velocities, `cv_temp_var`, and `cv_res`. See “Adding Climate Variables” vignette for more.                                                                                             |
| `add_poly_info(data, type)`                                             | Supplements shifts dataframe with summary information of the study area or species-specific study area polygon in which each shift was detected. See “Working with Polygons” vignette for more.                                                                                                                       | `lat_min`, `lat_max`, `lat_cent_deg`, `lon_cent_deg`, `lat_extent_km`, `ele_mean_m`, `ele_min_m`, `ele_max_m`, `ele_extent_m`, `area_km2`, `study_area`                                                                                                                                         |
| `add_polygons(data, type)`                                              | Supplements shifts dataframe with spatial polygons of study areas or species-specific study areas over which shifts were calculated. Note that this requires polygons to be downloaded locally with the [`download_polygons()`](https://bioshifts.github.io/BioShiftR/reference/download_polygons.md) function first. | `geom`                                                                                                                                                                                                                                                                                          |

Each `add_` function adds on to the minimal shifts dataframe from
[`get_shifts()`](https://bioshifts.github.io/BioShiftR/reference/get_shifts.md),
using combinations of identifiers (`id`, `article_id`, `poly_id`,
`method_id`, `eco`, `param`), and, when relevant, species names
(`sp_name_publication`, `subsp_or_pop`). Different sub-dataframes
connect to the shifts dataframe using different id keys (e.g.,
[`add_articles()`](https://bioshifts.github.io/BioShiftR/reference/add_articles.md)
connects by `article_id` but
[`add_poly_info()`](https://bioshifts.github.io/BioShiftR/reference/add_poly_info.md)
connects by `article_id`, `poly_id`, and if requested,
`sp_name_publication` and `subsp_or_pop`). These functions automate the
merging of subdataframes to correctly match the shifts dataframe with
any requested additional information.
