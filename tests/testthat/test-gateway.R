test_that("gateway returns full-precision JSON and ignores platform fields", {
  js <- gateway(model_input = get_default_input(), execution_id = "z",
                callback_url = "https://example.invalid/cb")
  expect_equal(jsonlite::fromJSON(js)$survival_90d,
               model_run(get_default_input())$survival_90d, tolerance = 1e-12)
  expect_equal(jsonlite::fromJSON(gateway())$score, 14)
})

test_that("empty strings and nulls count as not supplied", {
  x <- get_default_input(); x$units <- ""
  expect_equal(model_run(x)$score, 14)
  x$units <- NULL
  expect_equal(model_run(x)$score, 14)
})
