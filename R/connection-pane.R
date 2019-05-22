sql_action <- function() {
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
    exists("documentNew", asNamespace("rstudioapi"))) {
    contents <- paste(
      "-- !preview conn=citesdb::cites_db()",
      "",
      "SELECT * FROM cites_shipments LIMIT 100",
      "",
      sep = "\n"
    )

    rstudioapi::documentNew(
      text = contents, type = "sql",
      position = rstudioapi::document_position(2, 40),
      execute = FALSE
    )
  }
}

#' Open CITES database connection pane in RStudio
#'
#' This function launches the RStudio "Connection" pane to interactively
#' explore the database.
#'
#' @return NULL
#' @export
#'
#' @examples
#' if (!is.null(getOption("connectionObserver"))) cites_pane()
cites_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer) && interactive()) {
    observer$connectionOpened(
      type = "CITESDB",
      host = "citesdb",
      displayName = "CITES Transaction Tables",
      icon = system.file("img", "eha_logo.png", package = "citesdb"),
      connectCode = "citesdb::cites_pane()",
      disconnect = citesdb::cites_disconnect,
      listObjectTypes = function() {
        list(
          table = list(contains = "data")
        )
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
        res <- DBI::dbSendQuery(cites_db(),
                                paste("SELECT * FROM", table, "LIMIT 1"))
        on.exit(DBI::dbClearResult(res))
        data.frame(
          name = res@env$info$names, type = res@env$info$types,
          stringsAsFactors = FALSE
        )
      },
      previewObject = function(rowLimit, table) {  #nolint
        DBI::dbGetQuery(cites_db(),
                        paste("SELECT * FROM", table, "LIMIT", rowLimit))
      },
      actions = list(
        Status = list(
          icon = system.file("img", "cites-logo.png", package = "citesdb"),
          callback = cites_status
        ),
        SQL = list(
          icon = system.file("img", "edit-sql.png", package = "citesdb"),
          callback = sql_action
        )
      ),
      connectionObject = cites_db()
    )
  }
}

update_cites_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionUpdated("CITESDB", "citesdb", "")
  }
}
