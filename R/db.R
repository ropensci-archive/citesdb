#' @importFrom fs dir_info
cites_db_size <- function(db = cites_db()) {
  sum(fs::dir_info(cites_path(), recursive = TRUE)$size)
}

cites_db_export <- function(db) {

}

cites_db_import <- function(db)  {

}

cites_db_status <- function(db) {

}
