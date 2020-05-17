#' Estimate proportion of severe cases adjusted for population structure
#'
#' @param age_distr age distribution data-frame
#' @param outcome Outcome severity ("severe", "moderate", or "mild")
#'
#' @examples
#' # population age-distribution for France
#' pop_age_dist_france <- get_age_pop("FRA", format = "long")
#'
#' # expected distribution of severe cases for France
#' get_p_severe_pop_JHU(pop_age_dist_france)
#'
#' @importFrom stats quantile coef
#' @importFrom fitdistrplus fitdist
#' @export get_p_severe_pop_JHU
get_p_severe_pop_JHU <- function(age_distr, outcome = "severe") {

  # for testing purposes only
  if (FALSE) {
    age_distr <- get_age_pop("FRA", format = "long")
    outcome <- "severe"
  }

  # Load Pr(outcome|age) for Shenzhen
  # rows are samples and columns age categories
  prob <- get_posterior_shenzhen(outcome)

  # aggrate population age-classes to match estimate age-classes
  age_distr_agg <- aggregate_ages(age_distr, target = names(prob))

  # proportional age structure
  prop_age_pop <- age_distr_agg$population / sum(age_distr_agg$population)

  # get posterior samples of pr_outcome for total population (i.e. weighted by
  # proportion in each age category)
  p_outcome <- as.numeric(as.matrix(prob) %*% prop_age_pop)

  # fit model and return
  fit <- fitdistrplus::fitdist(p_outcome, "gamma", "mle")

  return(list(ests = p_outcome,
              mean = mean(p_outcome),
              ll = quantile(p_outcome, 0.025),
              ul = quantile(p_outcome, 0.975),
              q25 = quantile(p_outcome, 0.25),
              q75 = quantile(p_outcome, 0.75),
              shape = coef(fit)["shape"],
              rate = coef(fit)["rate"]))
}
