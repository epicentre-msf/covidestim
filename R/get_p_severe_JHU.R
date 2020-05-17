#' Get population-wide distribution of severe outcomes
#'
#' This is set up to use population estimates from the World Populaiton
#' Prospects data, and age-specific probabilities of outcome severity from
#' Shenzhen
#'
#' @param iso iso_a3 of country of interest
#' @param outcome Outcome severity ("severe", "moderate", or "mild")
#'
#' @examples
#' # expected population distribution of moderate outcomes for Canada
#' get_p_severe_JHU(iso = "CAN", outcome = "moderate")
#'
#' @importFrom fitdistrplus fitdist
#' @importFrom stats quantile coef
#' @export get_p_severe_JHU
get_p_severe_JHU <- function(iso = "CHN", outcome = c("severe", "moderate", "mild")) {

  outcome <- match.arg(outcome)

  # for testing purposes only
  if (FALSE) {
    iso <- "CHN"
    outcome <- "severe"
  }

  # Load Pr(outcome|age) for Shenzhen
  # rows are samples and columns age categories
  prob <- get_posterior_shenzhen(outcome)

  # get age dist for relevant country
  age_distr <- get_age_pop(iso, format = "long")

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

