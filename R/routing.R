#' Title
#'
#' @return
#' @export
#'
#' @examples
calculate_route <- function() {
  response = GET(
    'https://api.tomtom.com/routing/1/calculateRoute/52.50931%2C13.42936%3A52.50274%2C13.43872/json',
    query = list(
      avoid = 'unpavedRoads'
    )
  )

  content(response)
}
