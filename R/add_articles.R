#' Add article identifiers to range shift data
#'
#' @param data range shift dataframe from get_shifts() function
#'
#' @returns range shift dataframe supplemented with article identification information for each shift (author, doi)
#' @export
#'
#' @examples get_shifts(group = "Birds", continent = "Africa") |> add_articles()
add_articles <- function(data){

  articles <- readRDS(system.file("extdata", "articles.rds", package = "BioShiftR"))

  return <- data |>
    dplyr::left_join(articles,
                     dplyr::join_by(article_id))

  return(return)
}
