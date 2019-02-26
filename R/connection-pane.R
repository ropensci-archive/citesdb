#' @export
cites_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionOpened(
      type = "CITESDB",
      host = "citesdb",
      displayName = "CITES Transaction Tables",
      icon = system.file("img","eha_logo.png", package = "citesdb"),
      connectCode = "citesdb::cites_pane()",
      disconnect = citesdb::cites_disconnect,
      listObjectTypes = function() {
        list(
          table = list(contains = "data")                                )
      },
      listObjects = function(type = "datasets") {
        tbls <- DBI::dbListTables(cites_db())
        data.frame(
          name = tbls,
          type = rep("table", length(tbls)),
          stringsAsFactors = FALSE
        )
      },
      listColumns = function(table) {
        res = DBI::dbSendQuery(cites_db(), paste("SELECT * FROM", table, "LIMIT 1"))
        on.exit(DBI::dbClearResult(res))
        data.frame(name = res@env$info$names, type = res@env$info$types,
                   stringsAsFactors = FALSE)
      },
      previewObject = function(rowLimit, table) {
        DBI::dbGetQuery(cites_db(), paste("SELECT * FROM", table, "LIMIT", rowLimit))
      },
      actions = list(
        status = list(
          icon = system.file("img", "cites-logo.png", package = "citesdb"),
          callback = cites_db_status
        )
      ),
      connectionObject = cites_db())
  }
}

update_cites_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer))
    observer$connectionUpdated("CITESDB","citesdb", "")
}

