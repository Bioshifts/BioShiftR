#' Get BioShifts v2 Relational Table
#'
#' @param table Name of 14 relational tables in BioShifts v2:
#'
#' @returns Raw relational tables from BioShifts v2
#' @keywords internal
#'
#' @examples get_bs_table("author_reported")
get_bs_table <- function(table,
                         polygon_folder = "./BioShiftR_polygons"){



  file <- switch(table,

                 # shifts
                 "shifts" = "shifts.rds",

                 # shift estimate specificifites
                 "articles" = "articles.rds",
                 "author_reported" = "author_reported.rds",
                 "taxonomy" = "taxo.rds",
                 "methods" = "methods.rds",

                 # derived exposure variables
                 "SA_baselines" = "baselines.rds",
                 "SP_baselines" = "sp_baselines.rds",
                 "SA_trends" = "trends.rds",
                 "SP_trends" = "sp_trends.rds",
                 "SA_cv" = "cv.rds",
                 "SP_cv" = "sp_cv.rds",

                 # geospatial
                 "SA_polygon_info" = "poly_info.rds",
                 "SP_poly_info" = "sp_poly_info.rds",
                 "SA_polygons" = "sa_polygons_simplified.rds",
                 "SP_polygons" = "sp_polygons_simplified.rds"
                 )

  # if it's a spatial polygon, make sure the folder exists
  if(table %in% c("SA_polygons","SP_polygons")){
    file_exists <- file.exists(file.path(polygon_folder,file))
  } else {
    file.exists <- TRUE
  }



  out <- readRDS(system.file("extdata", file, package = "BioShiftR"))

  return(out)

}
