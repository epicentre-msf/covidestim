#' Estimate Covid2019 outcome probabilities for a population given its age
#' distribution, and age-severity estimates from O'Driscoll al. (2020)
#'
#' @description
#' Estimate Covid19 outcome probabilities (death|infection), using
#' age-severity estimates from O'Driscoll al. (2020), and the population age
#' distribution for a given country, either taken from the UN World Population
#' Prospects 2019 (WPP2019) or directly supplied by the user.
#'
#' @param x Either an ISO3 country code used to extract age-specific population
#'   estimates from the UN World Population Prospects 2019 dataset, \emph{or}, a
#'   data.frame containing age categories in the first column and population
#'   counts (or proportions) in the second column
#' @param p_type Outcome to estimate ("p_dead_inf" is the only option here)
#' @param p_stat Statistic of the severity estimates to use (either "mean",
#'   "low_95", or "up_95")
#' @param p_sex Use severity estimate for which sex (either "female", "male", or
#'   "total")
#'
#' @return
#' Estimated outcome probability (scalar)
#'
#' @author Anton Camacho
#' @author Patrick Barks <patrick.barks@@epicentre.msf.org>
#' @author Flavio Finger <flavio.finger@@epicentre.msf.org>
#'
#' @source
#' O’Driscoll, M., Dos Santos, G.R., Wang, L. et al.
#' Age-specific mortality and immunity patterns of
#' SARS-CoV-2. Nature (2020).
#' \url{https://doi.org/10.1038/s41586-020-2918-0}
#' 
#' @examples
#' # mean Pr(death|infection) for Canada (ISO3 code "CAN"), taking age
#' # distribution from WPP2019
#' get_p_ODriscoll(x = "CAN", p_stat = "mean", p_sex = "total")
#'
#' # use custom age-distribution
#' age_df <- data.frame(
#'   age = c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49",
#'              "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80+"),
#'   pop = c(1023, 1720, 2422, 3456, 3866, 4104, 4003, 3576, 1210, 1023,
#'            1720, 2422, 3456, 3866, 4104, 4003, 3576),
#'   stringsAsFactors = FALSE
#' )
#'
#' get_p_ODriscoll(x = age_df, p_type = "p_dead_inf", p_stat = "mean", p_sex = "total")
#'
#' @export get_p_ODriscoll
get_p_ODriscoll <- function(x,
                        p_type = c("p_dead_inf"),
                        p_stat = c("mean", "low_95", "up_95"),
                        p_sex = c("total", "male", "female")) {

  p_type <- match.arg(p_type)
  p_stat <- match.arg(p_stat)
  p_sex <- match.arg(p_sex)

  # for testing purposes only
  if (FALSE) {
    x <- "FRA"
    p_type <- "p_dead_inf"
    p_stat <- "mean"
    p_sex <- "total"
  }

  # get estimates from Salje for given sex and statistic
  est_odriscoll <- get_est_odriscoll(sex = p_sex, stat = p_stat)

  # prepare age distribution
  age_distr <- prep_age_distib(x, interval = "5yr")

  # aggrate population age-classes to match estimate age-classes
  age_distr_agg <- aggregate_ages(age_distr, target = est_odriscoll$age_group)

  # bind estimates to population data by age class
  est_full <- merge(est_odriscoll, age_distr_agg, all.x = TRUE)

  # return overall population probability
  out <- sum(est_full[["pop"]] * est_full[[p_type]]) / sum(est_full[["pop"]])
  return(out)
}
