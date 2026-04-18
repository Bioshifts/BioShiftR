#' Add Climate Velocity to shifts dataframe
#'
#' @param data Shifts dataframe from get_shifts() function
#' @param type Choice of climate velocity values from study area (SA) or species-specific study area (SP) polygons
#' @param stat Statistic of climate velocity to add. c("q25", "median", "mean", "q75", "sd").
#' @param res Spatial resolution with which climate velocities were calculated c("1km","25km","50km","110km"). Note that higher resolutions will generally have higher velocities, since climate velocity is calculated as climate trend / spatial gradient.
#' @param suffix Binary choice to add the resolution on to climate velocity variable columns. Use this if you plan to add multiple climate velocity resolutions to the same dataset.
#'
#' @returns dataframe of range shifts supplemented with selected columns of climate velocity standardized to positive values in the poleward or elevational directions.
#' @export
#'
#' @examples get_shifts() |> add_cv(stat = c("mean"),res = c("LAT" = "25km", "ELE" = "1km")) |> dplyr::glimpse()
add_cv <- function(data,
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


  # check if cv columns already exist -----------------------------------
  check_cols_important <- c(
    paste0("cv_temp_",stat),
    "cv_res")

  check_cols_unimportant <- c(
    "cv_temp_var",
    "along_gradient"
  )

  if(any(c(check_cols_important, check_cols_unimportant) %in% colnames(data))){
    # if cv_temp_var or along_gradient exist, remove them.
    existing_unimportant <- check_cols_unimportant[which(check_cols_unimportant %in% colnames(data))]
    data <- data %>% select(-all_of(existing_unimportant))

    # if real cv cols exist, remove and warn
    existing_important <- check_cols_important[which(check_cols_important %in% colnames(data))]
    existing_col_text <- glue::glue_collapse(existing_important, sep = ", ", last = ", and ")
    if(nchar(existing_col_text) > 0 & suffix == F){
      warning(paste0(existing_col_text," already exists in data and will be replaced. Use suffix argument to add multiple resolutions of climate data."))
      data <- data %>% select(-all_of(existing_important))
    }
  }

  # get cv files (study- or species-specific)
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


  # get input combinations of stat, res
  combinations <-
    purrr::map(.x = res,
               .f = ~expand.grid(stat, paste0("res",.x)))

  # paste combinations into colnames
  cols <- purrr::map(.x = combinations,
                     .f = ~paste0("cv_temp_", apply(.x,1,paste,collapse = "_")))

  # split data by type (lat/ele)
  data_split <- data |> split(f = factor(data$type, levels = c("LAT","ELE")))

  # add cv to bioshifts
  cv2 <- switch(
    type,
    # if type is "SA", add study-level CVs:
    "SA" = purrr::map_dfr(
      .x = names(cols),
      .f = ~{
        out <- data_split[[.x]] |>
          dplyr::left_join(cv |> dplyr::select(article_id, poly_id, type, method_id,along_gradient, dplyr::all_of(cols[[.x]]),cv_temp_var),
                           by = dplyr::join_by(article_id, poly_id, method_id, type))
        if(suffix == F){
          out <- out |>
            dplyr::mutate(cv_res = res[[.x]]) |>
            dplyr::rename_with(~ stringr::str_replace(.x, "_res.*", ""), dplyr::all_of(cols[[.x]]))
        } else if(suffix == T){
          out <- out |>
            dplyr::rename_with(~ stringr::str_replace(.x, "_res", "_"), dplyr::all_of(cols[[.x]]))
        }
        out
      }
    ),
    # if type is "SP", add species-level CVs:
    "SP" = purrr::map_dfr(
      .x = names(cols),
      .f = ~{
        out <- data_split[[.x]] |>
          dplyr::left_join(cv |> dplyr::select(article_id, poly_id, type, method_id, sp_name_checked, along_gradient, dplyr::all_of(cols[[.x]]),cv_temp_var),
                           by = dplyr::join_by(article_id, poly_id, type, method_id, sp_name_checked))
        if(suffix == F){
          out <- out |>
            dplyr::mutate(cv_res = res[[.x]]) |>
            dplyr::rename_with(~ stringr::str_replace(.x, "_res.*", ""), dplyr::all_of(cols[[.x]]))
        } else if(suffix == T){
          out <- out |>
            dplyr::rename_with(~ stringr::str_replace(.x, "_res", "_"), dplyr::all_of(cols[[.x]]))
        }
        out
      }
    )
  )

  # print a warning if species-specific shift rates are missing
  # (because they don't exist for some species)
  if(type == "SP"){
    cv_col <- ifelse(suffix, cols[[2]], stringr::str_replace(cols[[1]],"_res.*",""))
    n_missing <- sum(sum(is.na(cv2[[cv_col]])))
    if(n_missing > 0){
      warning(call. = F, paste0("Not all shifts have associated species-specific polygon values. ",scales::comma(n_missing)," NAs returned."))
    }
  }

  # various warnings
  if("Mar" %in% unique(data$eco) & "1km" %in% res[["LAT"]]){
    warning(call. = F, "Marine baselines do not include 1km resolutions. NAs returned")
  }
  if("ELE" %in% unique(data$type) & any(c("25km","50km",'110km') %in% res[["ELE"]])){
    warning(call. = F, "Elevation shifts do not include 25km, 50km, or 110km climate velocity resolutions. NAs returned.")
  }

  return(cv2)

}

