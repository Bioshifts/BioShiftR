# Get BioShifts Range Shifts - Start Here.

Get species' range shift values from the BioShifts database, filtered by
taxon, study type or geography. BioShifts includes range shift
observations of over 31,000 taxa within studies conducted around the
world, published between

## Usage

``` r
get_shifts(
  group = "All",
  realm = "All",
  continent = "All",
  type = c("LAT", "ELE")
)
```

## Arguments

- group:

  Rough taxonomic subgroups for which to pull bioshifts data. Options
  are Algae, Birds, Fish, Fungi, Mammals, Marine Invertebrates,
  Nonvascular Plants, Reptiles and Amphibians, Terrestrial
  Invertebrates, and Vascular Plants, or All (default). This shortcut is
  meant to provide a coarse subsetting for data exploration, but for
  more precise taxonomic filtering, see add_taxo().

- realm:

  Subset of study realms for which to uplaod range shift data. Options
  are "Mar" (marine), "Ter" (terrestrial), or "All" (default).

- continent:

  Continent of studies for which to upload BioShifts data. Options
  include "North America", "South America", "Africa", "Europe", "Asia",
  "Oceania", "High Seas", or "All".

- type:

  Gradient over which to extract range shifts. Options are "ELE" for
  elevational shifts, or "LAT" for latitudinal shifts.

## Value

Minimal data frame of calculated and author-reported species range shift
values.

## Examples

``` r
get_shifts()
#> # A tibble: 31,759 × 13
#>    id         article_id poly_id method_id eco   type  param sp_name_publication
#>    <chr>      <chr>      <chr>   <chr>     <chr> <chr> <chr> <chr>              
#>  1 A001_P1_E… A001       P1      M01       Ter   ELE   O     Aegithalos_caudatus
#>  2 A001_P1_E… A001       P1      M01       Ter   ELE   O     Certhia_familiaris 
#>  3 A001_P1_E… A001       P1      M01       Ter   ELE   O     Dendrocopos_major  
#>  4 A001_P1_E… A001       P1      M01       Ter   ELE   O     Dryocopus_martius  
#>  5 A001_P1_E… A001       P1      M01       Ter   ELE   O     Erithacus_rubecula 
#>  6 A001_P1_E… A001       P1      M01       Ter   ELE   O     Fringilla_coelebs  
#>  7 A001_P1_E… A001       P1      M01       Ter   ELE   O     Garrulus_glandarius
#>  8 A001_P1_E… A001       P1      M01       Ter   ELE   O     Nucifraga_caryocat…
#>  9 A001_P1_E… A001       P1      M01       Ter   ELE   O     Parus_ater         
#> 10 A001_P1_E… A001       P1      M01       Ter   ELE   O     Parus_caeruleus    
#> # ℹ 31,749 more rows
#> # ℹ 5 more variables: sp_name_checked <chr>, subsp_or_pop <chr>,
#> #   calc_rate <dbl>, calc_unit <chr>, direction <chr>
get_shifts(group = "Birds", continent = "Asia")
#> # A tibble: 80 × 13
#>    id         article_id poly_id method_id eco   type  param sp_name_publication
#>    <chr>      <chr>      <chr>   <chr>     <chr> <chr> <chr> <chr>              
#>  1 A048_P1_E… A048       P1      M01       Ter   ELE   LE    Eurylaimus_ochroma…
#>  2 A048_P1_E… A048       P1      M01       Ter   ELE   LE    Micropternus_brach…
#>  3 A048_P1_E… A048       P1      M01       Ter   ELE   LE    Oriolus_cruentus   
#>  4 A048_P1_E… A048       P1      M01       Ter   ELE   LE    Rhipidura_albicoll…
#>  5 A048_P1_E… A048       P1      M10       Ter   ELE   LE    Pellorneum_pyrroge…
#>  6 A048_P1_E… A048       P1      M11       Ter   ELE   LE    Phaenicophaeus_cur…
#>  7 A048_P1_E… A048       P1      M12       Ter   ELE   LE    Phylloscopus_trivi…
#>  8 A048_P1_E… A048       P1      M13       Ter   ELE   LE    Pycnonotus_flavesc…
#>  9 A048_P1_E… A048       P1      M14       Ter   ELE   LE    Reinwardtipicus_va…
#> 10 A048_P1_E… A048       P1      M02       Ter   ELE   LE    Alophoixus_ochrace…
#> # ℹ 70 more rows
#> # ℹ 5 more variables: sp_name_checked <chr>, subsp_or_pop <chr>,
#> #   calc_rate <dbl>, calc_unit <chr>, direction <chr>
get_shifts(continent = c("North America","South America"), type = "ELE")
#> # A tibble: 7,475 × 13
#>    id         article_id poly_id method_id eco   type  param sp_name_publication
#>    <chr>      <chr>      <chr>   <chr>     <chr> <chr> <chr> <chr>              
#>  1 A011_P1_E… A011       P1      M01       Ter   ELE   O     Abies_concolor     
#>  2 A011_P1_E… A011       P1      M01       Ter   ELE   O     Abies_magnifica    
#>  3 A011_P1_E… A011       P1      M01       Ter   ELE   O     Adenostoma_fascicu…
#>  4 A011_P1_E… A011       P1      M01       Ter   ELE   O     Aesculus_californi…
#>  5 A011_P1_E… A011       P1      M01       Ter   ELE   O     Amelanchier_alnifo…
#>  6 A011_P1_E… A011       P1      M01       Ter   ELE   O     Arbutus_menziesii  
#>  7 A011_P1_E… A011       P1      M01       Ter   ELE   O     Arctostaphylos_gla…
#>  8 A011_P1_E… A011       P1      M01       Ter   ELE   O     Arctostaphylos_nev…
#>  9 A011_P1_E… A011       P1      M01       Ter   ELE   O     Arctostaphylos_vis…
#> 10 A011_P1_E… A011       P1      M01       Ter   ELE   O     Artemisia_tridenta…
#> # ℹ 7,465 more rows
#> # ℹ 5 more variables: sp_name_checked <chr>, subsp_or_pop <chr>,
#> #   calc_rate <dbl>, calc_unit <chr>, direction <chr>
```
