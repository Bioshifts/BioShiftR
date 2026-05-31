# Autoplot species range shifts from the BioShifts database

Quickly visualise range shift data in one of three ways: a per-study dot
plot, a distribution by range parameter, or a spatial polygon map.

## Usage

``` r
bs_autoplot(
  data = NULL,
  plottype = c("point", "boxplot", "map"),
  facet = NULL,
  polygon_folder = "./BioShiftR_polygons"
)
```

## Arguments

- data:

  Either a character vector of species names (e.g.
  `"Troglodytes_troglodytes"`, spaces or underscores accepted) *or* a
  range-shift data frame from
  [`get_shifts()`](https://bioshifts.github.io/BioShiftR/reference/get_shifts.md).
  When omitted the full database is used.

- plottype:

  One of `"point"` (per-study dot plot with group means), `"boxplot"`
  (distribution of rates by range parameter), or `"map"` (species
  polygons on a world map, coloured by shift rate). Partial matching is
  supported.

- facet:

  Optional column name (string) in `data` to use as a `facet_wrap()`
  grouping variable.

- polygon_folder:

  Path to locally-downloaded polygon files from
  `download_polygons(type = "SP")`. Only used when `plottype = "map"`.
  Defaults to `"./BioShiftR_polygons"`.

## Value

A ggplot2 object.

## Details

Currently not an exported function.

The function accepts input in two ways:

- **By species name** – pass a character vector of one or more
  `sp_name_checked` values as the first argument. The full database is
  queried automatically.

- **Pipe-in** – filter
  [`get_shifts()`](https://bioshifts.github.io/BioShiftR/reference/get_shifts.md)
  yourself (e.g., to species) and pipe the result in.

## Examples

``` r
if (FALSE) { # \dontrun{
# Quick single-species dot plot
bs_autoplot("Troglodytes_troglodytes", plottype = "point")

# Two species boxplot at once
bs_autoplot(c("Troglodytes_troglodytes", "Fringilla_coelebs"),
  plottype = "boxplot", facet = "sp_name_checked"
)

# Pipe-in style
get_shifts(group = "Birds", continent = "Europe") |>
  bs_autoplot(plottype = "point")


# Map requires downloaded polygons (see ?download_polygons)
download_polygons(type = "SP")
bs_autoplot("Troglodytes_troglodytes", plottype = "map")
} # }
```
