#' @title Queries PatentsView API by CPC
#'
#' @description This function formats the returned JSON objects into flat data frames
#'
#' @param pvresult
#'
#' @return a data frame of 27 fields
#'
#' @examples clean_patents(pvresult)
#'
#' @export

########################################
########### clean_patents() ############
########################################
clean_patents <- function(pvresult) {
  i <- 1
  num_dfs <- length(pvresult)
  dfs <- list()
  for (i in c(i:num_dfs)) {
    dfs[[i]] <- pvresult[[i]]$patents
  }
  dfs <- bind_rows(dfs) %>%
    unnest(cols = c("applications","assignees")) %>%
    mutate(inv_city_state=paste0(patent_firstnamed_inventor_city,", ",
                                 patent_firstnamed_inventor_state))

  return(dfs)
}
