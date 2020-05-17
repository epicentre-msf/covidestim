#' Get age-sex specific probabilities estimated by Salje et al. 2020
#'
#' @param age_distr age distribution data-frame
#' @param p_type type of probablity to extract: p_hosp_inf = P(Hosp|Infection), etc
#' @param p_stat quantile of the original estimates used to compute probability
#' @param p_sex get estimates by sex or for total population
#'
#' @author Anton Camacho
#'
#' @examples
#' # overall propability of hospitalization given infection for France
#' age_dist_fr <- get_age_pop(iso = "FRA", format = "long")
#' get_p_Salje(age_dist_fr, p_type = "p_hosp_inf", p_stat = "mean", p_sex = "total")
#'
#' @export get_p_Salje
get_p_Salje <- function(age_distr,
                        p_type = c("p_hosp_inf", "p_icu_hosp", "p_dead_hosp", "p_dead_inf"),
                        p_stat = c("mean", "low_95", "up_95"),
                        p_sex = c("total", "male", "female")) {

  p_type <- match.arg(p_type)
  p_stat <- match.arg(p_stat)

  # for testing purposes only
  if (FALSE) {
    age_distr <- get_age_pop(iso = "FRA", format = "long")
    p_type <- "p_dead_hosp"
    p_stat <- "mean"
    p_sex <- "total"
  }

  # get estimates from Salje for given sex and statistic
  est_salje <- get_est_salje(sex = p_sex, stat = p_stat)

  # aggrate population age-classes to match estimate age-classes
  age_distr_agg <- aggregate_ages(age_distr, target = est_salje$age_group)

  # bind estimates to population data by age class
  est_full <- merge(est_salje, age_distr_agg, all.x = TRUE)

  # calculate overall population probability
  p <- sum(est_full[["population"]] * est_full[[p_type]]) / sum(est_full[["population"]])

  # return
  return(p)
}
