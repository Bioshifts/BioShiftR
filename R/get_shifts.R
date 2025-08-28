#' Get BioShifts Range Shifts - Start Here.
#'
#' Get species' range shift values from the BioShifts database, filtered by taxon, study type or geography. BioShifts includes range shift observations of over 31,000 taxa within studies conducted around the world, published between
#'
#' @param group Rough taxonomic subgroups for which to pull bioshifts data. Options are Algae, Birds, Fish, Fungi, Mammals, Marine Invertebrates, Nonvascular Plants, Reptiles and Amphibians, Terrestrial Invertebrates, and Vascular Plants, or All (default). This shortcut is meant to provide a coarse subsetting for data exploration, but for more precise taxonomic filtering, see add_taxo().
#' @param realm Subset of study realms for which to uplaod range shift data. Options are "Mar" (marine), "Ter" (terrestrial), or "All" (default).
#' @param continent Continent of studies for which to upload BioShifts data. Options include "North America", "South America", "Africa", "Europe", "Asia", "Oceania", "High Seas", or "All".
#' @param type Gradient over which to extract range shifts. Options are "ELE" for elevational shifts, or "LAT" for latitudinal shifts.
#'
#' @returns Minimal data frame of calculated and author-reported species range shift values.
#' @export
#'
#' @examples get_shifts()
#' @examples get_shifts(group = "Birds", continent = "Asia")
#' @examples get_shifts(continent = c("North America","South America"), type = "ELE")
get_shifts <- function(group = "All",
                       realm = "All",
                       continent = "All",
                       type = c("LAT","ELE")){

  shifts <- readRDS(system.file("extdata", "shifts.rds", package = "BioShiftR"))
  sa_cont <- readRDS(system.file("extdata","common_continent.rds", package = "BioShiftR"))
  common_taxa <- readRDS(system.file("extdata","common_taxa.rds", package = "BioShiftR"))



  if(!identical(group,c("All"))){

    shifts <- shifts |>
      dplyr::filter(sp_name_publication %in% unname(unlist(common_taxa[c(group)])))

  }

  if(!identical(realm,c("All"))){

    shifts <- shifts |> dplyr::filter(eco == realm)
    if(realm == "Mar"){warning("Note: Marine realm includes intertidal species, to differentiate, further filtering is required. Use column Eco.")}
    if(realm == "Ter"){warning("Note: Terrestrial realm includes Aquatic and Semi-Aquatic species, to differentiate, further filtering is required. Use Eco column.")}
  }

  if(!identical(continent,c("All"))){

    shifts <- shifts |>
      dplyr::mutate(cont_id = paste0(article_id,"_",poly_id)) |>
      dplyr::filter(cont_id %in% unname(unlist(sa_cont[continent])))
  }

  if(nrow(shifts) == 0){
    warning("No shifts of this grouping exist in the dataset")
  }

  # filter to selected type
  shifts <- shifts |>
    dplyr::filter(type %in% !!type)

  return(shifts)

}
