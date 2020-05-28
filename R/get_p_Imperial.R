#' Estimate Covid2019 outcome probabilities for a population given its age
#' distribution, and age-severity estimates from MRC-IDE at Imperial College
#'
#' @description
#' Estimate Covid19 outcome probabilities including hospitalizion|infection,
#' ICU|hospitalization, death|ICU, death|non-ICU, and death|infection, using
#' age-severity estimates from MRC-IDE at Imperial College, and the population
#' age distribution for a given country, either taken from the UN World
#' Population Prospects 2019 (WPP2019) or directly supplied by the user.
#'
#' @param x Either an ISO3 country code used to extract age-specific population
#'   estimates from the UN World Population Prospects 2019 dataset, \emph{or}, a
#'   data.frame containing age categories in the first column and population
#'   counts (or proportions) in the second column. To match the severity
#'   estimates, age groups must match or be aggregatable to 5-year intervals
#'   (0-4, 5-9, ...).
#' @param p_type Outcome to estimate (either "p_hosp_inf", "p_icu_hosp",
#'   "p_dead_icu", "p_dead_nonicu", or "p_dead_inf")
#'
#' @return
#' Estimated outcome probability (scalar)
#'
#' @author Patrick Barks <patrick.barks@@epicentre.msf.org>
#'
#' @source \url{https://mrc-ide.github.io/global-lmic-reports/parameters.html}
#'
#' @examples
#' # mean Pr(hospitalization|infection) for Canada (ISO3 code "CAN"), taking age
#' # distribution from WPP2019
#' get_p_Imperial(x = "CAN", p_type = "p_hosp_inf")
#'
#' @export get_p_Imperial
get_p_Imperial <- function(x,
                           p_type = c("p_hosp_inf",
                                      "p_icu_hosp",
                                      "p_dead_icu",
                                      "p_dead_nonicu",
                                      "p_dead_inf")) {

  p_type <- match.arg(p_type)

  # for testing purposes only
  if (FALSE) {
    x <- "FRA"
    p_type <- "p_hosp_inf"
  }

  # get estimates from Imperial
  est_imperial <- get_est_imperial()

  # prepare age distribution
  age_distr <- prep_age_distib(x, interval = "5yr")

  # aggrate population age-classes to match estimate age-classes
  age_distr_agg <- aggregate_ages(age_distr, target = est_imperial$age_group)

  # bind estimates to population data by age class
  est_full <- merge(est_imperial, age_distr_agg, by = "age_group", all.x = TRUE)

  # return overall population probability
  return(sum(est_full[["pop"]] * est_full[[p_type]]) / sum(est_full[["pop"]]))
}

