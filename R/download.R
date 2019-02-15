#' Title
#'
#' @param codes
#' @param db
#' @param new_only
#' @param verbose
#' @param temp_dir
#' @param cleanup
#'
#' @return NULL
#'
#' @importFrom httr GET write_disk
#'
#' @examples
cites_db_download <- function(version = "latest",  dir = tempdir(),
                              delete = TRUE, verbose = interactive()) {

  url <- citesdb_url(version)
  cites_filename <- basename(url)
  cites_file_path <- file.path(dir, cites_filename)

  if (verbose) message("Downloading compressed data...\n")
  response <- httr::GET(url, write_disk(cite_file_path), if (verbose) progress())
  stop_for_status(response, "download CITES data")

  if (verbose) message("Building local database...\n")
  DBI::dbRemoveTable(cites_db(), "transactions")
  monet.read.csv(cites_db(), cites_file_path, header = TRUE, locked = TRUE)
  status_table <- make_status_table(response, version, cites_db())
  DBI::dbWriteTable(cites_db(), "status", status_table())

  return(cites_db())
}

citesdb_url <- function(version) {

}


make_status_table <- function(response, version, db = cites_db()) {
 data.frame(
   time_downloaded = response$time,
   url_downloaded = response$url,
   version = version,
   records = DBI::dbGetQuery(db, "SELECT COUNT(*) FROM records;")
   size = sum(fs::dir_info(cites_path(), recursive = TRUE)$size)
   }

 )
}
