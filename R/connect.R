#' @importFrom rappdirs user_data_dir
cites_path <- function() {
  sys_cites_path <- Sys.getenv("CITES_DB_DIR")
  if (sys_cites_path == "") {
    rappdirs::user_data_dir("citesdb")
  }
}


#' The local CITES database
#'
#' Returns a connecction to the local CITES database.  This is a DBI-complient
#' [MonetDBLite::MonetDBLite]() database.
#'
#' @param dbdir The location of the database on disk.  Defaults to
#' `citesdb` under [MonetDBLite::MonetDBLite], or `getOption("CITES_DB_DIR")`.
#'
#' @return A MonetDBLite DBI connection
#' @importFrom DBI dbIsValid dbConnect
#' @importFrom MonetDBLite MonetDBLite
#' @export
#'
#' @examples
#' cites_db()
cites_db <- function(dbdir = cites_path()) {
  db <- mget("cites_db", envir = cites_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    if (DBI::dbIsValid(db)) {
      return(db)
    }
  }
  dbname <- dbdir
  dir.create(dbname, FALSE)
  db <- DBI::dbConnect(MonetDBLite::MonetDBLite(), dbname = dbdir)
  assign("cites_db", db, envir = cites_cache)
  db
}


#' CITES Shipment Data
#'
#' Returns a remote table with all CITES shipment data. Requires the dplyr and dbplyr packages.
#' @return A dplyr remote tibble ([dplyr::tbl()])
#' @export
#'
#' @examples
#' cites_shipments()
cites_shipments <- function() {
  if (!cites_db_status(FALSE)) {
    stop("Local CITES database empty or corrupt. Download with cites_db_download()")
  }
  if (!suppressWarnings(suppressPackageStartupMessages(require(dplyr)))) {
    stop("Install the dplyr package to use convenience functions like cites_trans()")
  }
  dplyr::tbl(cites_db(), "shipments")
}

#' Discconnect from the CITES database
#'
#' A utility function for disconnecting from the database.
#'
#' @examples
#' cites_disconnecct()
#' @export
cites_disconnect <- function(env = cites_cache, shutdown = TRUE) {
  db <- mget("cites_db", envir = env, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    MonetDBLite::monetdblite_shutdown()
  }
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionClosed("CITESDB", "citesdb")
  }
}

cites_clean <- function(db = db_connect()) {
  tables <- DBI::dbListTables(db)
  drop <- tables[ !grepl("_", tables) ]
  lapply(drop, function(x) DBI::dbRemoveTable(db, x))
  invisible(TRUE)
}

cites_cache <- new.env()
reg.finalizer(cites_cache, cites_disconnect, onexit = TRUE)
