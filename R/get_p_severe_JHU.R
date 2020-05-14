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

  # iso <- "CHN"
  # outcome <- "severe"

  outcome <- match.arg(outcome)

  # Load prob(outcome | age) from shenzhen
  # each col contains samples for an age category
  prob <- get_posterior_shenzhen(outcome)

  # population by age
  nage_ <- get_age_pop(iso) * 1000
  nage_[8] <- sum(nage_[8:11])     # merge >=70 years into 1 category
  nage_ <- nage_[1:8]              # discard >= 80
  pr_age10_ <- as.numeric(nage_ / sum(nage_))  # proportion of pop in each 10-yr age category

  # get posterior samples of pr_outcome for total population (i.e. weighted by
  # proportion in each age category)
  p_outcome_ <- as.numeric(as.matrix(prob) %*% pr_age10_)

  fit_ <- fitdistrplus::fitdist(p_outcome_, "gamma", "mle")

  out <- list(ests = p_outcome_,
              mean = mean(p_outcome_),
              ll = quantile(p_outcome_, .025),
              ul = quantile(p_outcome_, .975),
              q25 = quantile(p_outcome_, .25),
              q75 = quantile(p_outcome_, .75),
              shape = coef(fit_)["shape"],
              rate = coef(fit_)["rate"])

  return(out)
}

