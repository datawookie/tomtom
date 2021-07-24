#' @import dplyr
#' @import httr
#' @import logger
NULL

PKG_VERSION <- utils::packageDescription('tomtom')$Version

#' Set API key
#'
#' @param api_key TomTom API key.
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

get_api_key <- function() {
  get("api_key", api_key, envir = cache)
}
