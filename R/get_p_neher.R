#' Get age-adjusted probability of severe, ICU and death by country (giving ISO A3 code) according
#' to the assumptions taken by the Neher lab model
#'
#' @param age_distr age distribution data-frame
#' @param p_type type of probablity to extract: p_hosp_inf = P(Hosp|Infection), etc
#'
#' @examples
#' # overall propability of hospitalization given infection for France
#' age_dist_fr <- get_age_pop(iso = "FRA", format = "long")
#' get_p_neher(age_dist_fr, p_type = "p_hosp_inf")
#
#' @author Flavio Finger
#'
#' @import dplyr
#' @export get_p_neher
get_p_neher <- function(age_distr,
                        p_type = c("p_hosp_inf", "p_icu_hosp", "p_dead_hosp", "p_dead_inf")) {

  # age_distr <- get_age_pop(iso = "FRA", format = "long")
  # p_type <- "p_hosp_inf"

  p_type <- match.arg(p_type)

  #  population by age
  nage_ <- age_distr$population * 1000
  names(nage_) <- age_distr$age_class
  nage_[9] <- sum(nage_[9:11])       # merge >=80 years into 1 category
  nage_ <- nage_[1:9]                # discard >= 90
  pr_age10 <- nage_ / sum(nage_)     # proportion

  df_severity <- get_est_neher()

  prob <- df_severity[[p_type]]

  p <- sum(as.vector(pr_age10) * prob)

  return(p)
}

