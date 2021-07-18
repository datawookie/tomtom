http_error_message <- function(response) {
  status_code <- response$status_code

  error_message <- case_when(
    status_code == 401 ~ "Missing or invalid API key.",
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
#' @param retry Number of times to retry request on failure.
GET <- function(url, query = list(), headers = list(), config = list(), retry = 5, ...) {
  headers$accept = "*/*"

  query$key = get_api_key()

  api_key <- NULL
  try(api_key <- get_api_key(), silent = TRUE)

  response = httr::RETRY(
    "GET",
    url,
    do.call(add_headers, headers),
    query = query,
    times = retry,
    terminate_on = c(401, 404, 429),
    httr::user_agent(paste0("tomtom [R] (", PKG_VERSION, ")"))
  )

  http_error_message(response)

  response
}
