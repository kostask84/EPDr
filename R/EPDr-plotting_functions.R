# map_taxa_age -----------------------------------------------

#' Map pollen counts from a list of epd.entity.df objects
#' 
#' This function uses information on multiple \code{\link[EPDr]{epd.entity.df-class}}
#' objects to map counts for a particular taxa in a particular age (or time 
#' period). The function use ggplot function and allow for multiple 
#' parameters to further tune the resulting map. Each entity in the map 
#' is represented by a point, which size, border colour, and fill colour 
#' change according to the palynological count. When an entity is provided 
#' but it has no data for that particular age (or time period) the points 
#' are represented diferently to reflect \code{NA}, avoiding confusion 
#' with \code{0} (zero) values.
#'
#' @param x List of \code{\link[EPDr]{epd.entity.df-class}} objects that are 
#' going to be included in the map.
#' @param taxa Character string indicating the taxa that are going to 
#' be mapped.
#' @param sample_label Character string indicating the age (or time period) 
#' to be mapped.
#' @param pres_abse Logical value indicating whether the map will represent 
#' presence/absence or counts (absolute or percentages).
#' @param pollen_thres Logical value indicating the pollen count threshold 
#' to plot an specific count as presence or absence.
#' @param zoom_coords Numeric vector with 4 elements defining the bounding 
#' box of the map as geographical coordinates. It should have the 
#' following format \code{c(xmin, xmax, ymin, ymax)}. Where \code{x} 
#' represents longitude and \code{y} represents latitude. If not specified 
#' the function looks into the data and automatically selects an extent that 
#' encompases all entities.
#' @param points_pch Any value accepted for \code{pch} by
#' \code{\link[ggplot2]{geom_point}}. This controls for the symbol to represent
#' entities in the map.
#' @param points_colour Two elements vector with any values accepted for \code{colour}
#' by \code{\link[ggplot2]{geom_point}}. You can use this to change border
#' colours for points. The first element is used to select the border colour of the
#' absence/minimum values, whereas the second value selects the border colour for
#' presences/maximum values.
#' @param points_fill Two elements vector with any values accepted for \code{fill}
#' by \code{\link[ggplot2]{geom_point}}. You can use this to change fill colours
#' for points. The first element is used to select the fill colour of the absence/minimum
#' values, whereas the second value selects the fill colour for presences/maximum values.
#' @param points_range_size  Two elements vector with any values accepted for \code{size}
#' by \code{\link[ggplot2]{geom_point}}. You can use this to change point sizes.
#' The first element is used to select the size of the absence/minimum values, whereas the
#' second value selects the size for presences/maximum values.
#' @param map_title Character string with a title for the map.
#' @param legend_range Two elements vector with numeric values to set different min and max
#' limits of points representation. If you have a dataset where counts goes up to 98 but
#' want the map to represent until 100, you can set \code{legend_range = c(0,100)}. By default
#' the function uses the min and max values in the dataset.
#' @param legend_title Character string with a title for the legend.
#' @param napoints_size Any value accepted for \code{size} by
#' \code{\link[ggplot2]{geom_point}}. This control for the size of points
#' representing \code{NA} values.
#' @param napoints_colour Any value accepted for \code{colour} by
#' \code{\link[ggplot2]{geom_point}}. This control for the border colour of
#' points representing \code{NA} values.
#' @param napoints_fill  Any value accepted for \code{fill} by
#' \code{\link[ggplot2]{geom_point}}. This control for the fill colour of
#' points representing \code{NA} values.
#' @param countries_fill_colour Any value accepted for \code{fill} by
#' \code{\link[ggplot2]{borders}}. This control for the fill colour of polygons
#' representing countries.
#' @param countries_border_colour Any value accepted for \code{colour} by
#' \code{\link[ggplot2]{borders}}. This control for the border colour of polygons
#' representing countries. 
#'
#' @return The function displays a ggplot map with countries in the background and counts for particular taxa and age (or time periods) as points in the foreground.
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' epd.connection <- connect_to_epd(host = "localhost", database = "epd",
#'                                user = "epdr", password = "epdrpw")
#' entity.list <- list_e(epd.connection, country = c("Spain","Portugal",
#'                                                   "France", "Switzerland",
#'                                                   "Austria", "Italy",
#'                                                   "Malta", "Algeria",
#'                                                   "Tunisia", "Morocco",
#'                                                   "Atlantic ocean",
#'                                                   "Mediterranean Sea"))
#' epd.all <- lapply(entity.list$e_, get_entity, epd.connection)
#' epd.all <- lapply(epd.all, filter_taxagroups, c("HERB", "TRSH", "DWAR",
#'                                                 "LIAN", "HEMI", "UPHE"))
#' epd.all <- lapply(epd.all, giesecke_default_chron)
#' epd.all <- remove_restricted(epd.all)
#' epd.all <- remove_wo_ages(epd.all)
#' 
#' epd.int <- lapply(epd.all, interpolate_counts, seq(0, 22000, by = 1000))
#' epd.taxonomy <- get_taxonomy_epd(epd.connection)
#' epd.int <- lapply(epd.int, taxa_to_acceptedtaxa, epd.taxonomy)
#' epd.int <- unify_taxonomy(epd.int, epd.taxonomy)
#' 
#' epd.int.per <- lapply(epd.int, counts_to_percentage)
#' 
#' map_taxa_age(epd.int, "Cedrus", "21000", pres_abse = F)
#' map_taxa_age(epd.int, "Cedrus", "21000", pres_abse = T)
#' map_taxa_age(epd.int.per, "Cedrus", "21000", pres_abse = F)
#' map_taxa_age(epd.int.per, "Cedrus", "21000", pres_abse = T)
#' } 
map_taxa_age <- function(x, taxa, sample_label, pres_abse = FALSE,
                       pollen_thres = NULL, zoom_coords = NULL,
                       points_pch = 21, points_colour = NULL,
                       points_fill = NULL, points_range_size = NULL,
                       map_title = NULL, legend_range = NULL,
                       legend_title = NULL, napoints_size = 0.75,
                       napoints_colour = "grey45", napoints_fill = "grey45",
                       countries_fill_colour = "grey80",
                       countries_border_colour = "grey90"){
  if (class(x) == "list"){
    if (!(all(vapply(x, class, character(1)) == "epd.entity.df") ||
        all(vapply(x, class, character(1)) == "data.frame"))){
      stop("x of the wrong class. It has to be a list of epd.entity.df objects
           (see ?entityToMatrices) or data.frames (see ?table_by_taxa_age)")
    }else{
      if (class(x[[1]]) == "epd.entity.df"){
        data_list <- lapply(x, table_by_taxa_age, taxa, sample_label)
      }else{
        if (setequal(colnames(x[[1]]), c("e_", "londd", "latdd", "count",
                                         "sample_label", "taxa"))){
          data_list <- x
        }else{
          stop("data.frames in x of the wrong type. See ?table_by_taxa_age.")
        }
      }
    }
  }else{
    stop("x of the wrong class. It has to be a list of epd.entity.df objects
         (see ?getAgedCount) or data.frames (see ?table_by_taxa_age)")
  }
  data_list <- do.call(rbind, data_list)
  index <- which(data_list$londd < -175)
  data_list$londd[index] <- 360 + data_list$londd[index]
  if (is.null(zoom_coords)){
    xmin <- min(data_list$londd) - (0.005 * range(data_list$londd)[[1]])
    xmax <- max(data_list$londd) + (0.005 * range(data_list$londd)[[2]])
    ymin <- min(data_list$latdd) - (0.005 * range(data_list$latdd)[[1]])
    ymax <- max(data_list$latdd) + (0.005 * range(data_list$latdd)[[2]])
  }else{
    xmin <- zoom_coords[1]
    xmax <- zoom_coords[2]
    ymin <- zoom_coords[3]
    ymax <- zoom_coords[4]
  }
  counts_type <- x[[1]]@countstype
  if (pres_abse == TRUE){
    if (is.null(pollen_thres)){
      warning("Pollen threshold (pollen_thres) not provided as argment when
          requiring presence maps. Data maped using default threshold > 0%)")
      pollen_thres <- 0
    }
    data_list$count <- as.factor(data_list$count > pollen_thres)
    if (is.null(map_title)){
      map_title <- paste(taxa, " (>", pollen_thres, "): ",
                         sample_label, " cal BP", sep = "")
    }
    if (is.null(legend_title)){
      legend_title <- paste("Presence (>", pollen_thres, ")", sep = "")
    }
    if (is.null(points_colour)){
      points_colour <- c("Red 4", "Dodger Blue 3")
    }
    if (is.null(points_fill)){
      points_fill <- c("Red 2", "Dodger Blue 1")
    }
    if (is.null(points_range_size)){
      points_range_size <- c(2, 3.5)
    }
    nplot <- ggplot2::ggplot(data_list, ggplot2::aes(x = data_list$londd,
                                            y = data_list$latdd,
                                            fill = data_list$count,
                                            colour = data_list$count,
                                            size = data_list$count)) +
      ggplot2::borders("world",
                       fill = countries_fill_colour,
                       colour = countries_border_colour) +
      ggplot2::geom_point(pch = points_pch) +
      ggplot2::coord_quickmap(xlim = c(xmin, xmax), ylim = c(ymin, ymax)) +
      ggplot2::ggtitle(map_title) +
      ggplot2::guides(size = ggplot2::guide_legend(title = legend_title),
                      fill = ggplot2::guide_legend(title = legend_title),
                      colour = ggplot2::guide_legend(title = legend_title)) +
      ggplot2::scale_fill_manual(values = points_fill,
                                 na.value = napoints_fill) +
      ggplot2::scale_colour_manual(values = points_colour,
                                   na.value = napoints_colour) +
      ggplot2::scale_size_discrete(range = points_range_size,
                                   na.value = napoints_size) +
      ggplot2::scale_x_continuous(name = "Longitude") +
      ggplot2::scale_y_continuous(name = "Latitude") +
      ggplot2::theme_bw()
  }else{
    if (is.null(map_title)){
      map_title <- paste(taxa, ": ", sample_label, " cal BP", sep = "")
    }
    if (is.null(legend_title)){
      if (counts_type == "Percentages"){
        legend_title <- paste(counts_type, " (%)", sep = "")
      }else{
        legend_title <- paste(counts_type, " (n)", sep = "")
      }
    }
    if (is.null(legend_range)){
      if (counts_type == "Percentages"){
        legend_range <- c(0, max(data_list$count))
      }else{
        legend_range <- c(0, max(data_list$count))
      }
    }
    if (is.null(points_colour)){
      points_colour <- c("Blue 1", "Blue 3")
    }
    if (is.null(points_fill)){
      points_fill <- c("Light Blue 1", "Blue 3")
    }
    if (is.null(points_range_size)){
      points_range_size <- c(2, 7)
    }
    nplot <- ggplot2::ggplot(data_list, ggplot2::aes(x = data_list$londd,
                                 y = data_list$latdd,
                                 fill = data_list$count,
                                 colour = data_list$count,
                                 size = data_list$count)) +
      ggplot2::borders("world",
                       fill = countries_fill_colour,
                       colour = countries_border_colour) +
      ggplot2::geom_point(colour = napoints_colour,
                          fill = napoints_fill,
                          size = napoints_size,
                          show.legend = TRUE) +
      ggplot2::geom_point(pch = points_pch) +
      ggplot2::coord_quickmap(xlim = c(xmin, xmax), ylim = c(ymin, ymax)) +
      ggplot2::ggtitle(map_title) +
      ggplot2::guides(size = ggplot2::guide_legend(title = legend_title),
                      fill = ggplot2::guide_legend(title = legend_title),
                      colour = ggplot2::guide_legend(title = legend_title)) +
      ggplot2::scale_fill_gradient(low = points_fill[1],
                                   high = points_fill[2],
                                   limits = legend_range) +
      ggplot2::scale_colour_gradient(low = points_colour[1],
                                     high = points_colour[2],
                                     limits = legend_range) +
      ggplot2::scale_size(range = points_range_size, limits = legend_range) +
      ggplot2::scale_x_continuous(name = "Longitude") +
      ggplot2::scale_y_continuous(name = "Latitude") +
      ggplot2::theme_bw()
  }
  nplot
  return(nplot)
}



# plot_diagram -----------------------------------------------

#' Plot pollen diagram of an entity
#'
#' The function takes information on an \code{\link[EPDr]{epd.entity.df-class}} object
#' and plot a pollen diagram. The function also return the ggplot object, so the 
#' object can be stored and afterward combined with other plots.
#'
#' @param x epd.entity.df An object of class \code{\link[EPDr]{epd.entity.df-class}}.
#' @param chronology numeric A number indicating the chronology to be used in 
#' the pollen diagram. If not specified the default chronology specified in
#' \code{x} is used.
#' @param use_ages logical Indicating whether to plot the pollen diagram
#' with ages or depth of the samples. 
#' @param exag_low_values numeric A single value indicating an exageration
#' factor to improve visibility of low pollen values.
#' @param color_by_group logical or numeric or character If logical and
#' TRUE the function plot all taxa from the same taxa groups with the 
#' same color. If FALSE, each taxon will be represented in a different 
#' color. If numeric or character \code{color_by_group} should have
#' length equal number of taxa in \code{x} indicating the color to be used.
#' @param order_taxa logical or numeric. If logical and TRUE the diagram is
#' arranged to show taxa from maximum pollen count (at the left) to
#' minimum pollen count (at the right). If numeric \code{order_taxa} should
#' be length equal the number of taxa in \code{x} indicating the position in
#' which to plot each taxon.
#' @param x_breaks numeric Vector of numbers indicating the break points 
#' for the age-depth axis.
#' @param y_breaks numeric Vector of numbers indicating the break points
#' for the pollen counts axis.
#' @param legend_position character One element character indicating the
#' desired position of the legend (\code{"bottom"}, \code{"left"}, 
#' \code{"right"}, or \code{"upper"}).
#' @param legend_title character One element character indicating the 
#' title of the legend.
#' @param ... Not used with current methods.
#'
#' @return The function returns a ggplot object with the pollen diagram. It
#' can be stored and plotted afterwards.
#' 
#' @references \url{http://blarquez.com/684-2/}
#' 
#' @examples
#' \dontrun{
#' epd.connection <- connect_to_epd()
#' epd.1 <- get_entity(1, epd.connection)
#' epd.1 <- entity_to_matrices(epd.1)
#' epd.1 <- filter_taxagroups(epd.1, c("DWAR", "HERB", "TRSH"))
#' epd.1.per <- counts_to_percentage(epd.1)
#' plot_diagram(epd.1)
#' plot_diagram(epd.1.per)
#' }
#' @rdname plot_diagram
#' @exportMethod plot_diagram
setGeneric("plot_diagram",
           function(x,
                    chronology = NULL,
                    use_ages = TRUE,
                    exag_low_values = 10,
                    color_by_group = TRUE,
                    order_taxa = TRUE,
                    x_breaks = NULL,
                    y_breaks = NULL,
                    legend_position = NULL,
                    legend_title = "Legend"){
             standardGeneric("plot_diagram")
})

#' @rdname plot_diagram
setMethod("plot_diagram",
  signature(x = "epd.entity.df"),
  function(x,
           chronology,
           use_ages,
           exag_low_values,
           color_by_group,
           order_taxa,
           x_breaks,
           y_breaks,
           legend_position,
           legend_title){
    counts <- x@commdf@counts
    maxcounts <- apply(counts, MARGIN = 2,
                       FUN = max, na.rm = TRUE)
    dec_order <- order(maxcounts, decreasing = TRUE)
    if (length(order_taxa) == 1 & is.logical(order_taxa)){
      if (order_taxa == TRUE){
        order <- dec_order
      } else if (order_taxa == FALSE){
        order <- seq_along(counts)
      }
    } else if (length(order_taxa) == ncol(counts) && is.numeric(order_taxa)){
      order <- order_taxa
    } else {
      stop(paste0("'order_taxa' of the wrong format. Check ",
                  "'?plot_diagram' for valid formats information."))
    }
    counts <- counts[, order]
    maxcounts <- maxcounts[order]
    if (is.null(chronology)){
      chronology <- x@defaultchron
    }
    if (chronology == 9999){
      chronology <- "giesecke"
    }
    if (use_ages){
      if (nrow(x@agesdf@depthages) == 0){
        warning(paste0("The entity has not ages, and hence depths will be ",
                       "used for the y axis of the pollen diagram."))
        ages <- x@agesdf@depthcm
        xlabel <- "Depth (cm)"
        if (is.null(x_breaks)){
          x_breaks <- seq(0, 10000, 500)
        }
      }else{
        ages <- x@agesdf@depthages[, as.character(chronology)]
        xlabel <- "Age (cal. BP)"
        if (is.null(x_breaks)){
          x_breaks <- seq(0, 100000, 500)
        }
      }
    }else{
      ages <- x@agesdf@depthcm
      xlabel <- "Depth (cm)"
      if (is.null(x_breaks)){
        x_breaks <- seq(0, 10000, 50)
      }
    }
    if (is.null(color_by_group)) {
      color_by_group <- TRUE
    }
    if (is.logical(color_by_group) && length(color_by_group) == 1){
      if (color_by_group == TRUE){
        groups <- x@commdf@taxagroupid[order]
        if (is.null(legend_position)){
          legend_position <- "right"
        }
      }else{
        groups <- x@commdf@taxanames[order]
        if (is.null(legend_position)){
          legend_position <- "none"
        }
    }
    }else if (length(color_by_group) == ncol(counts)){
      groups <- color_by_group # Do not specify order
      if (is.null(legend_position)){
        legend_position <- "right"
      }
    }else{
      stop(paste0("wrong length or format in 'color_by_group'. ",
                  "Check '?plot_diagram' for valid format."))
    }
    if (x@countstype == "Percentages"){
      ylabel <- "Percentage (%)"
      if (is.null(y_breaks)){
        y_breaks <- seq(0, 100, 10)
      }
    }else{
      ylabel <- "Counts (n)"
      if (is.null(y_breaks)){
        y_breaks <- seq(0, max(maxcounts), 10)
      }
    }
    if (is.numeric(exag_low_values)){
      if (length(exag_low_values) > 1){
        warning(paste0("'length(exag_low_values) > 1' hence ",
                       "only the first value will be used."))
        exag_low_values <- exag_low_values[1]
      }
      maxcounts <- as.data.frame(
        do.call(rbind,
                replicate(nrow(counts),
                          maxcounts,
                          FALSE)))
      exag <- counts * exag_low_values
      exag <- pmin(exag, maxcounts)
    }else{
      stop(paste0("'exag_low_values' has to be numeric and
                          'length(exag_low_values) == 1'"))
    }
    df <- reshape2::melt(counts)
    exag <- reshape2::melt(exag)
    df$yr <- rep(ages, ncol(counts))
    df$group <- rep(groups, each = nrow(counts))
    df$exag <- exag$value
    theme_new <- ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      axis.line = ggplot2::element_line(colour = "black"),
      strip.text.x = ggplot2::element_text(size = 10,
                                           angle = 90,
                                           vjust = 0),
      strip.background = ggplot2::element_blank(),
      strip.text.y = ggplot2::element_text(angle = 0),
      panel.border = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(angle = 90,
                                          hjust = 1),
      legend.position = legend_position)
    nplot <- ggplot2::ggplot(df) +
      ggplot2::geom_area(ggplot2::aes(df$yr,
                                      df$exag,
                                      fill = df$group)) +
      ggplot2::geom_area(ggplot2::aes(df$yr,
                                      df$value)) +
      ggplot2::scale_x_reverse(breaks = x_breaks) +
      ggplot2::scale_y_continuous(breaks = y_breaks) +
      ggplot2::xlab(xlabel) +
      ggplot2::ylab(ylabel) +
      ggplot2::scale_fill_discrete(name = legend_title) +
      ggplot2::coord_flip() +
      theme_new +
      ggplot2::facet_grid(~df$variable,
                          scales = "free",
                          space = "free")
    nplot
    return(nplot)
  })
