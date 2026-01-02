#' Title
#'
#' @param species Name of a select species for which to plot all documented shifts.
#' @param article
#' @param type
#' @param plottype The type of plot to return. Options are
#'
#' @returns
## ' @export
#'
#' @examples
bs_autoplot <- function(species = c("Troglodytes troglodytes","Fringilla coelebs"),
                        article = NULL,
                        type = c("LAT","ELE"),
                        plottype = "point",
                        facet = NULL){


  sp <- stringr::str_replace(species, " ","_")

  sp_find <- get_shifts() |>
    filter(sp_name_checked %in% sp |
             sp_name_publication %in% sp) |>
    mutate(same = sp_name_checked == sp_name_publication)

  count(sp_find,same)

  if(any(sp_find$same == F)){
    n <- sum(sp_find$same == F)
    warning(paste0("Species names have been resolved. This plot contains ", n,
                   " shifts for which author-provided species name was different."))
  }

  if(nrow(sp_find) == 0){
    stop("No shifts found for selected species.")
  }


  if(plottype == "map"){

    filename <- #switch(type,
                      # "SA" = "sa_polygons_simplified.rds",
                      # "SP" =
      "sp_polygons_simplified.rds"#)

    # check if polygon gpkg has already been downloaded
    all_proj_files <-
      list.files(recursive = T,
                 include.dirs = F,
                 full.names = F)


    # check if filename already exists
    exists <- any(stringr::str_detect(all_proj_files, filename))

    if(exists == F){
      stop("Polygons not found locally. Please use download_polygons(), or specify directory if they are downloaded outside of default.")
    }


    path <- all_proj_files[which(stringr::str_detect(all_proj_files,filename))]

    polys <- readRDS(path) %>%
      filter(sp_name_checked %in% sp) %>%
      right_join(sp_find, by = dplyr::join_by(article_id, poly_id, sp_name_checked))

    bbox <- sf::st_bbox(sf::st_buffer(sf::st_union(polys),2))

    return <- ggplot2::ggplot(data = polys) +
      ggplot2::geom_sf(data = rnaturalearth::ne_countries(returnclass = "sf") |>
                         sf::st_crop(bbox)) +
      ggplot2::geom_sf( ggplot2::aes(fill = calc_rate,
                                     color = calc_rate),
                        alpha = .8) +
     # ggplot2::scale_fill_viridis_c() +
      ggplot2::scale_fill_gradient2(high = "tomato2", low = "cyan4", mid = "#dfa9f5",
                                    trans = ggallin::ssqrt_trans) +
      ggplot2::scale_color_gradient2(high = "tomato2", low = "cyan4", mid = "#dfa9f5",
                                     trans = ggallin::ssqrt_trans) +
      ggplot2::theme_bw() +
      #ggplot2::facet_wrap(~param)+
      ggplot2::coord_sf(expand=F)

    if(facet){
      return <- return +
        ggplot2::facet_wrap(~get(facet))

    }


  }




  #avg <- sp_find %>%
  #  group_by(type, param) %>%
  #  summarize(calc_rate = mean(calc_rate))
 # sp_find %>%
 #   ggplot2::ggplot(aes(x = article_id,
 #                       y = calc_rate,
 #                       color = param)) +
 #   ggplot2::geom_point() +
 #   facet_grid(param~type,
 #              scales = "free_x") +
 #   geom_hline(yintercept = 0) +
 #   geom_hline(data = avg,
 #              aes(yintercept = calc_rate,
 #                  color = param),
 #              linetype = "dashed",
 #            linewidth = .5,
 #            #outside = T,
 #            show.legend = F) +
 #   theme_bw()+
 #   theme(panel.grid = element_blank())
#

  if(plottype == "boxplot"){

   return <-  sp_find %>%
      ggplot(aes(x = param,
                 y = calc_rate,
                 color = param)) +
      geom_hline(yintercept = 0) +
      geom_point(position = position_jitter(width = .1, height = 0),
                 alpha = .8) +
      geom_boxplot(width = .2,
                   fill = "transparent",
                   color = "black",
                   outliers = F)
  }

  return(return)

}

