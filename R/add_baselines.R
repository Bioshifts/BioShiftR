#' Add baseline temperatures of species- or study-area polygons for each range shift
#'
#'
#'
#' @param data input data from get_shifts()
#' @param type Choice of baseline temperatures from study area (SA) or species area (SP) polygons.
#' @param stat Statistic of the given variable. Choices are min, 1Q, median, mean, 3Q, max.
#' @param exp Exposure variable; Choices are "temp" (temperature") or "precip" (precipitation), or both.
#' @param res Calculation resolution. Baseline temperatures in each species/study area were calculated with environmental raster layers at up to four resolutions: 1km, 25km, 50km, 110km, resulting in slightly different values. Choose a specific res ("1km","25km","50km","110km"), or use "best" to ensure each shift has a matching temperature (see vignette)
#'
#' @returns Shifts database supplemented with selected temperature and/or precipitation baseline values within the study area or species-specific study area.
#' @export
#'
#' @examples get_shifts() |> add_baselines()
#' @examples get_shifts(eco = "Mar") |> add_baselines(res = "25km")
add_baselines <- function(data,
                          type = "SA",
                          stat = c("mean"),
                          exp = c("temp"),
                          res = c("LAT" = "25km",
                                  "ELE" = "1km")){

  # get baselines df
  baselines <- switch(
    type,
    "SA" = readRDS(system.file("extdata", "baselines.rds", package = "BioShiftR")) |>
      dplyr::rename(baseline_temp_var = temp_var),
    "SP" = readRDS(system.file("extdata", "sp_baselines.rds", package = "BioShiftR")) |>
      dplyr::rename(baseline_temp_var = temp_var)
  )



#  default_res <- c(ELE = "1km", LAT = "25km")
#
#  data_split <- split(data, data$type)
#
#  # Join each split to df2 with the right resolution
#  out <- map_dfr(names(data_split), function(grad) {
#    dat <- data_split[[grad]]
#
#    # Decide resolution: user-supplied or default
#    res <- resolution %||% default_res[[grad]]
#
#    # Select only the columns of df2 that match this resolution
#    df2_res <- data2 %>% select(where(~!is.numeric(.))) %>%
#      bind_cols(df2 %>% select(ends_with(res)))
#
#    # Merge (assuming they share some join keys, e.g. "species" or "id")
#    left_join(dat, df2_res, by = "species")  # change 'species' to your join #key
#  })

  # specify res column - if only one is provided, make it the chosen res for both
  if(length(res) == 1 & is.null(names(res))){
    res <- c("LAT" = res,
             "ELE" = res)
  }

  combinations <-
    purrr::map(.x = res,
               .f = ~expand.grid(stat, exp, paste0("res",.x)))

  cols <- purrr::map(.x = combinations,
                             .f = ~paste0("baseline_", apply(.x,1,paste,collapse = "_")))

  data_split <- data |> split(f = factor(data$type, levels = c("LAT","ELE")))

  baselines2 <- switch(
    type,
    "SA" = purrr::map_dfr(
      .x = names(cols),
      .f = ~data_split[[.x]] |>
        dplyr::left_join(baselines |> dplyr::select(article_id, poly_id, type, method_id, all_of(cols[[.x]])),
                         by = dplyr::join_by(article_id, poly_id, method_id, type)) |>
        dplyr::mutate(baseline_res = res[[.x]]) |>
        dplyr::rename_with(~ stringr::str_replace(.x, "_res.*", ""), dplyr::all_of(cols[[.x]]))
    ),
    "SP" = purrr::map_dfr(
      .x = names(cols),
      .f = ~data_split[[.x]] |>
        dplyr::left_join(baselines |> dplyr::select(article_id, poly_id, type, method_id,sp_name_checked, all_of(cols[[.x]])),
                         by = dplyr::join_by(article_id, poly_id, method_id, type, sp_name_checked)) |>
        dplyr::mutate(baseline_res = res[[.x]]) |>
        dplyr::rename_with(~ stringr::str_replace(.x, "_res.*", ""), dplyr::all_of(cols[[.x]]))
    )
  )

  #baselines2 %>% glimpse()
# -------------------------------------------------------------------------


#
#
#  # get all combinations of var, stat, and exp
#  combinations <- expand.grid( stat, exp, paste0("res",res))
#
#  # paste to colnames
#  cols <- paste0("baseline_",apply(combinations, 1, paste, collapse = "_"))
#
#  baselines2 <- switch(
#    type,
#    "SA" =  baselines |> dplyr::select(article_id, poly_id, type, method_id, all_of(cols)),
#    "SP" = baselines |> dplyr::select(ID, sp_name_publication, Eco, Type, all_of(cols))
#  )
#
#
#  # remove "res_" from colnames
#  colnames(baselines2)[colnames(baselines2) %in% cols] <-  stringr::str_replace(cols,"_res.*","")
#
#  return <- switch(
#    type,
#    "SA" = data |> dplyr::left_join(baselines2, by = dplyr::join_by(article_id, poly_id, type, method_id)),
#    "SP" = data |> dplyr::left_join(baselines2, by = dplyr::join_by(ID, Eco, Type, sp_name_publication))
#  )
#
  # print a warning if species-specific polys are missing
  if(type == "SP"){
    n_missing <- sum(rowSums(is.na(baselines2[,c(stringr::str_replace(cols[[1]],"_res.*",""))])) == length(cols[[1]]))
    if(n_missing > 0){
      warning(call. = F,
              paste0("Not all shifts have associated species-specific polygon values. ",n_missing," NAs returned."))
    }
  }

  # various warnings
  if("Mar" %in% unique(data$eco) & "precip" %in% exp){
    warning("Marine shifts do not include precipitation values. NAs returned")
  }
  if("Mar" %in% unique(data$eco) & "1km" %in% res[["LAT"]]){
    warning("Marine baselines do not include 1km resolutions. NAs returned")
  }
  if("ELE" %in% unique(data$type) & any(c("25km","50km",'110km') %in% res[["ELE"]])){
    warning("Elevation shifts do not include 25km, 50km, or 110km baselines. NAs returned.")
  }


  return(baselines2)



}

