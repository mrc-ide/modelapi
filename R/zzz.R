cache <- new.env()

.onLoad <- function(...) {
  model_status_load() # nocov
}
