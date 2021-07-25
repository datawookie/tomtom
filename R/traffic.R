URL_TRAFFIC_INCIDENT <- 'https://api.tomtom.com/traffic/services/5/incidentDetails'
FIELDS <- '{incidents{type,geometry{type,coordinates},properties{id,iconCategory,magnitudeOfDelay,events{description,code},startTime,endTime,from,to,length,delay,roadNumbers,aci{probabilityOfOccurrence,numberOfReports,lastReportTime}}}}'

# More documentation (with numerous other options):
#
# - https://developer.tomtom.com/traffic-api/traffic-api-documentation
# - https://developer.tomtom.com/content/traffic-api-explorer

#' Traffic incidents
#'
#' @param left Left edge of bounding box.
#' @param bottom  Bottom edge of bounding box.
#' @param right  Right edge of bounding box.
#' @param top  Top edge of bounding box.
#'
#' @export
#'
#' @examples
#' #' library(tomtom)
#'
#' TOMTOM_API_KEY = Sys.getenv("TOMTOM_API_KEY")
#' set_api_key(TOMTOM_API_KEY)
#'
#' incidents <- incident_details(23.4, 37.9, 24.0, 38.2)
incident_details <- function(left, bottom, right, top) {
  bbox <- paste(c(left, bottom, right, top), collapse = ",")

  response = GET(
    URL_TRAFFIC_INCIDENT,
    query = list(
      bbox = bbox,
      fields = FIELDS
    )
  )

  traffic <- content(response)

  unpack_incident <- function(incident) {
    properties <- incident$properties
    # Handle multiple events.
    properties$events <- properties$events %>% map_dfr(identity)
    properties <- properties %>% unlist(recursive = FALSE)
    # Set up list columns.
    properties$events.description = paste(properties$events.description, collapse = "; ")
    properties$events.code = paste(properties$events.code, collapse = "; ")

    properties <- as.data.frame(properties)

    points <- sapply(incident$geometry$coordinates, c) %>%
      t() %>%
      data.frame() %>%
      setNames(c("lon", "lat")) %>%
      mutate_all(unlist)

    tibble(properties, points = list(points))
  }

  map_dfr(traffic$incidents, unpack_incident) %>%
    rename(
      begin = startTime,
      end = endTime
    ) %>%
    select(-id, -iconCategory, -magnitudeOfDelay) %>%
    rename_at(
      vars(starts_with("events")),
      ~ sub("^.*\\.", "", .)
    ) %>%
    mutate(
      length = as.numeric(length),
      incident = row_number(),
      description = factor(description)
    ) %>%
    select(
      incident, begin, end, description, from, to, length, points
    )
}
