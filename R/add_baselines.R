#' Add baseline temperatures of species- or study-area polygons for each range shift
#'
#'
#'
#' @param data input data from get_shifts()
#' @param type Choice of baseline temperatures from study area (SA) or species area (SP) polygons.
#' @param stat Statistic of the given variable. Choices are "mean" and "sd".
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
                          res = c("LAT" = "25km",
                                  "ELE" = "1km"),
                          suffix = F){

  # make sure inputs are valid ----------------
  # make sure selected resolutions are valid
  if(!all(res %in% c("1km","25km","50km","110km"))){
    stop("res must be one of: '1km', '25km','50km','110km")
  }
  # make sure selected statistics are valid
  if(!all(stat %in% c("q25", "median", "mean", "q75", "sd"))){
    stop('stat must be any of: "q25", "median", "mean", "q75", "sd".')
  }
  # make sure type is valid
  if(!type %in% c("SA","SP")){
    stop("type must be 'SA' or 'SP'.")
  }
  # make sure there is only one resolution if adding suffix
  if(length(res) > 1 & suffix == T ){
    stop("use suffix only when selecting a single resolution of climate data (with res = c())")
  }

  # check if baseline columns already exist -----------------------------------
  check_cols_important <- c(
    paste0("baseline_temp_",stat),
    "baseline_res")


  if(any(c(check_cols_important) %in% colnames(data))){
    # if baseline cols exist, remove and warn
    existing_important <- check_cols_important[which(check_cols_important %in% colnames(data))]
    existing_col_text <- glue::glue_collapse(existing_important, sep = ", ", last = ", and ")
    if(nchar(existing_col_text) > 0 & suffix == F){
      warning(paste0(existing_col_text," already exists in data and will be replaced. Use suffix argument to add multiple resolutions of baseline climate data."))
      data <- data %>% select(-all_of(existing_important))
    }
  }


  # get baselines df
  baselines <- switch(
    type,
    "SA" = readRDS(system.file("extdata", "baselines.rds", package = "BioShiftR")) |>
      dplyr::rename(baseline_temp_var = temp_var),
    "SP" = readRDS(system.file("extdata", "sp_baselines.rds", package = "BioShiftR")) |>
      dplyr::rename(baseline_temp_var = temp_var)
  )


  # specify res column - if only one is provided, make it the chosen res for both
  if(length(res) == 1 & is.null(names(res))){
    res <- c("LAT" = res,
             "ELE" = res)
  }

  # get input combinations of stat, res
  combinations <-
    purrr::map(.x = res,
               .f = ~expand.grid(stat, paste0("res",.x)))

  # paste combinations into colnames
  cols <- purrr::map(.x = combinations,
                     .f = ~paste0("baseline_temp_", apply(.x,1,paste,collapse = "_")))

  # split data by type (lat/ele)
  data_split <- data |> split(f = factor(data$type, levels = c("LAT","ELE")))

  # add baselinesto to bioshifts
  baselines2 <- switch(
    type,
    # if type is "SA", add study-level baselines:
    "SA" = purrr::map_dfr(
      .x = names(cols),
      .f = ~{
        out <- data_split[[.x]] |>
          dplyr::left_join(baselines |> dplyr::select(article_id, poly_id, type, method_id, dplyr::all_of(cols[[.x]])),
                           by = dplyr::join_by(article_id, poly_id, method_id, type))
        if(suffix == F){
          out <- out |>
            dplyr::mutate(baseline_res = res[[.x]]) |>
            dplyr::rename_with(~ stringr::str_replace(.x, "_res.*", ""), dplyr::all_of(cols[[.x]]))
        } else if(suffix == T){
          out <- out |>
            dplyr::rename_with(~ stringr::str_replace(.x, "_res", "_"), dplyr::all_of(cols[[.x]]))
        }
        out
      }
    ),
    # if type is "SP", add species-level baselines:
    "SP" = purrr::map_dfr(
      .x = names(cols),
      .f = ~{
        out <- data_split[[.x]] |>
          dplyr::left_join(baselines |> dplyr::select(article_id, poly_id, type, method_id, sp_name_checked, dplyr::all_of(cols[[.x]])),
                           by = dplyr::join_by(article_id, poly_id, type, method_id, sp_name_checked))
        if(suffix == F){
          out <- out |>
            dplyr::mutate(baseline_res = res[[.x]]) |>
            dplyr::rename_with(~ stringr::str_replace(.x, "_res.*", ""), dplyr::all_of(cols[[.x]]))
        } else if(suffix == T){
          out <- out |>
            dplyr::rename_with(~ stringr::str_replace(.x, "_res", "_"), dplyr::all_of(cols[[.x]]))
        }
        out
      }
    )
  )



  # print a warning if species-specific polys are missing
  if(type == "SP"){
    baseline_col <- ifelse(suffix, cols[[2]], stringr::str_replace(cols[[1]],"_res.*",""))
    n_missing <- sum(sum(is.na(baselines2[[baseline_col]])))
    if(n_missing > 0){
      warning(call. = F, paste0("Not all shifts have associated species-specific polygon values. ",scales::comma(n_missing)," NAs returned."))
    }
  }

  # various warnings
  if("Mar" %in% unique(data$eco) & "1km" %in% res[["LAT"]]){
    warning("Marine baselines do not include 1km resolutions. NAs returned")
  }
  if("ELE" %in% unique(data$type) & any(c("25km","50km",'110km') %in% res[["ELE"]])){
    warning("Elevation shifts do not include 25km, 50km, or 110km baselines. NAs returned.")
  }


  return(baselines2)



}

