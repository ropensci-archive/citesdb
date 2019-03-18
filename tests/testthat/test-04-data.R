context("Data")

test_that("CITES data source hasn't changed", {
  skip_on_cran()
  tmpf <- tempfile()
  httr::GET("https://trade.cites.org/cites_trade/download_db",
            httr::write_disk(tmpf))
  expect_equivalent(tools::md5sum(tmpf), "3d774b109c3ebf3594cf0fd4c20c1d1b")
  unlink(tmpf)
})
