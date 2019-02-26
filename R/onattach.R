.onAttach <- function(libname, pkgname) {
  MonetDBLite::monetdblite_shutdown()
  if (interactive() && Sys.getenv("RSTUDIO") == "1") {
    cites_pane()
  }
  if (interactive()) cites_db_status()
}

#' Remove the local CITES database
#'
#' Deletes all tables from the local database
#'
#' @return NULL
#' @export
#' @importFrom DBI dbListTables dbRemoveTable
#'
#' @examples
#' cites_db_delete()
cites_db_delete <- function() {
  for (t in dbListTables(cites_db())) {
    dbRemoveTable(cites_db(), t)
  }
  update_cites_pane()
}


#' Get the status of the current local CITES database
#'
#' @param verbose Whether to print a status message
#'
#' @return TRUE if the database exists, FALSE if it is not detected. (invisible)
#' @export
#' @importFrom DBI dbExistsTable
#' @importFrom tools toTitleCase
#' @examples
#' cites_db_status()
cites_db_status <- function(verbose = TRUE) {
  if (dbExistsTable(cites_db(), "shipments") &&
    dbExistsTable(cites_db(), "status")) {
    status <- DBI::dbReadTable(cites_db(), "status")
    status_msg <-
      paste0(
        "CITES database status:\n",
        paste0(toTitleCase(gsub("_", " ", names(status))),
          ": ", as.matrix(status),
          collapse = "\n"
        )
      )
    out <- TRUE
  } else {
    status_msg <- "Local CITES database empty or corrupt. Download with cites_db_download()"
    out <- FALSE
  }
  if (verbose) message(status_msg)
  invisible(out)
}


load_citesdb_metadata <- function() {
  tsvs <- list.files(system.file("extdata", package = "citesdb"),
                     pattern = "\\.tsv$", full.names = TRUE)
  tblnames <- tools::file_path_sans_ext(basename(tsvs))
  for (i in seq_along(tsvs)) {
    suppressMessages(dbWriteTable(cites_db(), tblnames[i],
                 read.table(tsvs[i], stringsAsFactors = FALSE, sep = "\t",
                            header = TRUE,  quote = "\""),
                 overwrite = TRUE))
  }
}
