#' Autoplot species range shifts from the BioShifts database
#'
#' Quickly visualise range shift data returned by `get_shifts()` (or a filtered
#' subset of it) in one of three ways: a per-study dot plot, a distribution by
#' range parameter, or a spatial polygon map.
#'
#' @param data Range shift data from `get_shifts()`, typically filtered to the
#'   species or studies of interest before passing in.
#' @param plottype One of `"point"` (per-study dot plot with group means),
#'   `"boxplot"` (distribution of rates by range parameter), or `"map"`
#'   (species-specific polygons on a world map, coloured by shift rate).
#'   Partial matching is supported.
#' @param facet Optional character string giving the name of a column in `data`
#'   to use as a `facet_wrap()` grouping variable.
#' @param polygon_folder Path to the folder containing locally-downloaded
#'   polygon files from `download_polygons()`. Only used when
#'   `plottype = "map"`. Defaults to `"./BioShiftR_polygons"`.
#'
#' @returns A ggplot2 object.
#' @export
#'
#' @examples
#' # Per-study dot plot for two bird species
#' get_shifts(group = "Birds", continent = "Europe") |>
#'   dplyr::filter(sp_name_checked %in% c(
#'     "Troglodytes_troglodytes",
#'     "Fringilla_coelebs"
#'   )) |>
#'   bs_autoplot(plottype = "point")
#'
#' # Boxplot of shift rate distributions by range parameter
#' get_shifts(group = "Birds", type = "LAT") |>
#'   dplyr::filter(sp_name_checked == "Troglodytes_troglodytes") |>
#'   bs_autoplot(plottype = "boxplot")
#'
#' \dontrun{
#' # Map requires downloaded polygons (see ?download_polygons)
#' download.polygons(type = "SP")
#' get_shifts(group = "Birds", continent = "Europe") |>
#'   dplyr::filter(sp_name_checked == "Troglodytes_troglodytes") |>
#'   bs_autoplot(plottype = "map")
#' }
bs_autoplot <- function(data,
                        plottype = c("point", "boxplot", "map"),
                        facet = NULL,
                        polygon_folder = "./BioShiftR_polygons") {
  plottype <- match.arg(plottype)

  # input validation ---------------------------------------------------------
  required_cols <- c("calc_rate", "param", "article_id", "type")
  missing_cols <- setdiff(required_cols, colnames(data))
  if (length(missing_cols) > 0) {
    stop(paste0(
      "data is missing required columns: ",
      paste(missing_cols, collapse = ", ")
    ), call. = FALSE)
  }

  if (nrow(data) == 0) {
    stop("data contains no rows. Filter to species of interest before calling bs_autoplot().",
      call. = FALSE
    )
  }


  # shared helpers -----------------------------------------------------------

  # human-readable labels for param and type
  param_labels <- c(
    "LE" = "Leading Edge",
    "TE" = "Trailing Edge",
    "O"  = "Centre"
  )

  # colour palette keyed to the human-readable labels
  param_colours <- c(
    "Leading Edge"  = "tomato2",
    "Trailing Edge" = "cyan4",
    "Centre"        = "#dfa9f5"
  )

  type_labels <- c(
    "LAT" = "Latitudinal",
    "ELE" = "Elevational"
  )

  # y-axis label: use calc_unit if available; otherwise generic
  if ("calc_unit" %in% colnames(data)) {
    units <- unique(data$calc_unit)
    unit_str <- if (length(units) == 1) paste0("(", units, ")") else "(km/year or m/year)"
  } else {
    unit_str <- "(km/year or m/year)"
  }
  y_label <- paste("Range Shift Rate", unit_str)

  # shared publication-ready theme
  bs_theme <- ggplot2::theme_classic(base_size = 11) +
    ggplot2::theme(
      strip.background  = ggplot2::element_blank(),
      strip.text        = ggplot2::element_text(face = "bold"),
      axis.line         = ggplot2::element_line(colour = "black"),
      panel.spacing     = ggplot2::unit(0.8, "lines"),
      legend.key        = ggplot2::element_blank()
    )

  # helper to optionally add facet_wrap
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


  # ── point plot ─────────────────────────────────────────────────────────────
  if (plottype == "point") {
    # compute per-group means for the dashed reference lines
    avg <- data |>
      dplyr::group_by(.data$type, .data$param) |>
      dplyr::summarise(
        calc_rate = mean(.data$calc_rate, na.rm = TRUE),
        .groups = "drop"
      )

    # apply readable labels
    plot_data <- data |>
      dplyr::mutate(
        param = factor(.data$param,
          levels = names(param_labels),
          labels = param_labels
        ),
        type = factor(.data$type,
          levels = names(type_labels),
          labels = type_labels
        )
      )

    avg <- avg |>
      dplyr::mutate(
        param = factor(.data$param,
          levels = names(param_labels),
          labels = param_labels
        ),
        type = factor(.data$type,
          levels = names(type_labels),
          labels = type_labels
        )
      )

    plt <- ggplot2::ggplot(
      plot_data,
      ggplot2::aes(
        x = .data$article_id, y = .data$calc_rate,
        colour = .data$param
      )
    ) +
      ggplot2::geom_hline(yintercept = 0, linewidth = 0.4, colour = "grey40") +
      ggplot2::geom_hline(
        data = avg,
        ggplot2::aes(yintercept = .data$calc_rate, colour = .data$param),
        linetype = "dashed", linewidth = 0.5, show.legend = FALSE
      ) +
      ggplot2::geom_point(alpha = 0.8, size = 1.5) +
      ggplot2::scale_colour_manual(
        values = param_colours,
        name = "Range\nParameter"
      ) +
      ggplot2::labs(
        x = "Study",
        y = y_label
      ) +
      bs_theme +
      ggplot2::theme(
        axis.text.x  = ggplot2::element_blank(),
        axis.ticks.x = ggplot2::element_blank()
      )

    # only add type faceting if both types are present
    if (dplyr::n_distinct(data$type) > 1) {
      plt <- plt + ggplot2::facet_grid(param ~ type, scales = "free_x")
    } else {
      plt <- plt + ggplot2::facet_wrap(~param, scales = "free_x", ncol = 1)
    }

    plt <- add_facet(plt)
    return(plt)
  }


  # ── boxplot ────────────────────────────────────────────────────────────────
  if (plottype == "boxplot") {
    plot_data <- data |>
      dplyr::mutate(
        param = factor(.data$param,
          levels = names(param_labels),
          labels = param_labels
        )
      )

    plt <- ggplot2::ggplot(
      plot_data,
      ggplot2::aes(x = .data$param, y = .data$calc_rate, colour = .data$param)
    ) +
      ggplot2::geom_hline(yintercept = 0, linewidth = 0.4, colour = "grey40") +
      ggplot2::geom_point(
        position = ggplot2::position_jitter(width = 0.15, height = 0),
        alpha = 0.5, size = 1.2
      ) +
      ggplot2::geom_boxplot(
        width = 0.25, fill = "transparent", colour = "black",
        outliers = FALSE, linewidth = 0.5
      ) +
      ggplot2::scale_colour_manual(values = param_colours, guide = "none") +
      ggplot2::labs(
        x = "Range Parameter",
        y = y_label
      ) +
      bs_theme

    plt <- add_facet(plt)
    return(plt)
  }


  # ── map ────────────────────────────────────────────────────────────────────
  if (plottype == "map") {
    if (!"sp_name_checked" %in% colnames(data)) {
      stop("plottype = 'map' requires a 'sp_name_checked' column in data.",
        call. = FALSE
      )
    }

    if (!requireNamespace("rnaturalearth", quietly = TRUE)) {
      stop("plottype = 'map' requires the 'rnaturalearth' package. ",
        "Install it with: install.packages('rnaturalearth')",
        call. = FALSE
      )
    }

    filename <- "sp_polygons_simplified.rds"
    path <- file.path(polygon_folder, filename)

    if (!file.exists(path)) {
      stop(
        "Polygons not found locally. Please run download_polygons(type = 'SP'), ",
        "or set polygon_folder to the directory where they are saved.",
        call. = FALSE
      )
    }

    sp <- stringr::str_replace(unique(data$sp_name_checked), " ", "_")

    polys <- readRDS(path) |>
      dplyr::filter(sp_name_checked %in% sp) |>
      dplyr::right_join(data,
        by = dplyr::join_by(article_id, poly_id, sp_name_checked)
      )

    bbox <- sf::st_bbox(sf::st_buffer(sf::st_union(polys), 2))

    # apply ssqrt transform if ggallin is available
    rate_trans <- if (requireNamespace("ggallin", quietly = TRUE)) {
      ggallin::ssqrt_trans
    } else {
      message("Install 'ggallin' for a better colour scale transform on the map.")
      "identity"
    }

    plt <- ggplot2::ggplot(data = polys) +
      ggplot2::geom_sf(
        data = rnaturalearth::ne_countries(returnclass = "sf") |>
          sf::st_crop(bbox),
        fill = "grey88", colour = "white", linewidth = 0.2
      ) +
      ggplot2::geom_sf(
        ggplot2::aes(fill = .data$calc_rate, colour = .data$calc_rate),
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

    plt <- add_facet(plt)
    return(plt)
  }
}
