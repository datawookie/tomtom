#' Title
#'
#' @return
#' @export
#'
#' @examples
incident_details <- function() {
  response = GET(
    'https://api.tomtom.com/traffic/services/5/incidentDetails',
    query = list(
      bbox = '4.8854592519716675,52.36934334773164,4.897883244144765,52.37496348620152',
      fields = '{incidents{type,geometry{type,coordinates},properties{id,iconCategory,magnitudeOfDelay,events{description,code},startTime,endTime,from,to,length,delay,roadNumbers,aci{probabilityOfOccurrence,numberOfReports,lastReportTime}}}}'
    )
  )

  content(response)
}
