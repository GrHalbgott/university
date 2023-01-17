# install.packages("terra")
library(terra)

# Übung 1

in_dir <- "./data/Level1/LC09_L1TP_138045_20220319_20220322_02_T1/"

pixel_qa <- list.files(in_dir, pattern = "PIXEL.TIF$", full.names = T, recursive = F, all.files = F) |> terra::rast() |> print()

df <- terra::freq(pixel_qa)
values <- df[order(-df$count),][1:4,] |> print()

i = 1
for (i in 0:length(values)) {
  rev(as.numeric(intToBits(values$count[i])[1:16])) |> print()
  i = i + 1
}

# terra::mask(df, bqa, maskvalues = filter, updatevalue = NA) # Fix this

# Übung 2

# install.packages("randomForest")
library(randomForest)

img1_s <- list.files(in_dir, pattern = "crop.tif$", full.names = T, recursive = F, all.files = F) |> terra::rast()
data <- list.files("./data/", pattern = "set.shp$", full.names = T, recursive = F, all.files = F) |> terra::vect()

train_data <- terra::project(data, crs(img1_s))

p_extract <- terra::extract(img1_s, train_data, df = T)
p_extract$class <- as.factor(train_data$class[match(p_extract$ID, seq(nrow(train_data)))])
rf_model <- randomForest::randomForest(class ~ .,
                                       data = p_extract,
                                       importance = T,
                                       ntree = 250,
                                       na.action = na.omit,
                                       proximity = T,
                                       keep.forest = T,
                                       replace = T)
rf_model
saveRDS(rf_model, "./data/result.rds")

rf <- readRDS("./data/result.rds")
# randomForest::partialPlot(rf,
                          as.data.frame(p_extract),
                          B5, "water",
                          main= "water",
                          ylab = "class probability",
                          xlab = "NIR (B5) reflectance",
                          ylim=c(-20, 20))

colors =
  c("#76b5c5","#76c576","#c5b576",
    "#1f431f", "#2e7b4f", "#7da1a8",
    "#737a7b", "#114677")
plot(rf, col = colors)

# class_img <- terra::predict(img1_s, rf, cores = 3, cpkgs =
                              "randomForest", filename =
                              "./data/RDSresults.tif", overwrite =
                              TRUE, wopt = list(datatype = "INT1U"))

classes <- data.frame(value =
                        c(1:length(rf$classes)),
                      class = rf$classes)
levels(class_img) <- classes
terra::plot(class_img, col = colors)