#' Download spatial data from OSF
#'
#' BioShiftR relies on data from multiple sources. Spatial polygon datasets of all study areas, or species ranges within study areas are available on [Open Science Framework]{https://osf.io/tp4hv/files/osfstorage}, but need to be downloaded locally in order to use provided helper functions. This function only needs to be run once
#'
#' @param type choice of study area ("SA") polygons, or species range polygons clipped to individual study areas ("SP"). Species range polygons will be more resolute in large study areas, but will take longer to download and use more disc space.
#' @param directory directory within the project folder for polygon storage.
#' @param timeout timeout option if download fails. Increasing timeout may result in more stable downloads.
#'
#'
#' @returns data folder for polygon storage
#' @export
#'
#' @examples \dontrun{download_polyons(type = "SA")}
download_polygons <- function(type = "SA",
                              directory = ".",
                              timeout = 500,
                              replace = F){

  # get filename for species or study polygons
  filename <- switch(type,
                     "SA" = "sa_polygons_simplified.rds",
                     "SP" = "sp_polygons_simplified.rds")

  size <- switch(type,
                 "SA" = 4,
                 "SP" = 435)

  # search for file in project directory
  # list all project files
  all_proj_files <-
    list.files(recursive = T,
               include.dirs = F,
               full.names = F)

  # check if filename already exists
  exists <- any(stringr::str_detect(all_proj_files, filename))

  # if file exists somewhere in directory, ask user if they want to continue
  if(exists){

    existing <- all_proj_files[which(stringr::str_detect(all_proj_files, filename))]

    cat("File seems to already exist at:\n", existing,"\n")
    response <- readline("Continue download? [Y or N]: ")

    if(response != "Y"){
      stop("Invalid answer. Download aborted by user.")
    }

  }


  # Prompt user for disc space
  cat("Downloading polygons will take ", size, "MB of disc space.\nContinue?\n")
  response2 <- readline("Choose an option [Y or N]: ")

  if(response2 != "Y"){
    stop("invalid answer. Download aborted by user.")
  }

  # find download link
  link <- switch(type,
                 "SA" = "https://osf.io/download/68b747593d97f9fb8567b34f/",
                 "SP" = "https://osf.io/download/68b7469215dee6d2f490637d/"
  )

  # create directory if it doesn't exist
  dir <- file.path(directory, "BioShiftR_polygons")
  dir.create(dir, recursive = T, showWarnings = F)

  # increase timeout
  if(type == "SP"){
    # Store original timeout
    original_timeout <- getOption("timeout")
    # increase timeout
    options(timeout=timeout)
    # restore original timeout on exit
    on.exit(options(timeout = original_timeout))

  }

  # download file
  download.file(link,
                destfile = file.path(dir, filename))

  cat("Downloaded to ",  file.path(dir, filename))

}
