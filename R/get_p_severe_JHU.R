#' Estimate probability distribution of mild/moderate/severe Covid19 outcomes
#' for a population given its age distribution, and age-severity estimates used
#' by JHU
#'
#' Based on age-specific outcome severity data from Shenzhen, China (Bi et al.
#' 2020). Population age distributions can either be taken from the UN World
#' Population Prospects 2019 (WPP2019), or directly supplied by the user.
#'
#' @param x Either an ISO3 country code used to extract age-specific population
#'   estimates from the UN World Population Prospects 2019 dataset, \emph{or}, a
#'   data.frame containing age categories in the first column and population
#'   counts (or proportions) in the second column
#' @param outcome Outcome category ("severe", "moderate", or "mild")
#' @param return_draws Logical indicating whether to include vector of draws
#'   from the posterior distribution of outcome probabilities in the returned
#'   list. Defaults to `FALSE`.
#'
#' @return A list with 8 elements relating to the posterior distribution of
#' outcome probabilities for the population of interest, taken over all age
#' classes: \item{ests}{vector of 2000 draws from posterior distribution}
#' \item{mean}{mean of posterior distribution} \item{ll}{lower 95\% CI of
#' posterior distribution} \item{ul}{upper 95\% CI of posterior distribution}
#' \item{q25}{lower 50\% CI of posterior distribution} \item{q75}{upper 50\% CI
#' of posterior distribution} \item{shape}{shape parameter of gamma distribution
#' fit to posterior distribution} \item{rate}{rate parameter of gamma
#' distribution fit to posterior distribution}
#'
#' @author Patrick Barks <patrick.barks@@epicentre.msf.org>
#'
#' @source
#' Bi, Q., Wu, Y., Mei, S., Ye, C., Zou, X., Zhang, Z., Liu, X., Wei, L.,
#' Truelove, S., Zhang, T., Gao, W., Cheng, C., Tang, X., ..., and Feng, .T.
#' (2020) Epidemiology and Transmission of COVID-19 in Shenzhen China: Analysis
#' of 391 cases and 1,286 of their close contacts. medRxiv preprint.
#' \url{https://doi.org/10.1101/2020.03.03.20028423}
#'
#' @examples
#' # expected population distribution of severe outcomes for Canada (ISO3 code
#' # "CAN"), taking age distribution from WPP2019
#' get_p_severe_JHU(x = "CAN", outcome = "severe")
#'
#' # use custom age-distribution
#' age_df <- data.frame(
#'   age = c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70+"),
#'   pop = c(1023, 1720, 2422, 3456, 3866, 4104, 4003, 3576),
#'   stringsAsFactors = FALSE
#' )
#'
#' get_p_severe_JHU(x = age_df, outcome = "severe")
#'
#' @importFrom fitdistrplus fitdist
#' @importFrom stats quantile coef
#' @export get_p_severe_JHU
get_p_severe_JHU <- function(x,
                             outcome = c("severe", "moderate", "mild"),
                             return_draws = FALSE) {

  outcome <- match.arg(outcome)

  # for testing purposes only
  if (FALSE) {
    x <- "CHN"; outcome <- "severe"; return_draws = FALSE
  }

  # prepare age distribution
  age_distr <- prep_age_distib(x)

  # Load Pr(outcome|age) for Shenzhen
  # rows are samples and columns are age categories
  prob <- get_posterior_shenzhen(outcome)

  # aggrate population age-classes to match estimate age-classes
  age_distr_agg <- aggregate_ages(age_distr, target = names(prob))

  # proportional age structure
  prop_age_pop <- age_distr_agg[["pop"]] / sum(age_distr_agg[["pop"]])

  # get posterior samples of pr_outcome for total population (i.e. weighted by
  # proportion in each age category)
  p_outcome <- as.numeric(as.matrix(prob) %*% prop_age_pop)

  # fit model and return
  fit <- fitdistrplus::fitdist(p_outcome, "gamma", "mle")

  # arrange output and return
  out <- list(mean = mean(p_outcome),
              ll = quantile(p_outcome, 0.025),
              ul = quantile(p_outcome, 0.975),
              q25 = quantile(p_outcome, 0.25),
              q75 = quantile(p_outcome, 0.75),
              shape = coef(fit)["shape"],
              rate = coef(fit)["rate"])

  if (return_draws) out <- c(out, list(ests = p_outcome))

  return(out)
}
