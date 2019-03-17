context("Download")

olddir <- Sys.getenv("CITES_DB_DIR")
Sys.setenv(CITES_DB_DIR = normalizePath(file.path(getwd(), "localdb"),
  mustWork = FALSE
))

test_that("Download succeeds", {
  skip_on_cran()
  cites_db_download()
  expect_true(cites_status())
})

Sys.setenv(CITES_DB_DIR = olddir)
