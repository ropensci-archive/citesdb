

library(httr)
library(here)
library(readr)
library(fs)
library(purrr)
library(dplyr)

GET(
  "https://trade.cites.org/cites_trade/download_db",
  write_disk(here("data-raw", "Trade_database.zip"), overwrite = TRUE)
)

unzip(here("data-raw", "Trade_database.zip"),
  overwrite = TRUE,
  exdir = here("data-raw"),
)

tdb <- map_dfr(
  list.files(here("data-raw"), pattern = "^trade_db_\\d+\\.csv$", full.names = TRUE),
  ~ read_csv(.,
    col_types = cols(
      Id = col_character(),
      Year = col_integer(),
      Appendix = col_character(),
      Taxon = col_character(),
      Class = col_character(),
      Order = col_character(),
      Family = col_character(),
      Genus = col_character(),
      Term = col_character(),
      Quantity = col_double(),
      Unit = col_character(),
      Importer = col_character(),
      Exporter = col_character(),
      Origin = col_character(),
      Purpose = col_character(),
      Source = col_character(),
      Reporter.type = col_character(),
      Import.permit.RandomID = col_character(),
      Export.permit.RandomID = col_character(),
      Origin.permit.RandomID = col_character()
    )
  )
)

# Removing invalid records to be fixed if possible in the future
tdb <- tdb %>%
  filter(!is.na(Year) & Year > 1970 & Year < 2021)

# Arrange values; improves compressibility
tdb <- tdb %>%
  arrange(Year, Taxon, Order, Family, Genus, Term, Importer, Exporter, Appendix)

# Write compressed data
write_tsv(
  tdb,
  here("data-raw", "cites_trade_db.tsv.bz2")
)

# Clean up
file_delete(
  list.files(here("data-raw"), pattern = "(zip|csv|docx)$", full.names = TRUE)
)

# Release the compressed data
datastorr::github_release_info(
  "ropensci/citesdb",
  read = read_tsv,
  filename = "cites_trade_db.tsv.bz2"
) %>%
datastorr::github_release_create(
  description = "Release of CITES shipment data (v2020.1)",
  target = "master", ignore_dirty = TRUE
)
