#' @importFrom rappdirs user_data_dir
cites_path <- function() {
  sys_cites_path <- Sys.getenv("CITES_DB_DIR")
  if (sys_cites_path == "") {
    rappdirs::user_data_dir("citesdb")
  }
}

#' @export
cites_connect <- function(dbdir = cites_path()){
  db <- mget("cites_db", envir = cites_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    if (DBI::dbIsValid(db)) {
      return(db)
    }
  }
  dbname <- dbdir
  dir.create(dbname, FALSE)
  db <- DBI::dbConnect(MonetDBLite::MonetDBLite(), dbname = dbname)
  assign("cites_db", db, envir = cites_cache)
  db
}

cites_db <- cites_connect
cites_trans <- function() {
  if (!require(dplyr))
    stop("Install the dplyr package to use convenience functions like cites_trans()")
  dplyr::tbl(cites_connect(), "transactions")
}

#' @export
cites_disconnect <- function(env=cites_cache, shutdown = TRUE){
  db <- mget("cites_db", envir = env, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection"))
    DBI::dbDisconnect(db, shutdown)
  observer <- getOption("connectionObserver")
  if (!is.null(observer))
    observer$connectionClosed("MonetDB", "citesdb")
}

cites_clean <- function(db = db_connect()){
  tables <- DBI::dbListTables(db)
  drop <- tables[ !grepl("_", tables) ]
  lapply(drop, function(x) DBI::dbRemoveTable(db, x))
  invisible(TRUE)
}

cites_cache <- new.env()
reg.finalizer(cites_cache, cites_disconnect, onexit = TRUE)


.onAttach <- function(libname, pkgname) {
  if (interactive() && Sys.getenv("RSTUDIO") == "1") {
    cites_pane()
  }
}

