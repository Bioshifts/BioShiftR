# Adding Climate Variables

## Adding Climate Variables

``` r
library(BioShiftR)
library(dplyr)
```

Range shifts are hypothesized to be driven, in part, by changes in
climate variables that affect species’ ability to survive, expand to new
areas, or contract from their existing ranges. It is therefore logical
that changes in climate variables contribute to the range changes
documented in the BioShifts database.

The BioShifts team has standardized calculations for changes in
temperature within the geographical regions in which range shifts were
recorded (hereafter, study areas), and, when available, the overlapping
sections of study areas and known distribtion ranges of individual
species (hereafter, species-specific study areas). Within each study
area and species-specific study area, we provide baseline temperatures
over study durations, average trends (°C/year) in temperature over the
study period, and the spatial velocity of climate change across
latitudinal or elevational gradients (matching the gradient of each
associated range shift).

All climate data can be supplemented to selected range shifts with the
[`add_baselines()`](https://bioshifts.github.io/BioShiftR/reference/add_baselines.md),
[`add_trends()`](https://bioshifts.github.io/BioShiftR/reference/add_trends.md),
and
[`add_cv()`](https://bioshifts.github.io/BioShiftR/reference/add_cv.md)
functions, but raw climate data can also be accessed with
`data(climate_variables)`.

## Understanding Resolutions

Climate data originate from annual satellite-derived temperature layers
spanning to 1912 for terrestrial regions, and 1946 for marine regions,
and coarsened to four different spatial resolutions: 1km (for elevation
shifts only), 25km, 50km, and 110km grid cells. Summary statistics
calculated between the four different resolutions may vary in several
ways, so we allow users the option to access data from whichever
resolution they feel is appropriate.

These four resolutions offer different trade-offs, because they affect
both the variability of climate variables between grid cells (small
resolutions will vary more, especially in heterogeneous environments),
but they will also affect velocities, since climate velocity is
calculated as change in temperature / the spatial gradient of
environmental values. Larger grid cells will generally result in flatter
(smaller) spatial variability in temperature values, decreasing the
denominators of climate velocity, and therefore resulting in larger
velocity values, compared to climate velocity calculated between small
grid cells.
