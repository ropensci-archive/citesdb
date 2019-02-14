#' Title
#'
#' @param codes
#' @param db
#' @param new_only
#' @param verbose
#' @param temp_dir
#' @param cleanup
#'
#' @return
#' @export
#'
#' @examples
cites_db_download <- function(codes = NULL, db = cites_db(), new_only = TRUE, verbose=TRUE,
                            temp_dir = tempdir(), cleanup=TRUEs) {



}

# Look at https://github.com/cboettig/taxadb/blob/master/R/td_create.R for this,
# But use the MonetDB import functions (monetdb.read.csv) for speed.
#
