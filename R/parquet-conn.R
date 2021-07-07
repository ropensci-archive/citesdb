#' Creates an in-memory DuckDB representing parquet files as virtual tables
#'
#' @param path A parquet file, a directory of parquet files or a named vector of these
#' If a directory, it can contain subdirectories of parquet files.  Each parquet file or top-level
#' directory will be treated as a single table (actually, VIEW) in the database.
#'  Tables will be named after filenames and directories, dropping the
#' `extension` value if it exists
#' @param extension the extension of parquet files, including the leading `.`
#' @param verbose List the views created
#'
#' @return a 'duckdb_connection'
#' @importFrom duckdb duckdb
#' @importFrom DBI dbConnect dbSendQuery dbGetQuery
#' @importFrom glue glue_sql
#' @export
#'
duckdb_parquet_conn <- function(path, extension = ".parquet", verbose = FALSE) {

  if(!file.exists(path)) {
    stop("Parquet files or directory not found")
  }

  pattern <- paste0("\\", extension, "$")
  conn <- DBI::dbConnect(
    duckdb::duckdb(),
    read_only = FALSE)
  for(ppath in paths) {
    if(file.info(ppath)$isdir) {
      files <- list.files(ppath, pattern = pattern, full.names = TRUE, recursive = FALSE, include.dirs = FALSE)
      dirs <- list.dirs(ppath, full.names = TRUE, recursive = FALSE)
      for (f in files) {
        vname <- stri_replace_last_regex(basename(f), pattern, '')
        query <- glue::glue_sql("CREATE VIEW {vname} AS SELECT * FROM parquet_scan({f})", .con = conn)
        DBI::dbSendQuery(conn, query)
      }
      for (d in dirs) {
        vname <- basename(d)
        query <- glue::glue_sql("CREATE VIEW {vname} AS SELECT * FROM parquet_scan({paste0(d, '/*', extension)})", .con = conn)
        DBI::dbSendQuery(conn, query)
      }
    }
  }
  if(verbose) {
    cat("Tables in database:")
    print(DBI::dbGetQuery(conn, "SELECT name FROM sqlite_master WHERE type='table' OR type='view' ORDER BY name")[[1]])
  }
  return(conn)
}
