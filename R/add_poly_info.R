#' Add polygon attributes to range shift dataframe
#'
#' This function supplements range shift observations ()
#'
#'
#' @param data Range shifts dataframe from `get_shifts()` function
#' @param type Specification for study area polygon info ("SA"), or species-specific study area polygon info ("SP")
#'
#' @returns Range shift dataframe supplemented with columns on spatial extent of study or species-specific polygons.
#' @export
#'
#' @examples get_shifts() |> add_poly_info(type = "SA") |> dplyr::glimpse()
add_poly_info <- function(data, type = "SA"){


  poly_info <- switch(
    type,
    "SA" = readRDS(system.file("extdata", "poly_info.rds", package = "BioShiftR")),
    "SP" = readRDS(system.file("extdata", "poly_info.rds", package = "BioShiftR"))
  )

  merged <- switch(
    type,
    "SA" = data |> dplyr::left_join(poly_info, by = dplyr::join_by(article_id, poly_id))
  )

  return(merged)

}
