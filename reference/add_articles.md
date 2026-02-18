# Add article identifiers to range shift data

Add article identifiers to range shift data

## Usage

``` r
add_articles(data)
```

## Arguments

- data:

  Range shifts dataframe from the
  [`get_shifts()`](https://bioshifts.github.io/BioShiftR/reference/get_shifts.md)
  function

## Value

Range shifts dataframe supplemented with article identification
information for each shift: Author, DOI, and identifiers for the article
within other datasets (BioShifts V1 and CoRE database of range shifts).

## Examples

``` r
get_shifts(group = "Birds", continent = "Africa") |> add_articles() |> dplyr::glimpse()
#> Rows: 2
#> Columns: 17
#> $ id                  <chr> "A175_P1_LAT_O_M01", "A175_P2_LAT_O_M01"
#> $ article_id          <chr> "A175", "A175"
#> $ poly_id             <chr> "P1", "P2"
#> $ method_id           <chr> "M01", "M01"
#> $ eco                 <chr> "Ter", "Ter"
#> $ type                <chr> "LAT", "LAT"
#> $ param               <chr> "O", "O"
#> $ sp_name_publication <chr> "Hirundo_rustica", "Hirundo_rustica"
#> $ sp_name_checked     <chr> "Hirundo_rustica", "Hirundo_rustica"
#> $ subsp               <chr> NA, NA
#> $ calc_rate           <dbl> 3.45, -8.89
#> $ calc_unit           <chr> "km/year", "km/year"
#> $ direction           <chr> "Towards Poles", "Towards Equator"
#> $ article             <chr> "Ambrosini_al_2011_CR", "Ambrosini_al_2011_CR"
#> $ doi                 <chr> "10.3354/cr01025", "10.3354/cr01025"
#> $ id_bioshifts_v1     <dbl> 209, 209
#> $ id_core             <dbl> 424, 424
```
