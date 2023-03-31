#!/usr/bin/env r
#==================================================
# R script to create a time-series analysis of the Harz, Germany
# Author: Niko Kolaxidis
# Date: 31.03.2023
# Data: Sentinel-2 raster data in the period 2018-2020
#==================================================

#=====================
## IMPORTS & LOGGER ##
#=====================

pkgs <- c("rstudioapi", "logger", "terra", "raster", "sen2r", "rasterVis", "RColorBrewer", "ggplot2")
# install.packages(pkgs)
lapply(pkgs, require, character.only = TRUE)

log_threshold(DEBUG)

#=======================================
## WORKING DIRECTORY, PATHS & FOLDERS ##
#=======================================

# Set working directiory to (this) script path
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

in_dir <- "../data"
out_dir <- "../export"
res_dir <- "../results"

dir.create(file.path(out_dir))
dir.create(file.path(res_dir))

#==============
## FUNCTIONS ##
#==============

f_make_stack <- function(dir) {
    # Reads raster files (bands 2-4 & 8), creates a raster stack and changes the layer names
    # You would reproject the files as well, but since we are using the same source, it's fine
    terraStack <- list.files(
        dir, pattern = "_B0[4|8].jp2$", full.names = TRUE, recursive = TRUE, all.files = FALSE
        ) |> terra::rast()
    names(terraStack) <- c("Red", "NIR")
    return(terraStack)
}

f_create_name <- function(meta) {
    # Reads values in meta data file and creates output name
    prod_date <- xml2::xml_find_all(meta, "//DATATAKE_SENSING_START")
    prod_v <- as.character(as.Date(trimws(xml2::xml_text(prod_date))))
    prod_uri <- xml2::xml_find_all(meta, "//PRODUCT_URI")
    prod_uri_v <- as.character(trimws(xml2::xml_text(prod_uri)))
    prod_uri_split <- unlist(strsplit(prod_uri_v, "\\_"))
    tile <- prod_uri_split[6]
    name <- paste0(gsub("-", "", prod_v), "_", tile)
    return(name)
}

f_calc_ndvi <- function(red, nir) {
    # Calculates ndvi by taking two layers from raster stack
    ndvi <- (nir - red) / (nir + red)
    return(ndvi)
}

f_read_vector <- function(name) {
    # Reads vector file and returns vector object
    terraVect <- terra::vect(file.path(in_dir, paste0(name, ".shp")))
    return(terraVect)
}

f_read_raster <- function(file) {
    # Reads raster files as terra raster stack
    terraStack <- terra::rast(file)
    return(terraStack)
}

f_merge_raster <- function(raster1, raster2) {
    # Merges two raster images together and creates raster stack with larger extent
    terraStack <- terra::merge(
        f_read_raster(raster1), f_read_raster(raster2), first = FALSE, na.rm = TRUE
    )
    return(terraStack)
}

f_crop_raster <- function(data, bbox) {
    # Crops raster stack depending on aoi parameter
    aoi_bbox <- f_read_vector(bbox) |> terra::ext()
    ts_crop <- terra::crop(data, aoi_bbox)
    ts <- raster::stack(ts_crop)
    return(ts)
}

f_derive_statistics <- function(year, aoi) {
    # Calculate descriptive statistics and return dataframe
    ts_ndvi <- list.files(out_dir, pattern = paste0("^", year), full.names = TRUE) |> terra::rast()
    data <- f_crop_raster(ts_ndvi, aoi)

    df_ndvi <- as.data.frame(round(raster::cellStats(data, "mean"), digits = 3))
    names(df_ndvi) <- "Mean"
    dates <- gsub("X", "", row.names(df_ndvi))
    df_ndvi$month <- format(as.Date(dates, format = "%Y.%m.%d"), "%m")
    df_ndvi$Year <- format(as.Date(dates, format = "%Y.%m.%d"), "%Y")
    df_ndvi$Min <- round(raster::cellStats(data, "min"), digits = 3)
    df_ndvi$Max <- round(raster::cellStats(data, "max"), digits = 3)
    df_ndvi$Stddev <- round(raster::cellStats(data, "sd"), digits = 3)
    df_ndvi$Skew <- round(raster::cellStats(data, "skew"), digits = 3)
    df_ndvi$Aoi <- aoi
    df_ndvi <- df_ndvi[, c(3, 2, 8, 1, 4:7)]
    return(df_ndvi)
}

f_make_levelplot <- function(data, aoi) {
    # Creates plot with levelplot
    cols <- colorRampPalette(RColorBrewer::brewer.pal(9, "RdYlGn"))
    plot <- rasterVis::levelplot(
        data,
        layout = c(4, 5),
        col.regions = cols,
        at = seq(-0.2, 1, len = 9),
        main = paste("NDVI Time-Series \nHarz 2018-2020 for", aoi),
        names.attr = names(data),
        scales = list(draw = FALSE)
    )
    return(plot)
}

