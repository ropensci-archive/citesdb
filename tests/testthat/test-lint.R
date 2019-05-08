if (requireNamespace("lintr", quietly = TRUE)) {
  context("lints")
  test_that("Package Style", {
    skip_on_cran()
    lintr::expect_lint_free(
      linters = lintr::with_defaults(
        camel_case_linter = NULL,
        snake_case_linter = NULL,
        absolute_paths_linter = NULL
      ))
  })
}
