#' Download the CITES database to your local computer
#'
#' This command downloads the CITES shipments database and populates a local
#' database.  The download is large (~158 MB), and the database will be over
#' 1 GB on disk.  During import over 3.5 GB of disk space may be used temporarily.
#'
#' @param tag What release tag of data to download. Defaults to the most recent.
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
#' \donttest{
#' \dontrun{
#' cites_db_download()
#' }
#' }
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
  gunzip(zfile, destname = temp_tsv, overwrite = TRUE, remove = cleanup)

  tblname <- "cites_shipments"
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

  dbWriteTable(cites_db(), "cites_status", make_status_table(version = ver),
    overwrite = TRUE
  )

  load_citesdb_metadata()

  file.remove(temp_tsv)
  if (verbose) cites_status()
  update_cites_pane()
}

cites_field_types <- c(
  Year = "INTEGER",
  Appendix = "STRING",
  Taxon = "STRING",
  Class = "STRING",
  Order = "STRING",
  Family = "STRING",
  Genus = "STRING",
  Term = "STRING",
  Quantity = "DOUBLE PRECISION",
  Unit = "STRING",
  Importer = "STRING",
  Exporter = "STRING",
  Origin = "STRING",
  Purpose = "STRING",
  Source = "STRING",
  Reporter.type = "STRING",
  Import.permit.RandomID = "STRING",
  Export.permit.RandomID = "STRING",
  Origin.permit.RandomID = "STRING"
)

#' @importFrom DBI dbGetQuery
make_status_table <- function(version) {
  sz <- sum(file.info(list.files(cites_path(),
                                 all.files = TRUE,
                                 recursive = TRUE,
                                 full.names = TRUE))$size)
  class(sz) <- "object_size"
  data.frame(
    time_imported = Sys.time(),
    version = version,
    number_of_records = formatC(
      DBI::dbGetQuery(cites_db(),
                      "SELECT COUNT(*) FROM cites_shipments;")[[1]],
      format = "d", big.mark = ","),
    size_on_disk = format(sz, "auto")
  )
}

#' @importFrom httr GET stop_for_status content accept write_disk progress
#' @importFrom purrr keep
get_gh_release_file <- function(repo, tag_name = NULL, destdir = tempdir(),
                                overwrite = TRUE, verbose = interactive()) {
  releases <- GET(
    paste0("https://api.github.com/repos/", repo, "/releases")
  )
  stop_for_status(releases, "finding releases")

  releases <- content(releases)

  if (is.null(tag_name)) {
    release_obj <- releases[1]
  } else {
    release_obj <- purrr::keep(releases, function(x) x$tag_name == tag_name)
  }

  if (!length(release_obj)) stop("No release tagged \"", tag_name, "\"")

  if (release_obj[[1]]$prerelease) {
    message("This is pre-release/sample data! It has not been cleaned or validated.")  #nolint
  }

  download_url <- release_obj[[1]]$assets[[1]]$url
  filename <- basename(release_obj[[1]]$assets[[1]]$browser_download_url)
  out_path <- normalizePath(file.path(destdir, filename), mustWork = FALSE)
  response <- GET(
    download_url,
    accept("application/octet-stream"),
    write_disk(path = out_path, overwrite = overwrite),
    if (verbose) progress()
  )
  stop_for_status(response, "downloading data")

  attr(out_path, "ver") <- release_obj[[1]]$tag_name
  return(out_path)
}
