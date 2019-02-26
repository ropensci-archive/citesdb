#' Download the CITES database to your local computer
#'
#' This command downloads the CITES shipments database and populates a local
#' database.  The download is large (>80MB), and the database will be at least
#' twice that on disk.  During import over 1GB of disk space may be used.
#'
#' @param tag What release tag of data to download. Defaults to the most recent
#' @param destdir Where to download the compressed file.
#' @param cleanup Whether to delete the compressed file after loading into the database.
#' @param verbose Whether to display messages and download progress
#'
#' @return NULL
#' @export
#' @importFrom DBI dbRemoveTable dbExistsTable dbCreateTable dbExecute dbWriteTable
#' @importFrom R.utils gunzip
#'
#' @examples
#' cites_db_download()
cites_db_download <- function(tag = NULL, destdir = tempdir(),
                              cleanup = TRUE, verbose = interactive()) {
  if (verbose) message("Downloading data...\n")
  zfile <- get_gh_release_file("ecohealthalliance/citesdb",
    tag_name = tag,
    destdir = destdir, verbose = verbose
  )
  ver <- attr(zfile, "ver")
  if (verbose) message("Decompressing and building local database...\n")
  temp_tsv <- tempfile(fileext = ".tsv")
  R.utils::gunzip(zfile, destname = temp_tsv, overwrite = TRUE, remove = cleanup)

  tblname <- "shipments"
  if (dbExistsTable(cites_db(), tblname)) {
    dbRemoveTable(cites_db(), tblname)
  }


  dbCreateTable(cites_db(), tblname, fields = cites_field_types)

  suppressMessages(
    dbExecute(
      cites_db(),
      paste0(
        "COPY OFFSET 2 INTO ", tblname, " FROM '",
        temp_tsv,
        "' USING DELIMITERS '\t','\n','\"' NULL as 'NA'"
      )
    )
  )

  dbWriteTable(cites_db(), "status", make_status_table(version = ver),
    overwrite = TRUE
  )

  load_citesdb_metadata()

  file.remove(temp_tsv)
  if (verbose) cites_db_status()
  update_cites_pane()
}

cites_field_types <- c(
  id = "INTEGER", year = "INTEGER", appendix = "STRING", taxon = "STRING",
  taxon_id = "INTEGER", class = "STRING", order = "STRING", family = "STRING",
  genus = "STRING", reported_taxon = "STRING", reported_taxon_id = "INTEGER",
  term = "STRING", quantity = "DOUBLE PRECISION", unit = "STRING", importer = "STRING",
  exporter = "STRING", origin = "STRING", purpose = "STRING", source = "STRING",
  reporter_type = "STRING"
)

#' @importFrom DBI dbGetQuery
make_status_table <- function(version) {
  sz <- sum(file.info(list.files(cites_path(), all.files = TRUE, recursive = TRUE, full.names = TRUE))$size)
  class(sz) <- "object_size"
  data.frame(
    time_imported = Sys.time(),
    version = version,
    number_of_records = formatC(DBI::dbGetQuery(cites_db(), "SELECT COUNT(*) FROM shipments;")[[1]], format = "d", big.mark = ","),
    size_on_disk = format(sz, "auto")
  )
}

#' @import httr
#' @importFrom purrr keep
get_gh_release_file <- function(repo, tag_name = NULL, destdir = tempdir(),
                                overwrite = TRUE, verbose = interactive()) {
  releases <- GET(
    paste0("https://api.github.com/repos/", repo, "/releases"),
    add_headers("Authorization" = paste("token", Sys.getenv("GITHUB_PAT")))
  )
  httr::stop_for_status(releases, "finding releases")

  releases <- content(releases)

  if (is.null(tag_name)) {
    release_obj <- releases[1]
  } else {
    release_obj <- purrr::keep(releases, function(x) x$tag_name == tag_name)
  }

  if (!length(release_obj)) stop("No release tagged \"", release, "\"")

  if (release_obj[[1]]$prerelease) {
    message("This is pre-release data! It has not been validated.")
  }

  download_url <- release_obj[[1]]$assets[[1]]$url
  filename <- basename(release_obj[[1]]$assets[[1]]$browser_download_url)
  out_path <- normalizePath(file.path(destdir, filename), mustWork = FALSE)
  response <- GET(
    paste0(download_url, "?access_token=", Sys.getenv("GITHUB_PAT")),
    httr::accept("application/octet-stream"),
    write_disk(path = out_path, overwrite = overwrite),
    if (verbose) progress()
  )
  httr::stop_for_status(response, "downloading data")

  attr(out_path, "ver") <- release_obj[[1]]$tag_name
  return(out_path)
}
