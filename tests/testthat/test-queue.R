context("queue")

test_that("basic queue operation", {
  queue <- model_queue_start(tempfile(), workers = 1, global = FALSE)
  on.exit(model_queue_stop(queue))
  expect_null(cache$queue)

  inputs <- validate_inputs("a,b\n1,2\n2,3\n3,4\n",
                            list(a = 20, b = 3, time = 0.5, poll = 100))
  id <- model_queue_submit(inputs, queue = queue)

  s1 <- model_queue_status(id, queue = queue)
  expect_true(s1$status %in% c("PENDING", "RUNNING"))
  expect_null(s1$success)
  expect_equal(s1$queue, 0L)
  expect_false(s1$done)

  queue$task_wait(id, timeout = 2, progress = FALSE)
  s2 <- model_queue_status(id, queue = queue)
  expect_equal(s2$status, "COMPLETE")
  expect_true(s2$success)
  expect_null(s2$queue, 0L)
  expect_true(s2$done)

  res <- model_queue_result(id, queue = queue)
  expect_setequal(names(res), c("fitted", "simulation"))
})


test_that("queue length", {
  queue <- model_queue_start(tempfile(), workers = 0, global = FALSE)
  inputs <- validate_inputs("a,b\n1,2\n2,3\n3,4\n",
                            list(a = 20, b = 3, time = 0.5, poll = 100))
  id1 <- model_queue_submit(inputs, queue = queue)
  id2 <- model_queue_submit(inputs, queue = queue)
  id3 <- model_queue_submit(inputs, queue = queue)

  s1 <- model_queue_status(id1, queue = queue)
  s2 <- model_queue_status(id2, queue = queue)
  s3 <- model_queue_status(id3, queue = queue)

  expect_equal(s1$status, "PENDING")
  expect_equal(s2$status, "PENDING")
  expect_equal(s3$status, "PENDING")

  expect_equal(s1$queue, 1)
  expect_equal(s2$queue, 2)
  expect_equal(s3$queue, 3)

  ## This is actually a bug: need to remove the task from
  ## keys$queue_rrq though that is a little difficult without some
  ## transactional tricks
  model_queue_remove(id2, queue = queue)
  expect_equal(model_queue_status(id3, queue = queue)$queue, 3)
})


test_that("global queue", {
  queue <- model_queue_start(tempfile(), workers = 0, global = TRUE)
  expect_identical(queue, cache$queue)
  model_queue_stop()
  expect_null(cache$queue)
})


test_that("worker cleanup", {
  skip_on_os("windows")
  queue <- model_queue_start(tempfile(), workers = 1, global = FALSE)

  info <- queue$worker_info()[[1]]
  handle <- ps::ps_handle(info$pid)
  expect_true(ps::ps_is_running(handle))

  rm(queue)
  gc()
  Sys.sleep(1)

  expect_false(ps::ps_is_running(handle))
})
