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
temperature and precipitation within the geographical regions that range
shifts were recorded (hereafter, study areas), and, when available,
within the study areas cropped to the range of the individual species
(hereafter, species-specific study areas). within each study area and
species-specific study area, we provide baseline temperature and
precipitation over individual study durations, average trends
(change/year) in temperature and precipitation, and the spatial velocity
of climate change (km/year??) across latitudinal or elevational
gradients (matching the gradient of each associated range shift).

All climate data can be supplemented to selected range shifts with the
[`add_baselines()`](https://bioshifts.github.io/BioShiftR/reference/add_baselines.md),
[`add_trends()`](https://bioshifts.github.io/BioShiftR/reference/add_trends.md),
and
[`add_cv()`](https://bioshifts.github.io/BioShiftR/reference/add_cv.md)
functions, but raw climate data can also be accessed with
`data(climate_variables)`.

## Understanding Resolutions

Climate data were collected and caculated with \[\[satelite??\]\] data
at four different resolutions: 1km, 25km, 50km and 110km. Summary
statistics calculated between the four different resolutions may vary in
several ways, so we allow users the option to access data from whichever
resolution they feel is appropriate.

These four resolutions offer different trade-offs, because they affect
both the variability of climate variables between grid cells (small
resolutions will vary more, especially in heterogenous environments),
but they will also affect velocities, since climate velocity is
calculated as change in trends / spatial gradient of environmental
values. Larger grid cells will generally result in flatter (smaller)
spatial variability in temperature values, decreasing the denominators
of climate velocity, and therefore resulting in larger velocity values,
compared to climate velocity calculated between small grid cells.
