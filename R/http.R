http_error_message <- function(response) {
  status_code <- response$status_code

  error_message <- case_when(
    status_code %in% c(401, 403) ~ "Missing or invalid TomTom API key.",
    status_code == 404 ~ "Not found.",
    status_code == 429 ~ "Limit exceeded."
  )

  if (!is.na(error_message)) stop(error_message, call. = FALSE)
}

#' Wrapper for httr::GET()
#'
#' @param url URL to retrieve.
#' @param config Additional configuration settings.
#' @param ... Further named parameters.
#' @param query Query parameters.
#' @param headers Header records.
#' @param retry Number of times to retry request on failure.
GET <- function(url, query = list(), headers = list(), config = list(), retry = 5, ...) {
  headers$accept = "*/*"

  query$key = get_api_key()

  api_key <- NULL
  try(api_key <- get_api_key(), silent = TRUE)

  response = httr::GET(
    url,
    do.call(add_headers, headers),
    query = query,
    httr::user_agent(paste0("tomtom [R] (", PKG_VERSION, ")"))
  )

  http_error_message(response)

  response
}
