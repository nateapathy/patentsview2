#' @title Queries PatentsView API by CPC
#'
#' @description This function formats and submits a POST call to the PatentsView Patents API endpoint
#'
#' @param page
#'
#' @return a data frame of 27 fields
#'
#' @examples clean_patents(pvresult)
#'
#' @export

########################################
########### patent_post() ##############
########################################
pv_post <- function(page,start_date,env = parent.frame(),...) {
  # get first page of results
  request <- httr::POST(url="https://api.patentsview.org/patents/query",
                        body=list(
                          q=list(
                            "_and"=c( # AND boolean operator to wrap around all three query components
                              list( # need these unnamed lists for whatever reason to make sure the wrapper does [] correctly
                                list( # greater than date criteria
                                  "_gte"=list(
                                    app_date=start_date # all patents granted since Jan 2000
                                  )
                                )
                              ),
                              list(
                                list(
                                  cpc_section_id=substr(env$cpc, 1, 1)
                                )
                              ),
                              list(
                                list(
                                  cpc_subsection_id=substr(env$cpc, 1, 3)
                                )
                              ),
                              list( # CPC category
                                list(
                                  cpc_group_id=env$cpc #
                                )
                              ),
                              list(
                                list(
                                  assignee_lastknown_country="US" # only from US applicants
                                )
                              )
                            )
                          ),
                          f=c("patent_id", # hard-code the fields that will come back by default
                              "patent_number",
                              "patent_title",
                              "patent_abstract",
                              "patent_date",
                              "patent_year",
                              "patent_firstnamed_inventor_city",
                              "patent_firstnamed_inventor_state",
                              "patent_firstnamed_inventor_latitude",
                              "patent_firstnamed_inventor_longitude",
                              "patent_num_cited_by_us_patents",
                              "patent_num_combined_citations",
                              "patent_processing_time",
                              "patent_type",
                              "govint_contract_award_number",
                              "govint_raw_statement",
                              "patent_num_cited_by_us_patents",
                              "patent_num_us_patent_citations",
                              # assignee info
                              "patent_firstnamed_assignee_id", # from patents table
                              "patent_firstnamed_assignee_city", # from patents table
                              "patent_firstnamed_assignee_state", # from patents table
                              "patent_firstnamed_assignee_latitude", # from patents table
                              "patent_firstnamed_assignee_longitude", # from patents table
                              "assignee_organization", # from assignees table, requires unnesting
                              "assignee_type", # from assignees table, requires unnesting
                              "assignee_total_num_patents", # from assignees table, requires unnesting
                              "assignee_first_seen_date",
                              "assignee_last_seen_date",
                              # application info
                              "app_date","app_id",
                              # cpc info
                              "cpc_group_id","cpc_group_title"),
                          o=list("page"=page,
                                 "per_page"=1000
                                 )
                        ),
                        encode = "json")
  # parse first page of results
  results <- fromJSON(content(request,
                              as = "text",
                              encoding = "UTF-8"),
                      flatten = T)
  return(results)
}
