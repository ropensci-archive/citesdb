#' @importFrom rappdirs user_data_dir
cites_path <- function() {
  sys_cites_path <- Sys.getenv("CITES_DB_DIR")
  if (sys_cites_path == "") {
    return(rappdirs::user_data_dir("citesdb"))
  } else {
    return(sys_cites_path)
  }
}

cites_check_status <- function() {
  if (!cites_status(FALSE)) {
    stop("Local CITES database empty or corrupt. Download with cites_db_download()") # nolint
  }
}

#' The local CITES database
#'
#' Returns a connection to the local CITES database. This is a DBI-compliant
#' [duckdb::duckdb()] database connection. When using **dplyr**-based
#' workflows, one typically accesses tables with functions such as
#' [cites_shipments()], but this function lets one interact with the database
#' directly via SQL.
#'
#' @param dbdir The location of the database on disk. Defaults to
#' `citesdb` under [rappdirs::user_data_dir()], or the environment variable `CITES_DB_DIR`.
#'
#' @return A DuckDB DBI connection
#' @importFrom DBI dbIsValid dbConnect
#' @importFrom duckdb duckdb
#' @export
#'
#' @examples
#' if (cites_status()) {
#'   library(DBI)
#'
#'   dbListTables(cites_db())
#'
#'   parties <- dbReadTable(cites_db(), "cites_parties")
#'
#'   dbGetQuery(
#'    cites_db(),
#'    'SELECT "Taxon", "Importer" FROM cites_shipments WHERE "Year" = 1976 LIMIT 100;'
#'    )
#' }
cites_db <- function(dbdir = cites_path(), read_only = TRUE) {
  db <- mget("cites_db", envir = citesdb:::cites_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    if (DBI::dbIsValid(db) && (!read_only && !dbIsReadOnly(db))) {
      return(db)
    }
  }
  dbname <- file.path(dbdir, "citesdb")
  dir.create(dbdir, FALSE, recursive = TRUE)

  # tryCatch({
      db <- DBI::dbConnect(duckdb::duckdb(dbdir=dbname), debug = FALSE, read_only = read_only)
#
  #   error = function(e) {
  #     if (grepl("(Database lock|bad rolemask)", e)) {
  #       stop(paste(
  #         "Local citesdb database is locked by another R session.\n",
  #         "Try closing or running cites_disconnect() in that session."
  #       ),
  #       call. = FALSE
  #       )
  #     } else {
  #       stop(e)
  #     }
  #   },
  #   finally = NULL
  # )

  assign("cites_db", db, envir = cites_cache)
  db
}


#' CITES shipment data
#'
#' Returns a remote database table with all CITES shipment data.  This is the
#' bulk of the data in the package and constitutes > 20 million records.  Loading
#' the whole table into R via the [dplyr::collect()] command will use over
#' 3 GB of RAM, so you may want to pre-process data in the database, as in
#' the examples below.
#'
#' @return A **dplyr** remote tibble ([dplyr::tbl()])
#' @export
#'
#' @examples
#' if (cites_status()) {
#'   library(dplyr)
#'
#'   # See the number of CITES shipment records per year
#'   cites_shipments() %>%
#'     group_by(Year) %>%
#'     summarize(n_records = n()) %>%
#'     arrange(desc(Year)) %>%
#'     collect()
#'
#'   # See what pangolin shipments went to which countries in 1990
#'    cites_shipments() %>%
#'      filter(Order == "Pholidota", Year == 1990) %>%
#'      count(Year, Importer, Term) %>%
#'      collect() %>%
#'      left_join(select(cites_parties(), country, code),
#'                by = c("Importer" = "code"))
#'
#' }
#' @importFrom dplyr tbl
cites_shipments <- function() {
  cites_check_status()
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
#'   library(dplyr)
#'
#'   # See the field definitions for cites_shipments()
#'   cites_metadata()
#'
#'   # See the codes used for shipment purpose
#'   cites_codes() %>%
#'    filter(field == "Purpose")
#'
#'   # See the most recent countries to join CITES
#'   cites_parties() %>%
#'     arrange(desc(date)) %>%
#'     head(10)
#'
#'   # See countries or locations with non-standaard or outdated ISO codes
#'   cites_parties() %>%
#'     filter(former_code | non_ISO_code)
#'
#'   # For remote connections to these tables, access the database directly:
#'   dplyr::tbl(cites_db(), "cites_metadata")
#'   dplyr::tbl(cites_db(), "cites_codes")
#'   dplyr::tbl(cites_db(), "cites_parties")
#' }
cites_metadata <- function() {
  cites_check_status()
  as_tibble(dbReadTable(cites_db(), "cites_metadata"))
}

#' @export
#' @rdname cites_metadata
cites_codes <- function() {
  cites_check_status()
  as_tibble(dbReadTable(cites_db(), "cites_codes"))
}

#' @export
#' @rdname cites_metadata
cites_parties <- function() {
  cites_check_status()
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
    DBI::dbDisconnect(db, shutdown = TRUE)
  }
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionClosed("CITESDB", "citesdb")
  }
}

cites_cache <- new.env()
reg.finalizer(cites_cache, cites_disconnect_, onexit = TRUE)
