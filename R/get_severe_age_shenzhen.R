#' Run model to return posterior probability of case severity by age based on
#' Shenzen results
#'
#' @description
#' Estimates probability of being a severe case by age from Shenzen data.
#'
#' Data in Qifang et al. 2020
#' https://www.medrxiv.org/content/10.1101/2020.03.03.20028423v3.full.pdf
#'
#' Adapted from https://github.com/HopkinsIDD/COVID19_refugees/
#' Now https://github.com/HopkinsIDD/covidSeverity ?
#'
#' @param outcome Outcome severity ("severe", "moderate", or "mild")
#'
#' @export get_severe_age_shenzhen
get_severe_age_shenzhen <- function(outcome = list("severe", "moderate", "mild")) {

  outcome <- match.arg(outcome)

  # for testing purposes only
  if (FALSE) {
    outcome <- "severe"
  }

  # get Shenzen outcome severity counts
  dat <- fetch_data("bi")

  # generate samples from posterior distribution for given outcome type
  mapply(sample_binomial_posterior,
         k = dat[[outcome]],
         n = dat$total,
         nsamples = 4000)
}


#' @noRd
#' @importFrom stats rbeta
sample_binomial_posterior <- function(k, n, nsamples) {
  rbeta(nsamples, 1+k, 1+(n-k))
}

