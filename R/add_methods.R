#' Add methods to range shift documentations
#'
#' add_methods supplements the minimal shifts database with methodological information describing the methods by which individal shifts were documented. These include variables such as sampling years, definitions of range parameters, and more.
#'
#' @param data input data from get_shifts().
#'
#' @returns original shifts dataset, supplemented with methodological parameters for each individual range shift detection.
#' @export
#'
#' @examples get_shifts() %>% add_taxo()
add_methods <- function(data){

  methods <- readRDS(system.file("extdata", "methods.rds", package = "BioShiftR"))

  return <- data %>%
    left_join(methods,
              join_by(id, article_id, poly_id, type, param, method_id))

  return(return)

}
