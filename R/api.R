api <- function(path = tempfile(), workers = 2, port = 8000) {
  model_queue_start(path, workers)
  path_api <- system.file("api.R", package = "modelapi", mustWork = TRUE)
  plumber::plumb(path_api)$run(port = port, swagger = TRUE)
}
