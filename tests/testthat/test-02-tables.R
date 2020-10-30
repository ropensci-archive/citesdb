olddir <- Sys.getenv("CITES_DB_DIR")
Sys.setenv(CITES_DB_DIR = normalizePath(file.path(getwd(), "localdb"),
  mustWork = FALSE
))

context("Tables")

test_that("Tables have expected types", {
  skip_on_cran()
  skip_if_not(cites_status())
  expect_is(cites_shipments(), "tbl_duckdb_connection")
  expect_is(cites_metadata(), "data.frame")
  expect_is(cites_codes(), "data.frame")
  expect_is(cites_parties(), "data.frame")
})

test_that("All codes are accounted for", {
  skip_on_cran()
  skip_if_not(cites_status())
  suppressWarnings(suppressPackageStartupMessages(library(dplyr)))

  sources <- cites_shipments() %>%
    count(Source) %>%
    pull(Source) %>%
    na.omit()
  source_codes <- cites_codes() %>%
    filter(field == "Source") %>%
    pull(code)
  expect_setequal(sources, source_codes)

  purposes <- cites_shipments() %>%
    count(Purpose) %>%
    pull(Purpose) %>%
    na.omit()
  purpose_codes <- cites_codes() %>%
    filter(field == "Purpose") %>%
    pull(code)
  expect_setequal(purposes, purpose_codes)
})

Sys.setenv(CITES_DB_DIR = olddir)
