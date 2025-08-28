#' Add taxonomy to range shifts
#'
#' add_taxo() merges taxonomic classification to range shifts uploaded with the get_shifts() function.
#'
#' @param df input shifts dataset from get_shifts() function.
#'
#' @returns Range shifts dataset with added columns containing taxonomic classification information for every species name, as written in the original publication.
#' @export
#'
#' @examples get_shifts() %>% add_taxo()
add_taxo <- function(data){

  taxo <- readRDS(system.file("extdata", "taxo.rds", package = "BioShiftR"))

  return <- data |>
    dplyr::left_join(taxo,
              dplyr::join_by(sp_name_publication))

  return(return)

}
