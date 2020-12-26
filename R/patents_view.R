#' @title Queries PatentsView API by CPC
#'
#' @description This function submits requests to the PatentsView API to return information on patents by CPC code. It calls both pv_post() and clean_patents().
#'
#' @param cpc
#'
#' @return a data frame of 27 fields
#'
#' @examples patents_view(cpc="G16H")
#'
#' @export patents_view

########################################
########### patents_view() ############
########################################
patents_view <- function(cpc) {
  # initialize list
  results <- list()
  results[[1]] <- pv_post(page=1)
  # figure how how many more pages of results there are
  names(results[[1]])[[3]] <- "total"
  # rename this from patents/assignees to "total" for math reasons
  pgs <- ceiling(results[[1]]$total/results[[1]]$count)
  if (pgs>1) { # loop through remaining pages, if there's more than 1
    for (i in c(2:pgs)) {
      results[[i]] <- pv_post(page=i)
    }
    return(clean_patents(results))
  }
  else {
    return(clean_patents(results))
  }
}
