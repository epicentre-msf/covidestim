#' Get age-sex specific probabilities estimated by Salje et al. 2020
#'
#' @param x Either an ISO3 country code used to extract age-specific population
#'   estimates from the UN World Population Prospects 2019 dataset, \emph{or}, a
#'   data.frame containing age categories in the first column and population
#'   counts (or proportions) in the second column
#' @param p_type type of probablity to extract: p_hosp_inf = P(Hosp|Infection), etc
#' @param p_stat quantile of the original estimates used to compute probability
#' @param p_sex get estimates by sex or for total population
#'
#' @return
#' Probability (scalar)
#'
#' @author Anton Camacho
#'
#' @examples
#' # mean Pr(hospitalization|infection) for Canada (ISO3 code "CAN"), taking age
#' # distribution from WPP2019
#' get_p_Salje(x = "CAN", p_type = "p_hosp_inf", p_stat = "mean", p_sex = "total")
#'
#' # use custom age-distribution
#' age_df <- data.frame(
#'   age = c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+"),
#'   pop = c(1023, 1720, 2422, 3456, 3866, 4104, 4003, 3576, 1210),
#'   stringsAsFactors = FALSE
#' )
#' get_p_Salje(x = age_df, p_type = "p_hosp_inf", p_stat = "mean", p_sex = "total")
#'
#' @export get_p_Salje
get_p_Salje <- function(x,
                        p_type = c("p_hosp_inf", "p_icu_hosp", "p_dead_hosp", "p_dead_inf"),
                        p_stat = c("mean", "low_95", "up_95"),
                        p_sex = c("total", "male", "female")) {

  p_type <- match.arg(p_type)
  p_stat <- match.arg(p_stat)

  # for testing purposes only
  if (FALSE) {
    x <- "FRA"
    p_type <- "p_dead_hosp"
    p_stat <- "mean"
    p_sex <- "total"
  }

  # get estimates from Salje for given sex and statistic
  est_salje <- get_est_salje(sex = p_sex, stat = p_stat)

  # prepare age distribution
  age_distr <- prep_age_distib(x)

  # aggrate population age-classes to match estimate age-classes
  age_distr_agg <- aggregate_ages(age_distr, target = est_salje$age_group)

  # bind estimates to population data by age class
  est_full <- merge(est_salje, age_distr_agg, all.x = TRUE)

  # return overall population probability
  return(sum(est_full[["pop"]] * est_full[[p_type]]) / sum(est_full[["pop"]]))
}
