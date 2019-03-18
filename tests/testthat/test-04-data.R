context("Data")

test_that("CITES data source hasn't changed", {
  skip_on_cran()
  httr::GET("https://trade.cites.org/cites_trade/download_db",
            httr::write_disk("cites_trade_db.zip"))
  expect_equivalent(tools::md5sum("cites_trade_db.zip"),
                    "3d774b109c3ebf3594cf0fd4c20c1d1b")
  unlink("cites_trade_db.zip")
})
