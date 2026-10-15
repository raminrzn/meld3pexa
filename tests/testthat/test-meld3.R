# Expected values are from MDCalc's MELD calculator (MELD 3.0 mode), which
# reports the score and 90-day survival to 0.1%.
oracle <- data.frame(
  sex = c("male", "female", "male", "female", "male", "female", "female", "male", "male"),
  bilirubin = c(2.5, 2.5, 5.7, 5.7, 0.8, 12, 1.2, 8, 3.0),
  sodium = c(137, 137, 133, 133, 140, 128, 135, 130, 126),
  inr = c(1.4, 1.4, 1.8, 1.8, 0.9, 2.5, 1.1, 2.0, 1.6),
  creatinine = c(1.0, 1.0, 1.5, 1.5, 0.7, 4.5, 0.9, 2.0, 1.2),
  albumin = c(3.2, 3.2, 2.7, 2.7, 4.0, 2.0, 3.0, 2.5, 2.2),
  score = c(14, 15, 26, 28, 6, 41, 12, 32, 25),
  survival = c(98.1, 97.8, 85.4, 79.9, 99.5, 10.7, 98.7, 63.5, 87.7),
  stringsAsFactors = FALSE
)

test_that("score and 90-day survival match the reference calculator", {
  for (i in seq_len(nrow(oracle))) {
    r <- do.call(meld3, as.list(oracle[i, 1:6]))
    expect_equal(r$score, oracle$score[i], label = paste("row", i))
    expect_lt(abs(100 * r$survival_90d - oracle$survival[i]), 0.051)
  }
})

test_that("SI units give the same answer", {
  a <- meld3("male", 5.7, 133, 1.8, 1.5, 2.7)
  b <- meld3("male", 5.7 * 17.1, 133, 1.8, 1.5 * 88.4, 27, units = "si")
  expect_equal(a$raw_score, b$raw_score, tolerance = 1e-10)
})

test_that("bounds are applied before the logs", {
  low <- meld3("male", 0.2, 150, 0.8, 0.3, 5)
  ref <- meld3("male", 1, 137, 1, 1, 3.5)
  expect_equal(low$raw_score, ref$raw_score)
  expect_equal(ref$raw_score, 6)
  expect_equal(meld3("male", 2, 137, 1, 9, 3.5)$raw_score,
               meld3("male", 2, 137, 1, 3, 3.5)$raw_score)
})

test_that("bad input fails clearly", {
  expect_error(meld3("x", 1, 137, 1, 1, 3.5), "sex")
  expect_error(meld3("male", 1, 137, 1, 90, 3.5), "SI")
  expect_error(model_run(list(sex = "male")), "Missing")
})
