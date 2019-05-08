# Response to reviewers

Thanks to both reviewers for their comments and issues


## Changes implemented

- We have changed the installation method to use `remotes` (which has lower
  dependencies than `devtools`).
- We have added disk location to `cites_status`
- We now clear out and disconnect the database tables after updating, which
  should trigger disk cleanup and avoid doubling database size
- We have modified out linter tests to avoid the false positives shown in
  https://github.com/ecohealthalliance/citesdb/issues/2
- We have renamed `cites_status()` to `cites_check_status()` to be less generic
- We have made more elaborate help and examples for the `cites_db()`, 
  `cites_shipments()`, and metadata functions to illustrate their use and
  distinguish between **dplyr** and **DBI**-based workflows.


## Changes not implemented / justifications

- We have opted not to use **glue** but stick with `paste` in the interest of
  limiting dependencies.  This is a trade-off but we believe a minor one.
- The low test coverage shown in https://github.com/ecohealthalliance/citesdb/issues/4
  is due to tests skippeed on CRAN.  Setting the environment variable to 
  `NOT_CRAN=true` shows that our test coverage is 65%.  This is lower than
  typical, but as we note above, this is largely due to the verbose code
  for interacting with the RStudio connection pane, which can not be
  straightforwardly tested. Other code coverage is 
  [greater than 90%](https://codecov.io/gh/ecohealthalliance/citesdb/tree/master/R)
  and all major funcionality is tested.
  
We have not yet been able to recreate the error in
https://github.com/ecohealthalliance/citesdb/issues/4, but have made some
changes that may resolve it.  Can reviewers test this and report back in that
issue?

A note - we have heard from the maintainers of MonetDBLite that it will not be
returning to CRAN (it's current iteration fails on R-devel), but they are
working on a successor embeedddeed database package that will replace it and go
to CRAN later this year. So for now we will host this package on GitHub and
replace the database back-end and send to CRAN when the successor is ready.
