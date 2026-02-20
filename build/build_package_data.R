# build package data

library(dplyr)

# get data from other project
path <- file.path("../format_bioshifts_data/data-processed/final")
files <- list.files(path)
path.out <- "inst/extdata"

# articles -----
files[1]
articles <- readr::read_csv(file.path(path, "articles.csv"))
saveRDS(articles,
        file.path(path.out,"articles.rds"))

# author -------
files[2]
author_reported <- readr::read_csv(file.path(path, "author.csv"))
saveRDS(author_reported,
        file.path(path.out,"author_reported.rds"))

# baselines ----
files[3]
baselines <- readr::read_csv(file.path(path, "baselines.csv"))
saveRDS(baselines,
        file.path(path.out,"baselines.rds"))

# cv -------
files[4]
cv <- readr::read_csv(file.path(path,"cv.csv"))
saveRDS(cv,
        file.path(path.out,"cv.rds"))

# common taxa -----
files[5]
common_taxa <- readRDS(file.path(path, "internal_common_list.rds"))
saveRDS(common_taxa,
        file.path(path.out,"common_taxa.rds"))

# common countries -----
files[6]
common_continent <- readRDS(file.path(path, "internal_poly_countries.rds"))
saveRDS(common_continent,
        file.path(path.out,"common_continent.rds"))

#methods ---------
files[7]
methods <- readr::read_csv(file.path(path,"methods.csv"))
saveRDS(methods,
        file.path(path.out,"methods.rds"))

# poly info -----
files[8]
poly_info <- readr::read_csv(file.path(path,"poly_info.csv"))
saveRDS(poly_info,
        file.path(path.out,"poly_info.rds"))

# shifts -------
files[9]
shifts <- readr::read_csv(file.path(path, "shifts.csv"))
saveRDS(shifts,
        file.path(path.out,"shifts.rds"))

# sp baselines ------
files[10]
sp_baselines <- readr::read_csv(file.path(path, "sp_baselines.csv"))
saveRDS(sp_baselines,
        file.path(path.out,"sp_baselines.rds"))

# sp cvs ---------
files[11]
sp_cv <- readr::read_csv(file.path(path, "sp_cv.csv"))
saveRDS(sp_cv,
        file.path(path.out,"sp_cv.rds"))

# sp poly info -------
files[12]
sp_poly_info <- readr::read_csv(file.path(path,"sp_poly_info.csv"))
saveRDS(sp_poly_info,
        file.path(path.out,"sp_poly_info.rds"))


# sp trends -------
files[13]
sp_trends <- readr::read_csv(file.path(path, "sp_trends.csv"))
saveRDS(sp_trends,
        file.path(path.out,"sp_trends.rds"))

# taxo --------
files[14]
taxo <- readr::read_csv(file.path(path,"taxo.csv"))
saveRDS(taxo,
        file.path(path.out,"taxo.rds"))


# trends ------
files[15]
trends <- readr::read_csv(file.path(path, "trends.csv"))
saveRDS(trends,
        file.path(path.out,"trends.rds"))

