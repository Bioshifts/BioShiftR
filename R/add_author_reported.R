#' Add author-reported shift results to range shifts
#'
#' The BioShifts package standardizes author-reported data in several forms to rates of change in the latitudinal or elevational direction over time. This function supplements the calculated shift rates with shift findings as reported by original study authors.
#'
#' @param data input shifts dataset from get_shifts() function.
#'
#' @returns Range shifts dataset with added columns containing author-reported shift values, and the figure, table, or dataset in the original publication from which the shift values were pulled.
#' @export
#'
#' @examples get_shifts() |> add_author_reported()
add_author_reported <- function(data){

  author <- readRDS(system.file("extdata", "author_reported.rds", package = "BioShiftR"))

  return <- data |>
    dplyr::left_join(author,
              dplyr::join_by(id,sp_name_publication, subsp_or_pop))

  return(return)


}
