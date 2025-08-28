#' Add article identifiers to range shift data
#'
#' @param data Range shifts dataframe from the `get_shifts()` function
#'
#' @returns Range shifts dataframe supplemented with article identification information for each shift: Author, DOI, and identifiers for the article within other datasets (BioShifts V1 and CoRE database of range shifts).
#' @export
#'
#' @examples get_shifts(group = "Birds", continent = "Africa") |> add_articles() |> dplyr::glimpse()
add_articles <- function(data){

  articles <- readRDS(system.file("extdata", "articles.rds", package = "BioShiftR"))

  return <- data |>
    dplyr::left_join(articles,
                     dplyr::join_by(article_id))

  return(return)
}
