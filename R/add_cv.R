#' Add Climate Velocity to shifts dataframe
#'
#' @param data Shifts dataframe from get_shifts() function
#' @param type Choice of climate velocity values from study area (SA) or species-speficic study area (SP) polygons
#' @param stat Statistic of climate velocity to add. c("min", "1Q", "median", "mean", "3Q", "max")
#' @param exp Exposure variable. c("temp","precip")
#' @param res Spatial resolution with which climate velocities were calculated c("1km","25km","50km","110km"). Note that higher resolutions will generally have higher velocities, since climate velocity is calculated as climate trend / spatial gradient.
#'
#' @returns dataframe of range shifts supplemented with selected columns of climate velocity.
#' @export
#'
#' @examples get_shifts() |> add_cv(stat = c("mean"), exp = c("temp"),res = c("LAT" = "25km", "ELE" = "1km")) |> dplyr::glimpse()
add_cv <- function(data,
                   type = "SA",
                   stat = c("mean"),
                   exp = c("temp"),
                   res = c("LAT" = "25km",
                           "ELE" = "1km")){

  # get baselines cv
  cv <- switch(type,
               "SA" =  readRDS(system.file("extdata", "cv.rds", package = "BioShiftR")) |>
                 dplyr::rename(cv_temp_var = temp_var),
               "SP" =  readRDS(system.file("extdata", "sp_cv.rds", package = "BioShiftR")) |>
                 dplyr::rename(cv_temp_var = temp_var)
  )

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
                     .f = ~paste0("VelAlong_", apply(.x,1,paste,collapse = "_")))

  # split data by type (lat/ele)
  data_split <- data |> split(f = factor(data$type, levels = c("LAT","ELE")))

  cv2 <- switch(
    type,
    "SA" = purrr::map_dfr(
      .x = names(cols),
      .f = ~data_split[[.x]] |>
        dplyr::left_join(cv |> dplyr::select(article_id, poly_id, type, method_id,along_gradient, dplyr::all_of(cols[[.x]]),cv_temp_var),
                         by = dplyr::join_by(article_id, poly_id, method_id, type)) |>
        dplyr::mutate(cv_res = res[[.x]]) |>
        dplyr::rename_with(~ stringr::str_replace(.x, "_res.*", ""), dplyr::all_of(cols[[.x]]))
    ),
    "SP" = purrr::map_dfr(
      .x = names(cols),
      .f = ~data_split[[.x]] |>
        dplyr::left_join(cv |> dplyr::select(article_id, poly_id, type, method_id, sp_name_checked, along_gradient, dplyr::all_of(cols[[.x]]),cv_temp_var),
                         by = dplyr::join_by(article_id, poly_id, type, method_id, sp_name_checked)) |>
        dplyr::mutate(cv_res = res[[.x]]) |>
        dplyr::rename_with(~ stringr::str_replace(.x, "_res.*", ""), dplyr::all_of(cols[[.x]]))
    )
  )

  # print a warning if species-specific polys are missing
  if(type == "SP"){
    n_missing <- sum(rowSums(is.na(cv2[,c(stringr::str_replace(cols[[1]],"_res.*",""))])) == length(cols[[1]]))
    if(n_missing > 0){
      warning(call. = F, paste0("Not all shifts have associated species-specific polygon values. ",n_missing," NAs returned."))
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
    warning("Elevation shifts do not include 25km, 50km, or 110km climate velocity resolutions. NAs returned.")
  }

  return(cv2)

}
