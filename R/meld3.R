# MELD 3.0 (Kim WR, et al. Gastroenterology 2021;161:1887-1895).
#
# Preprocessing (Results): bilirubin, INR and creatinine below 1.0 are set to
# 1.0; creatinine is capped at 3.0 mg/dL; sodium is bounded to 125-137 mEq/L;
# albumin to 1.5-3.5 g/dL. The score is rounded to the nearest integer; halves
# round up (floor(x + 0.5)), not R's round-half-to-even.
#
# 90-day survival uses the published survival function
# S(90) = 0.946 ^ exp(0.17698 * score - 3.56). The paper's worked examples
# differ from this equation by up to about 1 percentage point; the score itself
# is unaffected. Only the 90-day horizon is offered here.

.meld3_round <- function(x) floor(x + 0.5)

#' MELD 3.0 score and 90-day survival
#'
#' @param sex `"male"` or `"female"`.
#' @param bilirubin Total bilirubin.
#' @param sodium Serum sodium, mEq/L (= mmol/L).
#' @param inr INR.
#' @param creatinine Serum creatinine.
#' @param albumin Serum albumin.
#' @param units `"conventional"` (bilirubin and creatinine mg/dL, albumin
#'   g/dL) or `"si"` (bilirubin and creatinine umol/L, albumin g/L).
#' @return A data frame with `score`, `raw_score`, `survival_90d` and
#'   `mortality_90d`.
#' @references Kim WR, et al. MELD 3.0. *Gastroenterology.*
#'   2021;161:1887-1895. \doi{10.1053/j.gastro.2021.08.050}
#' @examples
#' meld3("male", bilirubin = 2.5, sodium = 137, inr = 1.4, creatinine = 1.0,
#'       albumin = 3.2)
#' @export
meld3 <- function(sex, bilirubin, sodium, inr, creatinine, albumin,
                  units = "conventional") {
  units <- match.arg(tolower(units), c("conventional", "si"))
  key <- tolower(trimws(as.character(sex)))
  female <- if (key %in% c("female", "f")) 1 else if (key %in% c("male", "m")) 0 else
    stop('Unrecognised `sex`: "', sex, '". Use "male" or "female".', call. = FALSE)

  bili <- .meld_num(bilirubin, "bilirubin", 0, 1000)
  crea <- .meld_num(creatinine, "creatinine", 0, 2000)
  alb  <- .meld_num(albumin, "albumin", 0, 100)
  na   <- .meld_num(sodium, "sodium", 90, 200)
  inr  <- .meld_num(inr, "inr", 0.5, 20)
  if (units == "si") {
    bili <- bili / 17.1; crea <- crea / 88.4; alb <- alb / 10
  } else if (crea > 30 || alb > 10) {
    stop("Creatinine or albumin looks like SI units; set `units = \"si\"`.",
         call. = FALSE)
  }

  bili <- max(bili, 1); inr <- max(inr, 1)
  crea <- min(max(crea, 1), 3)
  na   <- min(max(na, 125), 137)
  alb  <- min(max(alb, 1.5), 3.5)

  raw <- 1.33 * female + 4.56 * log(bili) + 0.82 * (137 - na) -
    0.24 * (137 - na) * log(bili) + 9.09 * log(inr) + 11.14 * log(crea) +
    1.85 * (3.5 - alb) - 1.83 * (3.5 - alb) * log(crea) + 6
  score <- .meld3_round(raw)
  surv <- 0.946^exp(0.17698 * score - 3.56)
  data.frame(score = score, raw_score = raw, survival_90d = surv,
             mortality_90d = 1 - surv)
}
