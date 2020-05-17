#' Get age-adjusted probability of severe, ICU and death by country (giving ISO
#' A3 code) according to the assumptions taken by the Neher lab model
#'
#' @param age_distr age distribution data-frame
#' @param p_type type of probablity to extract: p_hosp_inf = P(Hosp|Infection), etc
#'
#' @examples
#' # overall propability of hospitalization given infection for France
#' age_dist_fr <- get_age_pop(iso = "FRA", format = "long")
#' get_p_Neher(age_dist_fr, p_type = "p_hosp_inf")
#
#' @author Flavio Finger
#'
#' @export get_p_Neher
get_p_Neher <- function(age_distr,
                        p_type = c("p_hosp_inf", "p_icu_hosp", "p_dead_hosp", "p_dead_inf")) {

  p_type <- match.arg(p_type)

  # for testing purposes only
  if (FALSE) {
    age_distr <- get_age_pop(iso = "FRA", format = "long")
    p_type <- "p_hosp_inf"
  }

  # get estimates from Neher
  est_neher <- get_est_neher()

  # aggrate population age-classes to match estimate age-classes
  age_distr_agg <- aggregate_ages(age_distr, target = est_neher$age_group)

  # bind estimates to population data by age class
  est_full <- merge(est_neher, age_distr_agg, by = "age_group", all.x = TRUE)

  # calculate overall population probability
  p <- sum(est_full[["population"]] * est_full[[p_type]]) / sum(est_full[["population"]])

  # return
  return(p)
}

