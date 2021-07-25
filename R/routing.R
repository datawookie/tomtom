URL_ROUTING <- 'https://api.tomtom.com/routing/1/calculateRoute'

# More documentation (with numerous other options):
#
# - https://developer.tomtom.com/routing-api/routing-api-documentation
# - https://developer.tomtom.com/content/routing-api-explorer

#' Calculate route between series of points
#'
#' @param locations A \code{sf} object with a series of points that need to be on route.
#' @param alternatives Number of alternative routes.
#'
#' @export
#'
#' @examples
#' library(dplyr)
#' library(sf)
#'
#' library(tomtom)
#'
#' TOMTOM_API_KEY = Sys.getenv("TOMTOM_API_KEY")
#' set_api_key(TOMTOM_API_KEY)
#'
#' locations <- tribble(
#'   ~label, ~lon, ~lat,
#'   "Durban", 31.05, -29.88,
#'   "Port Elizabeth", 25.6, -33.96,
#'   "Cape Town", 18.42, -33.93,
#'   "Johannesburg", 28.05, -26.20
#' )
#'
#' locations <- st_as_sf(locations, coords = c("lon", "lat"), remove = FALSE, crs = 4326)
#' calculate_route(locations)
calculate_route <- function(
  locations,
  alternatives = 0
) {
  route = map(locations$geometry, ~ paste(rev(.), collapse = ",")) %>%
    paste(collapse = ":")

  URL = file.path(URL_ROUTING, URLencode(route, reserved = TRUE), 'json')

  response = GET(
    URL,
    query = list(
      avoid = 'unpavedRoads',
      maxAlternatives = alternatives
    )
  )

  journey <- content(response)

  # This gives distance and travel time.
  #
  journey$routes[[1]]$legs[[1]]$summary

  unpack_leg <- function(leg) {
    summary <- leg$summary %>%
      as_tibble() %>%
      select(
        distance = lengthInMeters,
        time = travelTimeInSeconds,
        delay = trafficDelayInSeconds,
        depart = departureTime,
        arrive = arrivalTime
      )

    points <- map_dfr(leg$points, identity) %>%
      select(
        lat = latitude,
        lon = longitude
      ) %>%
      nest(points = c(lon, lat))

    bind_cols(summary, points)
  }

  unpack_route <- function(route) {
    map_dfr(route$legs, unpack_leg) %>%
      mutate(leg = row_number()) %>%
      nest(data = everything())
  }

  map_dfr(journey$routes, unpack_route) %>%
    mutate(route = row_number()) %>%
    unnest(cols = c(data)) %>%
    select(route, leg, everything()) %>%
    mutate(
      route = factor(route),
      leg = factor(leg)
    )
}
