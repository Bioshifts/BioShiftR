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
#' @returns
#' @export
#'
#' @examples
add_baselines <- function(data,
                          type = "SA",
                          stat = c("mean"),
                          exp = c("temp"),
                          res = c("mean")){

  # get baselines df
  baselines <- readRDS(system.file("extdata", "baselines.rds", package = "BioShiftR"))


  # get all combinations of var, stat, and exp
  combinations <- expand.grid( stat, exp, paste0("res",res))


  # paste to colnames
  cols <- paste0("baseline_",apply(combinations, 1, paste, collapse = "_"))

  baselines2 <- switch(
    type,
    "SA" =  baselines %>% select(article_id, poly_id, type, method_id, all_of(cols)),
    "SP" = baselines %>% select(ID, sp_name_publication, Eco, Type, all_of(cols))
  )


  # remove "res_" from colnames
  colnames(baselines2)[colnames(baselines2) %in% cols] <-  stringr::str_replace(cols,"_res.*","")




  return <- switch(
    type,
    "SA" = data %>% left_join(baselines2, by = join_by(article_id, poly_id, type, method_id)),
    "SP" = data %>% left_join(baselines2, by = join_by(ID, Eco, Type, sp_name_publication))
  )

  # print a warning if species-specific polys are missing
  if(type == "SP"){
    n_missing <- sum(is.na(return[,c(str_replace(cols[1],"_res.*",""))]))
    if(n_missing > 0){
      warning(paste0("Not all shifts have associated species-specific polygon values. ",n_missing," NAs returned."))
    }
  }

  # various warnings
  if("Mar" %in% unique(data$eco) & "precip" %in% exp){
    warning("Marine shifts do not include precipitation values. NAs returned")
  }
  if("Mar" %in% unique(data$eco) & "1km" %in% res){
    warning("Marine baselines do not include 1km resolutions. NAs returned")
  }
  if("ELE" %in% unique(data$type) & any(c("25km","50km",'110km') %in% res)){
    warning("Elevation shifts do not include 25km, 50km, or 110km baselines. NAs returned.")
  }


  return(return)



}