f_make_histogram <- function(data, aoi) {
    # Creates histogram
    plot <- rasterVis::histogram(
        data,
        col = "gray",
        xlim = c(-0.2, 1),
        ylab = "NDVI",
        main = paste("NDVI Time-Series \nHarz 2018-2020 for", aoi)
    )
    return(plot)
}

#=========
## DATA ##
#=========

# Open GUI and load sen2r_settings.json file
# use ../data/bbox.shp as extent or define your own
# same applies to aoi

# sen2r() # doesn't work due to order quota

# Otherwise just put your unzipped Sentinel-2 folders (.SAFE) in data_dir

#==================
## MAIN: CLEANUP ##
#==================

log_info("Cleaning up...")

gc()
# file.remove(dir(out_dir, full.names = TRUE)) # use to clean export folder when running preprocessing again
file.remove(dir(res_dir, full.names = TRUE))
file.remove(dir(tempdir(), full.names = TRUE))
if (file.exists(tempfile())) {
    file.remove(tempfile())
}

log_success("...finished cleanup.")

#========================
## MAIN: PREPROCESSING ##
log_info("Preprocessing...")
#========================

if (length(list.files(out_dir)) == 0) { # skip preprocessing if it has already run
    # List all level 1 sub-directories within in_dir
    dir_list <- list.dirs(in_dir, full.names = TRUE, recursive = FALSE)

    # Extract extent from shapefile and use coords to create "bbox"
    bbox <- f_read_vector("bbox") |> terra::ext()

    # Iterate through all data folders, crop & name files and create ndvi results
    for (dir in dir_list){
        # Read meta data file
        s2_meta <- list.files(dir, pattern = "MTD_MSIL1C.xml$", full.names = TRUE, recursive = TRUE) |> xml2::read_xml()
        # String slicing the long dir name for easier handling
        name <- f_create_name(s2_meta)

        # Give path as parameter to function read_raster() and clip resulting stack with bbox
        stack <- f_make_stack(dir) |> terra::crop(bbox)

        # Masking values with cloud mask not possible without mask band (not available prior 2022)

        # Calculate ndvi with bands 1/red & 2/nir and write raster
        ndvi_name <- paste0(name, "_ndvi.tif")
        rast_ndvi <- f_calc_ndvi(stack[[1]], stack[[2]]) |> terra::writeRaster(
            file.path(out_dir, ndvi_name)
            )
        log_success(paste0("...", ndvi_name, " written to disk."))
    }


    log_info("...merging NDVI files...")

    file_list <- list.files(out_dir)
    total_i <- length(file_list)
    # Create iterators to be able to group 1+2, 3+4 etc.
    i1 <- 1
    i2 <- 2

    # Iterate through file liste and merge ndvi results together
    for (i in 1:(total_i / 2)) {
        # String slicing the file names for final file name
        name_first <- strsplit(file_list[i1], "_")[[1]][1]
        name_second <- strsplit(file_list[i2], "_")[[1]][1]

        if (name_first == name_second) {
            # Create a final file name
            final_name <- paste0(name_first, "_ndvi_merge.tif")

            # Use iterators to group together respective ndvi files
            raster1 <- file.path(out_dir, file_list[i1])
            raster2 <- file.path(out_dir, file_list[i2])
            merged_raster <- f_merge_raster(raster1, raster2)
            # Rename layer to date and write to disk
            names(merged_raster) <- as.Date(name_first, format = "%Y%m%d")
            terra::writeRaster(merged_raster, file.path(out_dir, final_name))

            log_success(paste0("...", final_name, " written to disk."))

            # Remove original files
            file.remove(raster1, raster2)

            i1 <- i1 + 2
            i2 <- i1 + 1
        } else {
            log_error("ERROR: Filenames do not match. Exiting.")
            exit()
        }
    }
}

log_info("Finished preprocessing.")

#===============================
## MAIN: TIME-SERIES ANALYSIS ##
log_info("Analyzing time-series...")
#===============================

aoi_list <- list("aoi1", "aoi2")

