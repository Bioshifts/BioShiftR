#' Add polygons to range shift database
#'
#' Each individual range shifts in the BioShifts database is associated with 1-2 spatial polygons. First, all shifts are associated with polygons of the study area, or the area sampled within the original article. Second, many shifts are associated with a species-specific polygon, or a polygon of the study area cropped to the polygon of the species range, when available. add_polygons allows users to merge spatial dataframes to selected range shift collections produced by the get_shifts() function. Requires download_polygons() to be used prior.
#'
#' @param data range shift dataframe. Output of get_shifts() function.
#' @param type choice of study area ("SA") or species-level ("SP"; species range cropped to study area) polygons
#'
#' @returns range shift dataframe with a geometry column containing the study-level or, when available, the species-specific polygon for each shift.
#' @export
#'
#' @examples \dontrun{get_shifts(continent = "Africa") |> add_polygons()}
add_polygons <- function(data,
                         type = "SA",
                         directory = "."){

  filename <- switch(type,
                     "SA" = "sa_polygons_simplified.rds",
                     "SP" = "sp_polys_simplified_5k.rds")


  # check if polygon gpkg has already been downloaded
  all_proj_files <-
    list.files(recursive = T,
               include.dirs = F,
               full.names = F)


  # check if filename already exists
  exists <- any(stringr::str_detect(all_proj_files, filename))

  if(exists == F){
    stop("Polygons not found locally. Please use download_polygons(), or specify directory if they are downloaded outside of default.")
  }


  path <- all_proj_files[which(stringr::str_detect(all_proj_files,filename))]


  polys <- readRDS(path)

  return <- data |>
    dplyr::left_join(polys, by = dplyr::join_by(article_id, poly_id)) |> sf::st_as_sf()


  sf::st_crs(return) <- sf::st_crs(polys)

  return(return)


}
