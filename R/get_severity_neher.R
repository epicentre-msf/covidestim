#' Get age severity data from Neher lab
#'
#' @description
#' assumptions used by the Neher lab: https://neherlab.org/covid19/
#' accessed on 2020-04-02
#' "This table summarizes the assumptions on severity which are informed
#' by epidemiological and clinical observations in China. The first column
#' reflects our assumption on what fraction of infections are reflected
#' in the statistics from China, the following columns contain the
#' assumption on what fraction of the previous category deteriorates
#' to the next. These fields are editable and can be adjusted to different
#' assumptions. The last column is the implied infection fatality for
#' different age groups."
#'
#' @author Flavio Finger
#'
#' @importFrom tibble tribble
#' @import dplyr
#' @export get_severity_neher
get_severity_neher <- function() {

  severity_neher <- tribble(
    ~age, ~confirmed, ~severe, ~critical, ~fatal,
    "0-9",    5,  1,  5, 30,
    "10-19",  5,  3, 10, 30,
    "20-29", 10,  3, 10, 30,
    "30-39", 15,  3, 15, 30,
    "40-49", 20,  6, 20, 30,
    "50-59", 25, 10, 25, 40,
    "60-69", 30, 25, 35, 40,
    "70-79", 40, 35, 45, 50,
    "80+",   50, 50, 55, 50
  ) %>%
    mutate_at(vars(-age), function(x) x/100) %>%
    mutate(p_hosp_inf = confirmed * severe,
           p_icu_hosp = critical,
           p_dead_hosp = critical * fatal,
           p_dead_inf = p_dead_hosp * p_hosp_inf)

  return(severity_neher)
}
