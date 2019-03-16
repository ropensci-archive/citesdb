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
#' @importFrom dplyr tbl
cites_shipments <- function() {
  if (!cites_status(FALSE)) {
    stop("Local CITES database empty or corrupt. Download with cites_db_download()")
  }
  tbl(cites_db(), "cites_shipments")
}

#' Cites shipment metadata
#'
#' @description
#'
#' The CITES database also includes tables of column-levelel metadata and
#' meanings of codes in colums, as well as a listing of CITES parties.
#' convenience functions acccess these tables. As they are small, the functions
#' collect the into R session memory, rather than returning a remote table.
#'
#' This information is drawn from
#' ["A guide to using the CITES Trade Database"](https://trade.cites.org/cites_trade_guidelines/en-CITES_Trade_Database_Guide.pdf),
#' from the CITES website. More information the the shipment-level data can be
#' found in the [guidance] help file.
#'
#' @return A tibble of metadata
#' @export
#'
#' @importFrom DBI dbReadTable
#' @importFrom dplyr as_tibble
#' @aliases metadata cites_metadata
#' @examples
#' cites_metadata()
#' cites_codes()
#' cites_shipments()
#' 
#' # For remote connections to these tables,
#' # access the database directly:
#' dplyr::tbl(cites_db(), "cites_metadata")
#' dplyr::tbl(cites_db(), "cites_codes")
#' dplyr::tbl(cites_db(), "cites_parties")
cites_metadata <- function() {
  if (!cites_status(FALSE)) {
    stop("Local CITES database empty or corrupt. Download with cites_db_download()")
  }
  as_tibble(dbReadTable(cites_db(), "cites_metadata"))
}

#' @export
#' @rdname cites_metadata
cites_codes <- function() {
  if (!cites_status(FALSE)) {
    stop("Local CITES database empty or corrupt. Download with cites_db_download()")
  }
  as_tibble(dbReadTable(cites_db(), "cites_codes"))
}

#' @export
#' @rdname cites_metadata
cites_parties <- function() {
  if (!cites_status(FALSE)) {
    stop("Local CITES database empty or corrupt. Download with cites_db_download()")
  }
  as_tibble(dbReadTable(cites_db(), "cites_metadata"))
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
