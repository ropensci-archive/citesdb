

library(dplyr)
library(readr)
library(stringr)

h <- here::here

# ==============================================================================


# Import CITES data sample

cites.test <- read_csv("data-raw/cites_test_sample.csv")

# Clean column names

colnames(cites.test) <- colnames(cites.test) %>%
  tolower() %>%
  str_replace_all(., " ", "_")

# Write compressed data to local disk

write_tsv(
  cites.test,
  h("data-raw", "cites_test_data.tsv.gz")
)

# Release the compressed data

# datastorr::github_release_info(
#   "ecohealthalliance/citesdb",
#   read = read_tsv,
#   filename = h("data-raw", "cites_test_data.tsv.gz")
# ) %>%
# datastorr::github_release_create(
#   description = "Release of CITES sample data (v0.0.0.9001)",
#   target = "master", ignore_dirty = FALSE
# )
