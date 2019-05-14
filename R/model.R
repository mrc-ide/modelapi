## This file contains just the model bits of code.  There's more
## metadata-based things that could be done here.  Entry point will be
##
## * a function that runs a model (input => output, both opaque)
## * validate inputs (any number of args => input, latter opaque,
##   throwing error if it does not work)

##' Run model
##' @title Run model
##' @param inputs Opaque list of inputs
##' @export
model_run <- function(inputs) {
  time <- inputs$parameters$time
  poll <- inputs$parameters$poll

  t <- seq(0, inputs$parameters$b, length.out = inputs$parameters$a)
  output <- list(
    fitted = list(a = inputs$parameters$a * 2,
                  b = inputs$parameters$b * 3),
    simulation = data.frame(
      t = t,
      y = sin(t),
      z = stats::runif(length(t))))

  end <- Sys.time() + time
  while (Sys.time() < end) {
    message(model_status())
    Sys.sleep(stats::rexp(1, poll))
  }

  output
}


##' Validate model inputs
##' @title Validate model inputs
##' @param csv_data A string representing a csv file
##' @param parameters A list of parameters
validate_inputs <- function(csv_data, parameters) {
  expected <- c("a", "b", "time", "poll")
  msg <- setdiff(expected, names(parameters))
  if (length(msg)) {
    stop("Missing parameters: ", paste(msg, collapse = ", "))
  }
  path <- tempfile()
  on.exit(unlink(path))
  writeLines(csv_data, path)
  data <- utils::read.csv(path, stringsAsFactors = FALSE)
  if (nrow(data) < 3) {
    stop("Expected at least 3 rows")
  }
  list(parameters = parameters, data = data)
}


model_status <- function() {
  sprintf("[%s]: %s", Sys.time(), sample(cache$model_status_messages, 1))
}


model_status_load <- function() {
  path <- system.file("model_status_messages", package = "modelapi",
                      mustWork = TRUE)
  cache$model_status_messages <- readLines(path)
}
