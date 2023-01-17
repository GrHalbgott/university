install.packages("terra")
library(terra)

# Übung 1

in_dir <- "../data/Level1/LC09_L1TP_138045_20220319_20220322_02_T1/"

read_raster <- function (dir) {
  terraStack <- list.files(dir, pattern = "_B[2-7].TIF$", full.names = T, recursive = F, all.files = F) |> terra::rast()
  names(terraStack) <- c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2")
  print(terraStack) |> plot() |> terra::plotRGB(r = 3, g = 2, b = 1, axes = TRUE, stretch = "lin") 
  return (terraStack)
}

plot_raster (in_raster) {
  
}


calc_ndvi <- function (dir) {
  stack <- read_raster(dir)
  ndvi <- (stack[[4]] - stack[[3]]) / (stack[[4]] + stack[[3]])
  terra::writeRaster(ndvi, paste0(in_dir, "20220319_ndvi.tif"), overwrite = T)
  plot(ndvi)# fix that
}

stack1 <- read_raster(in_dir)

# Übung 2

terra::plotRGB(stack1, r = 4, g = 3, b = 2, axes = TRUE, stretch = "lin")
stack1_crop <- crop(stack1, c(595122, 761087, 2329093, 2482092)) # TEST
terra::writeRaster(stack1, paste0(in_dir, "20220319_crop.tif"))

# Übung 3

DN_to_TOA <- function (dir) {
  meta_txt <- list.files(dir, pattern='MTL.txt$', recursive = T, full.names = T) |> read.delim(sep = '=', stringsAsFactors = F, header = F)
  names(meta_txt) <- c("VAR", "VAL")
  ref_mult_band <- as.numeric(meta_txt[grep("REFLECTANCE_MULT_BAND_[2-7]", meta_txt$VAR),][,2])
  ref_add_band <- as.numeric(meta_txt[grep("REFLECTANCE_ADD_BAND_[2-7]", meta_txt$VAR),][,2])
  ref_sun_elev <- as.numeric(meta_txt[grep("SUN_ELEVATION", meta_txt$VAR),][,2])
  TOA_wo_sun <- (ref_mult_band * stack1 + ref_add_band) * 10000 
  TOA_sun <- TOA_wo_sun / sin(ref_sun_elev + pi / 180) # or cos(90 - ref_sun_elev)
  terra::writeRaster(TOA_sun, paste0(in_dir, "20220319_toa.tif"), datatype = "INT2U", overwrite = T)
  plot(TOA_sun)
  return (TOA_sun)
}

new_TOA_sun <- DN_to_TOA(in_dir)
