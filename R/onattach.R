in_chk <- function() {
  any(
    grepl("check",
          sapply(sys.calls(), function(a) paste(deparse(a), collapse = "\n"))
    )
  )
}

.onAttach <- function(libname, pkgname) {  #nolint
  MonetDBLite::monetdblite_shutdown()
  if (interactive() && Sys.getenv("RSTUDIO") == "1"  && !in_chk()) {
    cites_pane()
  }
  if (interactive()) cites_status()
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
#' \donttest{
#' \dontrun{
#' cites_db_delete()
#' }
#' }
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
#' cites_status()
cites_status <- function(verbose = TRUE) {
  if (dbExistsTable(cites_db(), "cites_shipments") &&
      dbExistsTable(cites_db(), "cites_status")) {
    status <- DBI::dbReadTable(cites_db(), "cites_status")
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
    status_msg <- "Local CITES database empty or corrupt. Download with cites_db_download()" #nolint
    out <- FALSE
  }
  if (verbose) message(status_msg)
  invisible(out)
}
