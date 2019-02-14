#' @importFrom rappdirs user_data_dir
cites_path <- function() {
  sys_cites_path <- Sys.getenv("CITES_DB_HOME")
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

#' @export
cites_disconnect <- function(env=cites_cache, shutdown = TRUE){
  db <- mget("cites_db", envir = env, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection"))
    DBI::dbDisconnect(db, shutdown)
  observer <- getOption("connectionObserver")
  if (!is.null(observer))
    observer$connectionClosed("MonetDB", "citesdb")
}

cites_cache <- new.env()
reg.finalizer(cites_cache, cites_disconnect, onexit = TRUE)


#' @export
cites_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionOpened(type = "MonetDB",
                              host = "citesdb",
                              displayName = "CITES",
                              icon = system.file("img","eha_logo.png", package = "citesdb"),
                              connectCode = "citesdb::cites_pane()",
                              disconnect = citesdb::cites_disconnect,
                              listObjectTypes = function() {
                                list(
                                  table = list(contains = "data")                                )
                              },
                              listObjects = function(type = "datasets") {
                                tbls <- DBI::dbListTables(cites_connect())
                                data.frame(
                                  name = tbls,
                                  type = rep("table", length(tbls)),
                                  stringsAsFactors = FALSE
                                )
                              },
                              listColumns = function(table) {
                                res = DBI::dbSendQuery(cites_connect(), paste("SELECT * FROM", table, "LIMIT 1"))
                                on.exit(DBI::dbClearResult(res))
                                data.frame(name = res@env$info$names, type = res@env$info$types,
                                           stringsAsFactors = FALSE)
                              },
                              previewObject = function(rowLimit, table) {
                                DBI::dbGetQuery(cites_connect(), paste("SELECT * FROM", table, "LIMIT", rowLimit))
                              },
                              actions = list(
                                boom = list(
                                  icon = system.file("img","eha_logo.png", package = "citesdb"),
                                  callback = function() cat("BOOM!")
                                )
                              ),
                              connectionObject = cites_connect())
  }
}

.onAttach <- function(libname, pkgname) {
  if (interactive()) {
    cites_pane()
  }
}