# Use multiple aois to derive statistics
for (aoi in aoi_list) {

    log_info(paste0("...calculating statistics for ", aoi, "..."))

    # Run f_derive_statistics() for multiple years (seperate stacks)
    df_2018 <- f_derive_statistics("2018", aoi)
    df_2019 <- f_derive_statistics("2019", aoi)
    df_2020 <- f_derive_statistics("2020", aoi)

    # Combine all years to one dataframe (to plot them together)
    df <- rbind(df_2018, df_2019, df_2020)

    write.csv(df, file.path(res_dir, paste0("df_ndvi_", aoi, ".csv")), row.names = FALSE)

    log_info(paste0("...plotting statistics for ", aoi, "..."))

    # Using ggplot to plot multiple linegraphs into one (seperate by years), plot all statistics
    plot_mean <- ggplot(df, aes(month, Mean, colour = Year), na.rm = TRUE) +
        geom_point(size = 3, aes(group = Year)) +
        geom_line(aes(group = Year)) +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 13), limits = c(-0.2, 1)) +
        ggtitle(paste("NDVI Time-Series in Harz 2018-2020\nMean NDVI for", aoi)) +
        xlab("Month") + ylab("Mean NDVI") +
        theme(text = element_text(size = 24))
    ggsave(paste0("plot_mean_", aoi, ".png"), path = res_dir, dpi = 120)

    plot_min <- ggplot(df, aes(month, Min, colour = Year), na.rm = TRUE) +
        geom_point(size = 3, aes(group = Year)) +
        geom_line(aes(group = Year)) +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 13), limits = c(-0.2, 1)) +
        ggtitle(paste("NDVI Time-Series in Harz 2018-2020\nMin NDVI for", aoi)) +
        xlab("Month") + ylab("Min NDVI") +
        theme(text = element_text(size = 24))
    ggsave(paste0("plot_min_", aoi, ".png"), path = res_dir, dpi = 120)

    plot_max <- ggplot(df, aes(month, Max, colour = Year), na.rm = TRUE) +
        geom_point(size = 3, aes(group = Year)) +
        geom_line(aes(group = Year)) +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 13), limits = c(-0.2, 1)) +
        ggtitle(paste("NDVI Time-Series in Harz 2018-2020\nMax NDVI for", aoi)) +
        xlab("Month") + ylab("Max NDVI") +
        theme(text = element_text(size = 24))
    ggsave(paste0("plot_max_", aoi, ".png"), path = res_dir, dpi = 120)

    plot_std <- ggplot(df, aes(month, Stddev, colour = Year), na.rm = TRUE) +
        geom_point(size = 3, aes(group = Year)) +
        geom_line(aes(group = Year)) +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 13), limits = c(0, 0.25)) +
        ggtitle(paste("NDVI Time-Series in Harz 2018-2020\nStandard deviation NDVI for", aoi)) +
        xlab("Month") + ylab("Standard deviation NDVI") +
        theme(text = element_text(size = 24))
    ggsave(paste0("plot_std_", aoi, ".png"), path = res_dir, dpi = 120)

    plot_skew <- ggplot(df, aes(month, Skew, colour = Year), na.rm = TRUE) +
        geom_point(size = 3, aes(group = Year)) +
        geom_line(aes(group = Year)) +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 13), limits = c(-1.5, 0.5)) +
        ggtitle(paste("NDVI Time-Series in Harz 2018-2020\nSkewness NDVI for", aoi)) +
        xlab("Month") + ylab("Skewness NDVI") +
        theme(text = element_text(size = 24))
    ggsave(paste0("plot_skew_", aoi, ".png"), path = res_dir, dpi = 120)

    # Plotting boxplot not possible with cellStats (from f_derive_statistics()), therefore "fake" boxplot
    plot_bar <- ggplot(df, aes(month, Mean, colour = Year), na.rm = FALSE) +
        geom_crossbar(aes(ymin = Min, ymax = Max), width = 0.5, position = "dodge") +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 13), limits = c(-0.2, 1)) +
        ggtitle(paste("NDVI Time-Series in Harz 2018-2020\nMin - Mean - Max NDVI for", aoi)) +
        xlab("Month") + ylab("NDVI") +
        theme(text = element_text(size = 24))
    ggsave(paste0("plot_bar_", aoi, ".png"), path = res_dir, dpi = 120)
}

log_info("...plotting overview plots...")

ts_ndvi <- list.files(out_dir, pattern = ".tif$", full.names = TRUE) |> terra::rast()

log_info("...plotting full scene...")

# Use rasterVis to plot every layer of stack into one large figure (ndvi values and histogram)
ts_rv <- raster::stack(ts_ndvi)
aoi_text <- "full scene"
rv_plot <- f_make_levelplot(ts_rv, aoi_text)
rv_hist <- f_make_histogram(ts_rv, aoi_text)

log_info("...plotting aoi1...")

aoi_bbox1 <- f_read_vector("aoi1") |> terra::ext()
ts_rv1 <- terra::crop(ts_ndvi, aoi_bbox1) |> raster::stack()
aoi1_text <- "AOI 1"
rv_plot1 <- f_make_levelplot(ts_rv1, aoi1_text)
rv_hist1 <- f_make_histogram(ts_rv1, aoi1_text)

log_info("...plotting aoi2...")

aoi_bbox2 <- f_read_vector("aoi2") |> terra::ext()
ts_rv2 <- terra::crop(ts_ndvi, aoi_bbox2) |> raster::stack()
aoi2_text <- "AOI 2"
rv_plot2 <- f_make_levelplot(ts_rv2, aoi2_text)
rv_hist2 <- f_make_histogram(ts_rv2, aoi2_text)

#=========
log_success("...finished!")
#=========
