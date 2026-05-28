#' Add polygons to range shift database
#'
#' Each individual range shifts in the BioShifts database is associated with 1-2 spatial polygons. First, all shifts are associated with polygons of the study area, or the area sampled within the original article. Second, many shifts are associated with a species-specific polygon, or a polygon of the study area cropped to the polygon of the species range, when available. add_polygons allows users to merge spatial dataframes to selected range shift collections produced by the get_shifts() function. Requires download_polygons() to be used prior.
#'
#' @param data range shift dataframe. Output of get_shifts() function.
#' @param type choice of study area ("SA") or species-level ("SP"; species range cropped to study area) polygons
#' @param polygon_folder location of locally-downloaded geopackages for BioShifts polygons. Defaults to "./BioShiftR_polygons" from the `download_polygons()` function, but requires specification if the user selected a custom location in the download function.
#'
#' @returns range shift dataframe with a geometry column containing the study-level or, when available, the species-specific polygon for each shift.
#' @export
#'
#' @examples \dontrun{get_shifts(continent = "Africa") |> add_polygons()}
add_polygons <- function(data,
                         type = "SA",
                         polygon_folder = "./BioShiftR_polygons"){

  # make sure data has correct necessary ids for matching
  if(type == "SA" & !all(c("article_id", "poly_id") %in% colnames(data))){
    stop("ID key missing; input requires: article_id, poly_id", call.=FALSE)
  }
  if(type == "SP" & !all(c("article_id", "poly_id", "sp_name_checked") %in% colnames(data))){
    stop("ID key missing; input requires: article_id, poly_id, sp_name_checked", call.=FALSE)
  }


  filename <- switch(type,
                     "SA" = "sa_polygons_simplified.rds",
                     "SP" = "sp_polygons_simplified.rds")

  # make path to polygons (specified folder / filename)
  path <- file.path(polygon_folder, filename)

  # make sure polygon gpkg exists in working directory or is specified
  if(!file.exists(path)){
    stop("Polygons not found locally. Please use download_polygons(), or specify directory if they are downloaded outside of the defaul directory: ./BioShiftR_polygons.", call.=FALSE)
  }

  polys <- readRDS(path)

  return <- switch(
    type,
    "SA" = data |>
      dplyr::left_join(polys,
                       by = dplyr::join_by(article_id, poly_id)) |>
      sf::st_as_sf(),
    "SP" = data |> dplyr::left_join(polys,
                             by = dplyr::join_by(article_id, poly_id, sp_name_checked)) |>
      sf::st_as_sf()
  )

  # if species-specific polygons were requested, show warning that NAs were produced
  if(type == "SP" & any(return |> sf::st_is_empty())){

    NAs <- sum(sf::st_is_empty(return))
    warning(paste0("In add_polygons(). Some shifts lack species-specific ranges. ",NAs," NA values returned."), call. = FALSE)

  }

  sf::st_crs(return) <- sf::st_crs(polys)
  rm(polys)

  return(return)


}
