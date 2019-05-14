## The api for plumber.  There are two ways of building this - one is
## an "comments" approach, the other is directly building the R6
## objects - eventually we will want the latter.

#* Say hello
#* @get /
api_root <- function() {
  jsonlite::unbox("Welcome to modelapi")
}


#* Get the package version
#* @get /version
api_version <- function() {
  list(R = jsonlite::unbox(as.character(getRversion())),
       modelapi = jsonlite::unbox(as.character(packageVersion("modelapi"))))
}


#* Validate inputs
#* @post /validate
#* @param csv_data Comma-separated-values data, as a string array
#* @param parameters Dictionary of parameters, must include the
#*   parameters "a", "b", "time" and "poll" with other parameters
#*   ignored
#* @serializer unboxedJSON
api_validate <- function(csv_data, parameters) {
  tryCatch({
    modelapi:::validate_inputs(csv_data, parameters)
    list(success = TRUE, error = NA)
  }, error = function(e) list(success = FALSE, error = e$message))
}


#* Submit model run
#* @post /model/submit
#* @param csv_data Comma-separated-values data, as a string array
#* @param parameters Dictionary of parameters, must include the
#*   parameters "a", "b", "time" and "poll" with other parameters
#*   ignored
api_model_submit <- function(csv_data, parameters) {
  inputs <- modelapi:::validate_inputs(csv_data, parameters)
  id <- modelapi:::model_queue_submit(inputs)
  jsonlite::unbox(id)
}


#* Query model status
#* @get /model/<id>/status
#* @serializer unboxedJSON
api_model_status <- function(id) {
  modelapi:::model_queue_status(id)
}


#* Get model result
#* @get /model/<id>/result
api_model_status <- function(id) {
  modelapi:::model_queue_result(id)
}


api <- function() {
  pr <- plumber::plumber$new()
  pr$handle("GET", "/version", api_version)
}
