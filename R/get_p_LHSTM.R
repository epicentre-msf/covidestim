#' Get age specific probabilities estimated by LSHTM (Davies et al. 2020 and Van
#' Zandvoort et al. 2020)
#'
#' @param age_distr age distribution data-frame
#' @param p_type type of probablity to extract: p_hosp_inf = P(Hosp|Infection), etc
#' @param p_stat quantile of the original estimates used to compute probability
#'
#' @author Anton Camacho
#'
#' @examples
#' # overall propability of hospitalization given infection for France
#' age_dist_fr <- get_age_pop(iso = "FRA", format = "long")
#' get_p_LSHTM(age_dist_fr, p_type = "p_hosp_inf", p_stat = "mean")
#'
#' @export get_p_LSHTM
get_p_LSHTM <- function(age_distr,
                        p_type = c("p_hosp_inf", "p_icu_hosp", "p_dead_hosp", "p_dead_inf"),
                        p_stat = c("mean", "median", "low_95", "up_95", "low_50", "up_50")) {

  p_type <- match.arg(p_type)
  p_stat <- match.arg(p_stat)

  ## for testing only
  if (FALSE) {
    age_distr <- get_age_pop(iso = "FRA", format = "long")
    p_type <- "p_dead_inf"
    p_stat <- "mean"
  }

  # use P(Clinical|Infection) from Davies 2020 (with confidence intervals) and
  #  P(Hosp|Clinical) from VanZandvoort 2020 to compute P(Hosp|Infection)
  est_davies <- get_est_davies(stat = p_stat)
  est_vanzan <- get_est_vanzandvoort()

  est_merge <- merge(est_vanzan, est_davies, by.x = "age_group")
  est_merge$p_hosp_inf <- est_merge$p_hosp_clin * est_merge$p_clin_inf
  est_merge$p_dead_inf <- est_merge$p_dead_hosp * est_merge$p_hosp_inf

  # aggrate population age-classes to match estimate age-classes
  age_distr_agg <- aggregate_ages(age_distr, target = est_merge$age_group)

  # bind estimates to population data by age class
  est_full <- merge(est_merge, age_distr_agg, all.x = TRUE)

  # calculate overall population probability
  p <- sum(est_full[["population"]] * est_full[[p_type]]) / sum(est_full[["population"]])

  # return
  return(p)
}

