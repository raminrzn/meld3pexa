.meld_vars <- c("sex", "bilirubin", "sodium", "inr", "creatinine", "albumin", "units")
.meld_alias <- c(gender = "sex", bili = "bilirubin", total_bilirubin = "bilirubin",
                 na = "sodium", serum_sodium = "sodium", cr = "creatinine",
                 creat = "creatinine", alb = "albumin")

#' MELD 3.0 (ModelsCloud entry point)
#' @param model_input Named list: `sex`, `bilirubin`, `sodium`, `inr`,
#'   `creatinine`, `albumin`, optional `units`.
#' @param ... The same fields as named arguments.
#' @return See [meld3()].
#' @export
model_run <- function(model_input = NULL, ...) {
  args <- .meld_normalize(model_input, list(...), .meld_vars, .meld_alias)
  if (is.null(args) || length(args) == 0) args <- get_default_input()
  missing <- setdiff(setdiff(.meld_vars, "units"), names(args))
  if (length(missing) > 0) {
    stop("Missing required variable(s): ", paste(missing, collapse = ", "), ".",
         call. = FALSE)
  }
  do.call(meld3, args)
}

#' Example MELD 3.0 inputs
#' @param n Optional number of rows.
#' @param ... Ignored.
#' @export
get_sample_input <- function(n = NULL, ...) {
  df <- data.frame(sex = c("male", "female", "male"), bilirubin = c(2.5, 2.5, 5.7),
                   sodium = c(137, 137, 133), inr = c(1.4, 1.4, 1.8),
                   creatinine = c(1.0, 1.0, 1.5), albumin = c(3.2, 3.2, 2.7),
                   stringsAsFactors = FALSE)
  if (!is.null(n)) df <- utils::head(df, n)
  df
}

#' Default MELD 3.0 input
#' @param ... Ignored.
#' @export
get_default_input <- function(...) {
  list(sex = "male", bilirubin = 2.5, sodium = 137, inr = 1.4,
       creatinine = 1.0, albumin = 3.2)
}
