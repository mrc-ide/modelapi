context("model")

test_that("run model", {
  inputs <- validate_inputs("a,b\n1,2\n2,3\n3,4\n",
                            list(a = 20, b = 3, time = 0.1, poll = 100))
  res <- model_run(inputs)
  expect_equal(res$fitted, list(a = 40, b = 9))
  expect_equal(res$simulation$t, seq(0, 3, length.out = 20))
  expect_equal(res$simulation$y, sin(res$simulation$t))
  expect_is(res$simulation$z, "numeric")
})


test_that("validate", {
  expect_error(
    validate_inputs("a,b\n1,2\n2,3\n",
                    list(a = 20, b = 3, time = 0.1, poll = 100)),
    "Expected at least 3 rows")
  expect_error(
    validate_inputs("a,b\n1,2\n2,3\n3,4\n",
                    list(a = 20, poll = 100)),
    "Missing parameters: b, time")
})


test_that("model status", {
  cache$model_status_messages <- NULL
  model_status_load()
  expect_is(cache$model_status_messages, "character")
})
