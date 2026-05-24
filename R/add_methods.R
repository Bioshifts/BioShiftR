#' Add methods to range shift documentations
#'
#' add_methods supplements the minimal shifts database with methodological information describing the methods by which individal shifts were documented. These include variables such as sampling years, definitions of range parameters, and more.
#'
#' @param data input data from get_shifts().
#'
#' @returns original shifts dataset, supplemented with methodological parameters for each individual range shift detection. See readme for details on methods columns.
#' @export
#'
#' @examples get_shifts() |> add_methods() |> dplyr::glimpse()
add_methods <- function(data){

  if(!all(c("id") %in% colnames(data))){
    stop("ID key missing; input requires: id", call.=F)
  }

  # upload data
  methods <- readRDS(system.file("extdata", "methods.rds", package = "BioShiftR")) %>%
    dplyr::select(-c( article_id, poly_id, type, param, method_id)) # not needed for merge. covered in 'id'


  # merge
  return <- data |>
    dplyr::left_join(methods,
              dplyr::join_by(id))

  return(return)

}
