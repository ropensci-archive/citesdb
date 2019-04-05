#' @importFrom rappdirs user_data_dir
cites_path <- function() {
  sys_cites_path <- Sys.getenv("CITES_DB_DIR")
  if (sys_cites_path == "") {
    return(rappdirs::user_data_dir("citesdb"))
  } else {
    return(sys_cites_path)
  }
}

check_status <- function() {
  if (!cites_status(FALSE)) {
    stop("Local CITES database empty or corrupt. Download with cites_db_download()") # nolint
  }
}

#' The local CITES database
#'
#' Returns a connection to the local CITES database. This is a DBI-compliant
#' [MonetDBLite::MonetDBLite()] database connection.
#'
#' @param dbdir The location of the database on disk. Defaults to
#' `citesdb` under [rappdirs::user_data_dir()], or the environment variable `CITES_DB_DIR`.
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

  tryCatch(
    db <- DBI::dbConnect(MonetDBLite::MonetDBLite(), dbname = dbdir),
    error = function(e) {
      if (grepl("Database lock", e)) {
        stop(paste(
          "Local citesdb database is locked by another R session.\n",
          "Try closing or running cites_disconect() in that session."
        ),
        call. = FALSE
        )
      } else {
        stop(e)
      }
    },
    finally = NULL
  )

  assign("cites_db", db, envir = cites_cache)
  db
}


#' CITES shipment data
#'
#' Returns a remote table with all CITES shipment data. Requires the dplyr and dbplyr packages.
#' @return A dplyr remote tibble ([dplyr::tbl()])
#' @export
#'
#' @examples
#' if (cites_status()) {
#'   cites_shipments()
#' }
#' @importFrom dplyr tbl
cites_shipments <- function() {
  check_status()
  tbl(cites_db(), "cites_shipments")
}

#' CITES shipment metadata
#'
#' @description
#'
#' The CITES database also includes tables of column-level metadata and
#' meanings of codes in columns, as well as a listing of CITES Parties/country abbreviations.
#' Convenience functions access these tables. As they are small, the functions
#' collect the tables into R session memory, rather than returning a remote table.
#'
#' This information is drawn from
#' ["A guide to using the CITES Trade Database"](https://trade.cites.org/cites_trade_guidelines/en-CITES_Trade_Database_Guide.pdf),
#' from the CITES website. More information on the shipment-level data can be
#' found in the [guidance] help file.
#'
#' @return A tibble of metadata
#' @export
#'
#' @importFrom DBI dbReadTable
#' @importFrom dplyr as_tibble
#' @aliases metadata cites_metadata
#' @examples
#' if (cites_status()) {
#'   cites_metadata()
#'   cites_codes()
#'   cites_parties()
#'
#'   # For remote connections to these tables,
#'   # access the database directly:
#'   dplyr::tbl(cites_db(), "cites_metadata")
#'   dplyr::tbl(cites_db(), "cites_codes")
#'   dplyr::tbl(cites_db(), "cites_parties")
#' }
cites_metadata <- function() {
  check_status
  as_tibble(dbReadTable(cites_db(), "cites_metadata"))
}

#' @export
#' @rdname cites_metadata
cites_codes <- function() {
  check_status()
  as_tibble(dbReadTable(cites_db(), "cites_codes"))
}

#' @export
#' @rdname cites_metadata
cites_parties <- function() {
  check_status()
  as_tibble(dbReadTable(cites_db(), "cites_parties"))
}

#' Disconnect from the CITES database
#'
#' A utility function for disconnecting from the database.
#'
#' @examples
#' cites_disconnect()
#' @export
#'
cites_disconnect <- function() {
  cites_disconnect_()
}
cites_disconnect_ <- function(environment = cites_cache) { # nolint
  db <- mget("cites_db", envir = cites_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    MonetDBLite::monetdblite_shutdown()
  }
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionClosed("CITESDB", "citesdb")
  }
}

cites_cache <- new.env()
reg.finalizer(cites_cache, cites_disconnect_, onexit = TRUE)
