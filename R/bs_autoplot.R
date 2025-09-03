#' Title
#'
#' @param species
#' @param article
#' @param type
#' @param plottype
#'
#' @returns
## ' @export
#'
#' @examples
bs_autoplot <- function(species = c("Troglodytes troglodytes","Fringilla coelebs"),
                        article = NULL,
                        type = c("LAT","ELE"),
                        plottype = "point"){


  sp <- stringr::str_replace(species, " ","_")

  sp_find <- get_shifts() |>
    filter(sp_name_checked %in% sp |
             sp_name_publication %in% sp) |>
    mutate(same = sp_name_checked == sp_name_publication)

  count(sp_find,same)

  if(any(sp_find$same == F)){
    n <- sum(sp_find$same == F)
    warning(paste0("Species names have been resolved. This plot contains ", n,
                   " shifts for which author-provided species names have changed."))
  }

  if(nrow(sp_find) == 0){
    stop("No shifts found for selected species.")
  }


  avg <- sp_find %>%
    group_by(type, param) %>%
    summarize(calc_rate = mean(calc_rate))
  sp_find %>%
    ggplot2::ggplot(aes(x = article_id,
                        y = calc_rate,
                        color = param)) +
    ggplot2::geom_point() +
    facet_grid(param~type,
               scales = "free_x") +
    geom_hline(yintercept = 0) +
    geom_hline(data = avg,
               aes(yintercept = calc_rate,
                   color = param),
               linetype = "dashed",
             linewidth = .5,
             #outside = T,
             show.legend = F) +
    theme_bw()+
    theme(panel.grid = element_blank())

  sp_find %>%
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

