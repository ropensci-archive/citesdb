# CITES Code Values
#
# This function returns a data frame with descriptions of all the code values
# used in [cites_data()].  This is useful for lookup
# as well as merging with the data for more descriptive summaries.
#
# These values are drawn from
# ["A guide to using the CITES Trade Database"](https://github.com/ecohealthalliance/cites/tree/master/inst/extdata),
# from the CITES website.
#
# \if{html}{
#   \Sexpr[echo=FALSE, results=rd, stage=build]{
#     if(citesdb:::is_js_ok()) {
#       mytext <- citesdb:::rd_datatable(citesdb::cites_codes())
#     } else {
#       mytext <- c('In RStudio help, this help file includes a searchable table of values if you install the DT package')
#     }
#     mytext
#   }
# }
#
# #' \if{text,latex}{The HTML version of this help file includes a searchable table of the CITES codes.}
# #'
# #' @return A tibble with fields and descriptions
# #' @seealso [cites_metadata()] [cites_data()]
# #' @export
# cites_codes <- function() {
#   cites_codes_
# }

# CITES Field Descriptions
#
# This function returns a data frame field descriptions for [cites_data()].
#
# This information is taken from
# ["A guide to using the CITES Trade Database"](https://github.com/ecohealthalliance/cites/tree/master/inst/extdata),
# from the CITES websites.
#
# \if{html}{
#   \Sexpr[echo=FALSE, results=rd, stage=build]{
#     if (citesdb:::is_js_ok()) {
#       mytext <- citesdb:::rd_datatable(citesdb::cites_metadata())
#     } else {
#       mytext <- citesdb:::tabular(citesdb::cites_metadata())
#     }
#     mytext
#   }
# }
#
# #' \if{text,latex}{ \Sexpr[echo=FALSE, results=rd, stage=build]{citesdb:::tabular(citesdb::cites_metadata())}}
# #'
# #' @return A tibble with field, code, and code description
# #' @aliases metadata
# #' @seealso [cites_codes()] [cites_data()] [cites_parties()]
# #' @export
# # cites_metadata <- function() {
# #   cites_metadata_
# # }
#
#

# Parties to the CITES treaty.
#
# This function returns a data frame witha list of countries party to CITES
# and their date of joining the treaty.
#
# \if{html}{
#   \Sexpr[echo=FALSE, results=rd, stage=build]{
#     if (citesdb:::is_js_ok()) {
#       mytext <- citesdb:::rd_datatable(citesdb::cites_parties())
#     } else {
#       mytext <- citesdb:::tabular(citesdb::cites_parties())
#     }
#     mytext
#   }
# }
#
# \if{text,latex}{ \Sexpr[echo=FALSE, results=rd, stage=build]{citesdb:::tabular(citesdb::cites_metadata())}}
#
# @return A tibble
# @aliases parties
# @seealso [cites_codes()] [cites_metadata()]
# @export
# cites_parties <- function() {
#   cites_parties_
# }
