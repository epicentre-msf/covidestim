#' Estimate Covid2019 outcome probabilities for a population given its age
#' distribution, and age-severity estimates from Brazeau al. (2020)
#'
#' @description
#' Estimate Covid19 outcome probabilities (death|infection), using
#' age-severity estimates from Brazeau al. (2020), and the population age
#' distribution for a given country, either taken from the UN World Population
#' Prospects 2019 (WPP2019) or directly supplied by the user.
#'
#' @param x Either an ISO3 country code used to extract age-specific population
#'   estimates from the UN World Population Prospects 2019 dataset, \emph{or}, a
#'   data.frame containing age categories in the first column and population
#'   counts (or proportions) in the second column
#' @param p_type Outcome to estimate ("p_dead_inf" (default) or "p_dead_inf_serorev")
#' @param p_stat Statistic of the severity estimates to use (either "mean",
#'   "low_95", or "up_95")
#'
#' @return
#' Estimated outcome probability (scalar)
#'
#' @author Anton Camacho
#' @author Patrick Barks <patrick.barks@@epicentre.msf.org>
#' @author Flavio Finger <flavio.finger@@epicentre.msf.org>
#'
#' @source
#' Report  34: COVID-19   Infection   Fatality   Ratio:   Estimates   from Seroprevalence.
#' Nicholas F Brazeau, Robert  Verity,  Sara Jenks, Han Fu, Charles  Whittaker, Peter Winskill,
#' Ilaria Dorigatti, Patrick Walker, Steven Riley, Ricardo P Schnekenberg, Henrique Hoeltgebaum,
#' Thomas A  Mellan,  Swapnil  Mishra,  H  Juliette  T  Unwin,  Oliver  J  Watson,
#' Zulma  M  Cucunubá,  Marc Baguelin, Lilith Whittles, Samir Bhatt,
#' Azra C Ghani, Neil M Ferguson, Lucy C Okell.
#' \url{https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis/covid-19/report-34-ifr/}
#' 
#' @examples
#' # mean Pr(death|infection) for Canada (ISO3 code "CAN"), taking age
#' # distribution from WPP2019
#' get_p_Brazeau(x = "CAN", p_stat = "mean")
#'
#' # use custom age-distribution
#' age_df <- data.frame(
#'   age = c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49",
#'              "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89", "90+"),
#'   pop = c(1023, 1720, 2422, 3456, 3866, 4104, 4003, 3576, 1210, 1023,
#'            1720, 2422, 3456, 3866, 4104, 4003, 3576, 1576, 854),
#'   stringsAsFactors = FALSE
#' )
#'
#' get_p_Brazeau(x = age_df, p_type = "p_dead_inf", p_stat = "mean")
#'
#' @export get_p_Brazeau
get_p_Brazeau <- function(x,
                        p_type = c("p_dead_inf", "p_dead_inf_serorev"),
                        p_stat = c("mean", "low_95", "up_95")) {

  p_type <- match.arg(p_type)
  p_stat <- match.arg(p_stat)

  # for testing purposes only
  if (FALSE) {
    x <- "FRA"
    p_type <- "p_dead_inf"
    p_stat <- "mean"
  }

  # get estimates from Salje for given sex and statistic
  est_brazeau <- get_est_brazeau(stat = p_stat, type = p_type)

  # prepare age distribution
  age_distr <- prep_age_distib(x, interval = "5yr")

  # aggrate population age-classes to match estimate age-classes
  age_distr_agg <- aggregate_ages(age_distr, target = est_brazeau$age_group)

  # bind estimates to population data by age class
  est_full <- merge(est_brazeau, age_distr_agg, all.x = TRUE)

  # return overall population probability
  out <- sum(est_full[["pop"]] * est_full[[p_type]]) / sum(est_full[["pop"]])
  return(out)
}
