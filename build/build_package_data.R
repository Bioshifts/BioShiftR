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
# remove unneeded columns
methods <- methods %>%  dplyr::select(-c(article_id, poly_id, type, param, method_id))
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




# merge all ----------------------------------------------------------------
full <- shifts %>%
  left_join(articles) %>%
  left_join(author_reported) %>%
  left_join(taxo) %>%
  left_join(methods) %>%
  left_join(poly_info %>%   rename_at(.vars = vars(c(lat_min :area_km2)), .funs = ~paste0("sa_",.x))) %>%
  left_join(sp_poly_info %>%   rename_at(.vars = vars(c(lat_min :area_km2)), .funs = ~paste0("sp_",.x))) %>%
  left_join(baselines %>%   rename_with(~gsub("baseline","sa_baseline",.x))) %>%
  left_join(sp_baselines %>%   rename_with(~gsub("baseline","sp_baseline",.x))) %>%
  left_join(trends %>% rename_with(~gsub("trend","sa_trend",.x))) %>%
  left_join(sp_trends %>% rename_with(~gsub("trend","sp_trend",.x))) %>%
  left_join(cv %>% rename_with(~gsub("cv","sa_cv",.x))) %>%
  left_join(sp_cv %>% rename_with(~gsub("cv","sp_cv",.x))) %>% glimpse()

ncol(full) + length(c("study_poly","sp_poly","range_source"))

# tally up things to see if database org is saving us space ---------------------------------------------------------
full_dim <- dim(full)[1] * dim(full)[2]

dim_sep <- (dim(shifts)[1] * dim(shifts)[2] +
              dim(articles)[1] * dim(articles)[2] +
              dim(author_reported)[1] * dim(author_reported)[2] +
              dim(taxo)[1] * dim(taxo)[2] +
              dim(methods)[1] * dim(methods)[2] +
              dim(poly_info)[1] * dim(poly_info)[2] +
              dim(sp_poly_info)[1] * dim(sp_poly_info)[2] +
              dim(baselines)[1] * dim(baselines)[2] +
              dim(sp_baselines)[1] * dim(sp_baselines)[2] +
              dim(trends)[1] * dim(trends)[2] +
              dim(sp_trends)[1] * dim(sp_trends)[2] +
              dim(cv)[1] * dim(cv)[2] +
              dim(sp_cv)[1] * dim(sp_cv)[2]
)


dim_sep / full_dim * 100


# save each as .csv -------------------------------------------------------
out <- file.path("BioShiftR_tables_hardcopy")


# save shifts
readr::write_csv(shifts, file.path(out, "01-shifts.csv"))

# shift specificities
readr::write_csv(articles, file.path(out, "02-articles.csv"))
readr::write_csv(author_reported, file.path(out, "03-author_reported.csv"))
readr::write_csv(taxo, file.path(out, "04-taxo.csv"))
readr::write_csv(methods, file.path(out, "05-methods.csv"))

# derived exposure variables
readr::write_csv(baselines, file.path(out, "06-baselines.csv"))
readr::write_csv(sp_baselines, file.path(out, "07-sp_baselines.csv"))
readr::write_csv(trends, file.path(out, "08-trends.csv"))
readr::write_csv(sp_trends, file.path(out, "09-sp_trends.csv"))
readr::write_csv(cv, file.path(out, "10-cv.csv"))
readr::write_csv(sp_cv, file.path(out, "11-sp_cv.csv"))
readr::write_csv(poly_info, file.path(out, "12-poly_info.csv"))
readr::write_csv(sp_poly_info, file.path(out, "13-sp_poly_info.csv"))



