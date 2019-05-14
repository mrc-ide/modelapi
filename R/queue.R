## The bits here will pretty much all be repurposable for a general
## support package

model_queue_start <- function(root, workers = 2, name = "modelapi",
                              global = TRUE) {
  if (!global || is.null(cache$queue)) {
    ctx <- context::context_load(context_init(root, name))

    message("connecting to redis at ", redux::redis_config()$url)
    con <- redux::hiredis()

    message("Starting queue")
    rrq <- rrq::rrq_controller(ctx, con)
    if (workers > 0L) {
      rrq::worker_spawn(rrq, workers)
      reg.finalizer(rrq, model_queue_finalize)
    }

    if (!global) {
      return(rrq)
    }

    cache$queue <- rrq
  }
  invisible(cache$queue)
}

model_queue_submit <- function(data, queue = cache$queue) {
  queue$enqueue_(quote(model_run(data)))
}


model_queue_status <- function(id, queue = cache$queue) {
  status <- unname(queue$task_status(id))
  done <- c("ERROR", "COMPLETE")
  if (status %in% done) {
    list(done = TRUE,
         status = status,
         success = status == "COMPLETE",
         queue = NULL)
  } else {
    list(done = FALSE,
         status = status,
         success = NULL,
         queue = queue$task_position(id))
  }
}


model_queue_result <- function(id, queue = cache$queue) {
  queue$task_result(id)
}


model_queue_remove <- function(id, queue = cache$queue) {
  queue$task_delete(id)
}


## Not part of the api exposed functions, used in tests
model_queue_stop <- function(queue = cache$queue) {
  global <- identical(queue, cache$queue)
  queue$destroy(delete = TRUE)
  if (global) {
    cache$queue <- NULL
  }
}


model_queue_finalize <- function(queue) {
  message("Stopping workers")
  queue$worker_stop()
}


## Support for queue building
context_init <- function(root, name = "modelapi") {
  context::context_save(root,
                        sources = character(0),
                        packages = "modelapi",
                        name = name)
}
