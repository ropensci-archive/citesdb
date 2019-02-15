#' @export
cites_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionOpened(
      type = "MonetDB",
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
