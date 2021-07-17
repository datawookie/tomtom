#' @import httr
#' @import logger
NULL

#' Set API key
#'
#' @param api_key
#'
#' @return
#' @export
#'
#' @examples
#' set_api_key("USf9S3AINkT4MhQZfz66ogYa3ZEGwPzZ")
set_api_key <- function(api_key) {
  log_debug("Setting API key: {api_key}.")
  assign("api_key", api_key, envir = cache)
}
