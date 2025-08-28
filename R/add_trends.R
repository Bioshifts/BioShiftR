#' Add climate variable trends to range shift dataframe
#'
#' @param data dataframe of BioShifts range shifts from get_shifts() function
#' @param type Type of area over which trends are calculated: Article study areas ("SA"), or study areas cropped to species' range polygons ("SP").
#' @param stat Statistic of climate trends to add c("min", "1Q", "median", "mean", "3Q", "max").
#' @param exp Exposure variable c("temp","precip")
#' @param res Spatial resolution of climate grid cells with which the climate trends were calculated c("1km","25km","50km","110km"). Note that terrestrial latitudinal study areas are calculated at 1, 25, 50, 110km, marine latitudinal studies are calculated at 25, 50, 110km, and elevation studies are calculated only at 1km.
#'
#'
#' @returns range shift dataframe supplemented with selected trends in temperature (°C/year) or precipitation (inches ???!? / year) within study areas or species-specific study areas throughout the duration of the original study.
#' @export
#'
#' @examples
add_trends <- function(data,
                       type = "SA",
                       stat = c("mean"),
                       exp = c("temp"),
                       res = c("LAT" = "25km",
                               "ELE" = "1km")){

  # get baselines cv
  trends <- readRDS(system.file("extdata", "trends.rds", package = "BioShiftR"))

  # specify res column - if only one is provided, make it the chosen res for both
  if(length(res) == 1 & is.null(names(res))){
    res <- c("LAT" = res,
             "ELE" = res)
  }

  # get input combinations of stat, exp, res
  combinations <-
    purrr::map(.x = res,
               .f = ~expand.grid(stat, exp, paste0("res",.x)))

  # paste combinations into colnames
  cols <- purrr::map(.x = combinations,
                     .f = ~paste0("trend_", apply(.x,1,paste,collapse = "_")))

  # split data by type (lat/ele)
  data_split <- data |> split(f = factor(data$type, levels = c("LAT","ELE")))

  trends2 <- purrr::map_dfr(

    .x = names(cols),

    .f = ~data_split[[.x]] |>
      dplyr::left_join(trends |> dplyr::select(article_id, poly_id, type, method_id,temp_var, dplyr::all_of(cols[[.x]])),
                       by = dplyr::join_by(article_id, poly_id, method_id, type)) |> dplyr::mutate(trend_res = res[[.x]]) |>
      dplyr::rename_at((cols[[.x]]), function(col) stringr::str_replace(col,"_res.*",""))

  )

  # print a warning if species-specific polys are missing
  if(type == "SP"){
    n_missing <- sum(is.na(return[,c(stringr::str_replace(cols[1],"_res.*",""))]))
    if(n_missing > 0){
      warning(paste0("Not all shifts have associated species-specific polygon values, or values at every resolution. ",n_missing," NAs returned."))
    }
  }

  # various warnings
  if("ELE" %in% unique(data$type) & "precip" %in% exp){
    warning("Elevation shifts do not include precipitation velocities. NAs returned")
  }
  if("Mar" %in% unique(data$eco) & "precip" %in% exp){
    warning("Marine shifts do not include precipitation velocities. NAs returned")
  }
  if("Mar" %in% unique(data$eco) & "1km" %in% res[["LAT"]]){
    warning("Marine baselines do not include 1km resolutions. NAs returned")
  }
  if("ELE" %in% unique(data$type) & any(c("25km","50km",'110km') %in% res[["ELE"]])){
    warning("Elevation shifts do not include 25km, 50km, or 110km climate variable resolutions. NAs returned.")
  }

  return(trends2)

}
