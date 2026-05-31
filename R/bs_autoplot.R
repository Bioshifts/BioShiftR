#' Autoplot species range shifts from the BioShifts database
#'
#' Quickly visualise range shift data in one of three ways: a per-study dot
#' plot, a distribution by range parameter, or a spatial polygon map.
#'
#' Currently not an exported function.
#'
#' The function accepts input in two ways:
#' * **By species name** – pass a character vector of one or more
#'   `sp_name_checked` values as the first argument.  The full database is
#'   queried automatically.
#' * **Pipe-in** – filter `get_shifts()` yourself (e.g., to species) and pipe
#'  the result in.
#'
#' @param data Either a character vector of species names (e.g.
#'   `"Troglodytes_troglodytes"`, spaces or underscores accepted) *or* a
#'   range-shift data frame from `get_shifts()`.  When omitted the full
#'   database is used.
#' @param plottype One of `"point"` (per-study dot plot with group means),
#'   `"boxplot"` (distribution of rates by range parameter), or `"map"`
#'   (species polygons on a world map, coloured by shift rate).  Partial
#'   matching is supported.
#' @param facet Optional column name (string) in `data` to use as a
#'   `facet_wrap()` grouping variable.
#' @param polygon_folder Path to locally-downloaded polygon files from
#'   `download_polygons(type = "SP")`.  Only used when `plottype = "map"`.
#'   Defaults to `"./BioShiftR_polygons"`.
#'
#' @returns A ggplot2 object.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' # Quick single-species dot plot
#' bs_autoplot("Troglodytes_troglodytes", plottype = "point")
#'
#' # Two species boxplot at once
#' bs_autoplot(c("Troglodytes_troglodytes", "Fringilla_coelebs"),
#'   plottype = "boxplot", facet = "sp_name_checked"
#' )
#'
#' # Pipe-in style
#' get_shifts(group = "Birds", continent = "Europe") |>
#'   bs_autoplot(plottype = "point")
#'
#'
#' # Map requires downloaded polygons (see ?download_polygons)
#' download_polygons(type = "SP")
#' bs_autoplot("Troglodytes_troglodytes", plottype = "map")
#' }
bs_autoplot <- function(data = NULL,
                        plottype = c("point", "boxplot", "map"),
                        facet = NULL,
                        polygon_folder = "./BioShiftR_polygons") {
  plottype <- match.arg(plottype)

  # If species names are passed as the first argument, filter the full database
  if (is.character(data)) {
    species <- stringr::str_replace_all(data, " ", "_")
    data <- dplyr::filter(
      get_shifts(),
      sp_name_checked %in% species
    )
    if (nrow(data) == 0) {
      stop(
        "No records found for the requested species. ",
        "Check spelling against sp_name_checked values returned by get_shifts().",
        call. = FALSE
      )
    }
  }

  # If nothing was supplied at all, use the full database
  if (is.null(data)) {
    data <- get_shifts()
  }

  # input validation ---------------------------------------------------------
  required_cols <- c("calc_rate", "param", "article_id", "type")
  missing_cols <- setdiff(required_cols, colnames(data))
  if (length(missing_cols) > 0) {
    stop(
      "data is missing required columns: ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  if (nrow(data) == 0) {
    stop(
      "data contains no rows. ",
      "Filter to species of interest before calling bs_autoplot().",
      call. = FALSE
    )
  }


  # shared helpers -----------------------------------------------------------

  param_labels <- c(
    "LE" = "Leading Edge",
    "O"  = "Centre",
    "TE" = "Trailing Edge"
  )

  param_colours <- c(
    "Leading Edge"  = "tomato2",
    "Centre"        = "#dfa9f5",
    "Trailing Edge" = "cyan4"
  )

  type_labels <- c(
    "LAT" = "Latitudinal",
    "ELE" = "Elevational"
  )

  if ("calc_unit" %in% colnames(data)) {
    units <- unique(data$calc_unit)
    unit_str <- if (length(units) == 1) paste0("(", units, ")") else "(km/year or m/year)"
  } else {
    unit_str <- "(km/year or m/year)"
  }
  y_label <- paste("Range Shift Rate", unit_str)

  bs_theme <- ggplot2::theme_classic(base_size = 11) +
    ggplot2::theme(
      strip.background = ggplot2::element_blank(),
      strip.text       = ggplot2::element_text(face = "bold"),
      axis.line        = ggplot2::element_line(colour = "black"),
      panel.spacing    = ggplot2::unit(0.8, "lines"),
      legend.key       = ggplot2::element_blank()
    )

  add_facet <- function(plt) {
    if (!is.null(facet)) {
      if (!facet %in% colnames(data)) {
        warning(paste0("facet column '", facet, "' not found in data; ignoring."),
          call. = FALSE
        )
        return(plt)
      }
      plt <- plt + ggplot2::facet_wrap(~ .data[[facet]])
    }
    plt
  }


  # point plot ---------------------------------------------------------------
  if (plottype == "point") {
    avg <- data |>
      dplyr::group_by(type, param) |>
      dplyr::summarise(
        calc_rate = mean(calc_rate, na.rm = TRUE),
        .groups = "drop"
      )

    plot_data <- data |>
      dplyr::mutate(
        param = factor(param, levels = names(param_labels), labels = param_labels),
        type  = factor(type, levels = names(type_labels), labels = type_labels)
      )

    avg <- avg |>
      dplyr::mutate(
        param = factor(param, levels = names(param_labels), labels = param_labels),
        type  = factor(type, levels = names(type_labels), labels = type_labels)
      )

    plt <- ggplot2::ggplot(
      plot_data,
      ggplot2::aes(x = article_id, y = calc_rate, colour = param)
    ) +
      ggplot2::geom_hline(yintercept = 0, linewidth = 0.4, colour = "grey50") +
      ggplot2::geom_hline(
        data = avg,
        ggplot2::aes(yintercept = calc_rate, colour = param),
        linetype = "dashed", linewidth = 0.5, show.legend = FALSE
      ) +
      ggplot2::geom_point(alpha = 0.8, size = 1.5) +
      ggplot2::scale_colour_manual(values = param_colours, name = "Range\nParameter") +
      ggplot2::labs(x = "Study", y = y_label) +
      bs_theme +
      ggplot2::theme(
        axis.text.x  = ggplot2::element_blank(),
        axis.ticks.x = ggplot2::element_blank()
      )

    if (dplyr::n_distinct(data$type) > 1) {
      plt <- plt + ggplot2::facet_grid(param ~ type, scales = "free_x")
    } else {
      plt <- plt + ggplot2::facet_wrap(~param, scales = "free_x", ncol = 1)
    }

    return(add_facet(plt))
  }


  # boxplot ------------------------------------------------------------------
  if (plottype == "boxplot") {
    plot_data <- data |>
      dplyr::mutate(
        param = factor(param, levels = names(param_labels), labels = param_labels)
      )

    plt <- ggplot2::ggplot(
      plot_data,
      ggplot2::aes(x = param, y = calc_rate, colour = param)
    ) +
      ggplot2::geom_hline(yintercept = 0, linewidth = 0.4, colour = "grey50") +
      ggplot2::geom_point(
        position = ggplot2::position_jitter(width = 0.15, height = 0),
        alpha = 0.8, size = 1.2
      ) +
      ggplot2::geom_boxplot(
        width = 0.25, fill = "transparent", colour = "black",
        outliers = FALSE, linewidth = 0.5
      ) +
      ggplot2::scale_colour_manual(values = param_colours, guide = "none") +
      ggplot2::labs(x = "Range Parameter", y = y_label) +
      bs_theme

    return(add_facet(plt))
  }


  # map ----------------------------------------------------------------------
  if (plottype == "map") {
    if (!"sp_name_checked" %in% colnames(data)) {
      stop("plottype = 'map' requires a 'sp_name_checked' column in data.",
        call. = FALSE
      )
    }

    if (!requireNamespace("rnaturalearth", quietly = TRUE)) {
      stop(
        "plottype = 'map' requires the 'rnaturalearth' package. ",
        "Install it with: install.packages('rnaturalearth')",
        call. = FALSE
      )
    }

    path <- file.path(polygon_folder, "sp_polygons_simplified.rds")
    if (!file.exists(path)) {
      stop(
        "Polygons not found locally. Run download_polygons(type = 'SP'), ",
        "or set polygon_folder to the directory where they are saved.",
        call. = FALSE
      )
    }

    sp <- stringr::str_replace_all(unique(data$sp_name_checked), " ", "_")

    polys <- readRDS(path) |>
      dplyr::filter(sp_name_checked %in% sp) |>
      dplyr::right_join(data, by = dplyr::join_by(article_id, poly_id, sp_name_checked))

    # s2 rejects degenerate edges common in species-range polygons; GEOS is
    # more lenient. Disable for the whole map block and restore on exit.
    prev_s2 <- sf::sf_use_s2(FALSE)
    on.exit(sf::sf_use_s2(prev_s2), add = TRUE)

    pad <- 2
    bbox <- sf::st_bbox(sf::st_make_valid(polys))
    bbox["xmin"] <- bbox["xmin"] - pad
    bbox["ymin"] <- bbox["ymin"] - pad
    bbox["xmax"] <- bbox["xmax"] + pad
    bbox["ymax"] <- bbox["ymax"] + pad

    rate_trans <- if (requireNamespace("ggallin", quietly = TRUE)) {
      ggallin::ssqrt_trans
    } else {
      message("Install 'ggallin' for a better colour scale transform on the map.")
      "identity"
    }

    plt <- ggplot2::ggplot(data = polys) +
      ggplot2::geom_sf(
        data = rnaturalearth::ne_countries(returnclass = "sf") |>
          sf::st_make_valid() |>
          sf::st_crop(bbox) |> suppressMessages(),
        fill = "grey88", colour = "white", linewidth = 0.2
      ) +
      ggplot2::geom_sf(
        ggplot2::aes(fill = calc_rate, colour = calc_rate),
        alpha = 0.8
      ) +
      ggplot2::scale_fill_gradient2(
        high = "tomato2", low = "cyan4", mid = "#dfa9f5",
        trans = rate_trans,
        name = paste("Range Shift\nRate", unit_str)
      ) +
      ggplot2::scale_colour_gradient2(
        high = "tomato2", low = "cyan4", mid = "#dfa9f5",
        trans = rate_trans,
        guide = "none"
      ) +
      ggplot2::coord_sf(expand = FALSE) +
      ggplot2::labs(x = NULL, y = NULL) +
      bs_theme +
      ggplot2::theme(
        panel.background = ggplot2::element_rect(fill = "aliceblue"),
        axis.line        = ggplot2::element_blank()
      )

    return(add_facet(plt))
  }
}
