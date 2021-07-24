URL_ROUTING <- 'https://api.tomtom.com/routing/1/calculateRoute'

#' Title
#'
#' @param src The location (vector of latitude, longitude) of the origin.
#' @param dst The location (vector of latitude, longitude) of the destination.
#'
#' @return
#' @export
#'
#' @examples
calculate_route <- function(src, dst) {
  src <- paste(src, collapse = ",")
  dst <- paste(dst, collapse = ",")

  URL = file.path(URL_ROUTING, URLencode(paste(src, dst, sep = ":"), reserved = TRUE), 'json')

  response = GET(
    URL,
    query = list(
      avoid = 'unpavedRoads'
    )
  )

  route <- content(response)

  # This gives distance and travel time.
  #
  # route$routes[[1]]$legs[[1]]$summary

  route$routes[[1]]$legs[[1]]$points %>% map_dfr(identity)
}
