
# patentsview

`patentsview` is a simple set of functions to query the [Patents
endpoint](https://api.patentsview.org/patent.html) of the [PatentsView
API](https://www.patentsview.org/) using [CPC
Subclass](https://en.wikipedia.org/wiki/Cooperative_Patent_Classification)
identifiers (e.g. [G16H for medical
informatics](https://www.uspto.gov/web/patents/classification/cpc/html/cpc-G16H.html#G16H))

# Introduction

Patents and patent applications are a valuable measure of innovation
within countries, sub-national geographies (e.g. states or cities),
industries, and firms. Numerous patent databases exist, including
[PATSTAT from the EPO](https://data.epo.org/expert-services/index.html),
[NBER](https://www.nber.org/research/data/us-patents), [Google
Patents](https://patents.google.com/), [OECD Patent
Microdata](http://www.oecd.org/sti/intellectual-property-statistics-and-analysis.htm),
[the
USPTO](https://www.uspto.gov/patents-application-process/search-patents),
and [others](https://iii.pubpub.org/datasets). These databases can be
unweildy, so the USPTO created
[PatentsView](https://www.patentsview.org/) as a user-friendly query
portal for data about individual patents. They also implemented several
API endpoints that can be queried directly. Despite its public
availability and documentation, the PatentsView API isn’t *that* easy to
use. So to collect data about patents across different patent types,
classified by Cooperative Patent Classification (CPC) subclasses, I
wrote a few helper functions. Hope they’re useful.

# the `patents_view()` function

`patentsview::patents_view()` is the primary function. This function
calls two other functions, `pv_post()` and `clean_patents()`. This
function has a single argument, `cpc`, which takes a string consisting
of any of the 4-character CPC subclasses available in PatentsView. By
default, the function returns all patent applications with the defined
classification since Jan 1, 2000 to the USPTO by US-based assignees.

``` r
patentsview::patents_view(cpc="F03B")
```

This returns a data frame of patent application observations and 27
fields of information about the patent as well as the first named
inventor and assignee.

## `pv_post()` and `clean_patents()`

You should not have to call either of these functions directly. Both are
called by `patents_view()` to help with constructing the POST call to
the API and to clean up the data frame, as their names imply.

# the CPC datasets

The package also includes two data sets for reference to CPC subclasses.
`cpc_subgroups` lists all subclasses, groups, and subgroups (258,827
observations), while `cpc_subclasses` lists only the four-character
subclass codes (615 observations) that can be used in the `cpc` argument
within `patents_view()`.

``` r
data("cpc_subclasses") # 615 obs by 2 vars
data("cpc_subgroups") # 258,827 obs by 5 vars
```

Use `cpc_subclasses` to find subclasses of interest, and use the
4-character code found in the `cpc_subclass` field in your query. You
can also [browse the CPC hierarchy from the
USPTO](https://www.uspto.gov/web/patents/classification/cpc/html/cpc.html).
You may also want to loop through several CPC subclasses, as below. Note
that the below code does not look for patents with all subclasses, but
rather performs distinct API calls for each of the 5 random CPC
subclasses sampled. In this case, the 5 data frames will all be in the
`random_cpcs` list.

``` r
# random sample of CPCs
cpc_samp <- sample(cpc_subclasses$cpc_subclass,5)
random_cpcs <- list()
for (i in c(1:length(cpc_samp))) {
  random_cpcs[[i]] <- patents_view(cpc=cpc_samp[i])
}
names(random_cpcs) <- cpc_samp
```

# an example

``` r
# CPC Subclass B62K: Unicycles
cpc_subclasses %>% filter(cpc_subclass=="B62K")
#>   cpc_subclass     title
#> 1         B62K Unicycles
b62k <- patentsview::patents_view(cpc="B62K")
dim(b62k) 
#> [1] 1844   27
# 1,844 patent applications since Jan 1 2000

# get number of unique patient numbers
# remember, each observation is an APPLICATION not a patent
unique(b62k$patent_number) %>% length() 
#> [1] 1811
# 1,811 unqiue patent numbers

# how many unique assignees?
unique(b62k$assignee_organization) %>% length() 
#> [1] 454
# 454 unqiue assignees

# what other fields do we have?
colnames(b62k)
#>  [1] "patent_id"                           
#>  [2] "patent_number"                       
#>  [3] "patent_title"                        
#>  [4] "patent_abstract"                     
#>  [5] "patent_date"                         
#>  [6] "patent_year"                         
#>  [7] "patent_firstnamed_inventor_city"     
#>  [8] "patent_firstnamed_inventor_state"    
#>  [9] "patent_firstnamed_inventor_latitude" 
#> [10] "patent_firstnamed_inventor_longitude"
#> [11] "patent_num_cited_by_us_patents"      
#> [12] "patent_num_combined_citations"       
#> [13] "patent_processing_time"              
#> [14] "patent_type"                         
#> [15] "patent_firstnamed_assignee_id"       
#> [16] "patent_firstnamed_assignee_city"     
#> [17] "patent_firstnamed_assignee_state"    
#> [18] "patent_firstnamed_assignee_latitude" 
#> [19] "patent_firstnamed_assignee_longitude"
#> [20] "assignee_organization"               
#> [21] "assignee_type"                       
#> [22] "assignee_total_num_patents"          
#> [23] "assignee_key_id"                     
#> [24] "app_date"                            
#> [25] "app_id"                              
#> [26] "cpcs"                                
#> [27] "inv_city_state"

# where are unicycle patent applications concentrated?
b62k %>% 
  group_by(inv_city_state) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  ungroup() %>%
  mutate(pct=n/sum(n)*100,
         cumulative_pct=cumsum(pct)) %>%
  top_n(10,n) %>% kable()
```

| inv\_city\_state |  n |      pct | cumulative\_pct |
| :--------------- | -: | -------: | --------------: |
| Bedford, NH      | 70 | 3.796095 |        3.796095 |
| Los Gatos, CA    | 54 | 2.928416 |        6.724512 |
| Santa Cruz, CA   | 46 | 2.494577 |        9.219089 |
| Morgan Hill, CA  | 45 | 2.440347 |       11.659436 |
| Chicago, IL      | 43 | 2.331887 |       13.991323 |
| Roseau, MN       | 33 | 1.789588 |       15.780911 |
| Aptos, CA        | 30 | 1.626898 |       17.407809 |
| Capitola, CA     | 30 | 1.626898 |       19.034707 |
| Portland, OR     | 27 | 1.464208 |       20.498915 |
| Madison, WI      | 26 | 1.409978 |       21.908894 |
