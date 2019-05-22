# Response to reviewers

Thanks to both reviewers for their comments and issues that have 
helped us to make a more user-friendly package.

## Changes implemented

- We have changed the installation method in the `README` to use **devtools**.
  
- We have added information to the `cites_status` table indicating the location 
  of the database files on disk.

- We now clear out and disconnect the database tables after updating, which
  should trigger disk cleanup and avoid doubling database size.
  
- Thanks for the reviewers for sticking with us through a long and merry chase
  of a bug that was preventing package-building in 
  https://github.com/ecohealthalliance/citesdb/issues/1, which had its origins
  in a missing token for use with the **rcites** package as well as a low-level
  database lock issue. We now cache this the **rcites** information to avoid
  having to make remote calls in vignette-building, and also have resolved the
  DB locking conflict.

- We have modified our linter tests to avoid the false positives shown in
  https://github.com/ecohealthalliance/citesdb/issues/2.
  
- We have renamed the internal function `check_status()` to `cites_check_status()`
  to be less generic.
  
- We have made more elaborate help and examples for the `cites_db()`, 
  `cites_shipments()`, and metadata functions to illustrate their use and
  distinguish between **dplyr**- and **DBI**-based workflows.

## Changes not implemented / justifications

- We have opted not to use the **glue** package and instead stick with the base
  R `paste()` functions in the interest of limiting dependencies. We believe
  this is a minor trade-off.
  
- The low test coverage shown in https://github.com/ecohealthalliance/citesdb/issues/4
  is due to tests skipped on CRAN. Setting the environment variable to 
  `NOT_CRAN=true` shows that our test coverage is 65%. This is lower than
  typical, but as we note in the issue above, this is largely due to the 
  verbose code for interacting with the RStudio connection pane, which cannot be
  tested except in an interactive session. Other code coverage is 
  [greater than 90%](https://codecov.io/gh/ecohealthalliance/citesdb/tree/master/R).
  We believe that all core functionality is tested, including important
  edge-cases and conditions not reflected in the coverage statistic, such as
  error handling in multiple sessions and changing up upstream data sources.
  
A final note: we have learned from the maintainers of **MonetDBLite** that it will 
not be returning to CRAN (its current iteration fails on R-devel), but they are
working on a successor embedded database package that will replace it and go
to CRAN later this year. So, for now, we will host this package on GitHub and
replace the database back-end and send to CRAN when the successor package is ready.
We've added a note to the README showing that users need package build tools for
the current version.
