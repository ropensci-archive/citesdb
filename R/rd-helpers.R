# Modified from https://cran.r-project.org/web/packages/roxygen2/vignettes/formatting.html#tables

tabular <- function(df, col_names = TRUE, ...) {
  stopifnot(is.data.frame(df))

  align <- function(x) if (is.numeric(x)) "r" else "l"
  col_align <- vapply(df, align, character(1))

  cols <- lapply(df, format, ...)
  contents <- do.call(
    "paste",
    c(cols, list(sep = " \\tab ", collapse = "\\cr\n  "))
  )

  if (col_names) {
    header <- paste0("\\bold{", colnames(df), "}", collapse = " \\tab")
    contents <- paste0(header, "\\cr\n  ", contents)
  }

  paste(
    "\\tabular{", paste(col_align, collapse = ""), "}{\n  ",
    contents, "\n}\n",
    sep = ""
  )
}

#' @noRd
rd_datatable <- function(df, width = "100%", ...) {
  wrap_widget(DT::datatable(df, width = width, ...))
}

#' @noRd
wrap_widget <- function(widget) {
  tmp <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget(widget, tmp)
  widg <- paste(
    grep("^</?(!DOCTYPE|meta|body|html|head|title)",
      readLines(tmp),
      value = TRUE, invert = TRUE
    ),
    collapse = "\n"
  )
  paste("\\out{", escape_rd(widg), "}\n", sep = "\n")
}

#' @noRd
escape_rd <- function(x) {
  x <- gsub("\\", "\\\\", x, fixed = TRUE)
  x <- gsub("%", "\\%", x, fixed = TRUE)
  x <- gsub("{", "\\{", x, fixed = TRUE)
  x <- gsub("}", "\\}", x, fixed = TRUE)
  x
}

is_js_ok <- function() {
  in_pkgdown <- any(grepl("as_html.tag_Sexpr", sapply(sys.calls(), function(a) paste(deparse(a), collapse = "\n"))))
  !(in_pkgdown) && require(DT)
}
