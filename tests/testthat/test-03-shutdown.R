olddir <- Sys.getenv("CITES_DB_DIR")
Sys.setenv(CITES_DB_DIR = normalizePath(file.path(getwd(), "localdb"),
  mustWork = FALSE
))


context("Shutdown")

test_that("Disconnetion works", {
  skip_on_cran()
  skip_if_not(cites_status())

  cites_disconnect()
  expect_error({
    success <- callr::r(function() {
      options(CITES_DB_DIR = "localdb")
      con <- DBI::dbConnect(
        MonetDBLite::MonetDBLite(),
        getOption("CITES_DB_DIR")
      )
      out <- inherits(con, "MonetDBEmbeddedConnection")
      citesdb::cites_disconnect()
      options(CITES_DB_DIR = NULL)
      return(out)
    })
    stopifnot(success)
  }, NA)
})

test_that("Database is deleted", {
  skip_on_cran()
  skip_if_not(cites_status())

  expect_error(cites_db_delete(), NA)
  expect_equal(DBI::dbListTables(cites_db()), character(0))
  expect_false(cites_status())
})

unlink(Sys.getenv("CITES_DB_DIR"), recursive = TRUE)
Sys.setenv(CITES_DB_DIR = olddir)
