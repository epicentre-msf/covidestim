#' Get the proprtion severe by age ditstr according to JHU assumptions
#'
#' @param age_distr age distribution data-frame
#' @param p probability passed to quantile function
#'
#' @author Flavio Finger
#'
#' @examples
#' # population age-distribution for France
#' pop_age_dist_france <- get_age_pop("FRA", format = "long")
#'
#' # expected distribution of severe cases for France
#' get_p_severe_JHU_model(pop_age_dist_france, p = 0.5)
#'
#' @importFrom stats quantile
#' @export get_p_severe_JHU_model
get_p_severe_JHU_model <- function(age_distr, p) {
  p_sev <- get_p_severe_pop_JHU(age_distr, outcome = "severe")
  p_hosp <- quantile(unlist(p_sev$ests), probs = p)
  return(p_hosp)
}
