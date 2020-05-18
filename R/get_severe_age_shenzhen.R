#' Model the probability of Covid19 outcome type (mild, moderate, severe) by age
#' group based on data from Shenzen, China (Bi et al. 2020)
#'
#' Adapted from https://github.com/HopkinsIDD/covidSeverity
#'
#' @param outcome Outcome category ("severe", "moderate", or "mild")
#' @param nsamples Number of samples to draw (defaults to 2000)
#'
#' @return
#' A data.frame with \code{nsamples} rows and 8 columns, corresponding to each
#' age group (`0-9`, `10-19`, ..., `70+`)
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
#' # draws from the posterior distribution of probability of severe outcome
#' post_samples <- get_severe_age_Shenzhen("severe")
#'
#' # posterior median probability of severe outcomes for each age group
#' apply(post_samples, 2, median)
#'
#' @export get_severe_age_Shenzhen
get_severe_age_Shenzhen <- function(outcome = c("severe", "moderate", "mild"),
                                    nsamples = 2000) {

  outcome <- match.arg(outcome)

  # for testing purposes only
  if (FALSE) {
    outcome <- "severe"
  }

  # get Shenzen outcome severity counts
  dat <- fetch_data("bi")

  # generate samples from posterior distribution for given outcome type
  out <- mapply(sample_binomial_posterior,
                k = dat[[outcome]],
                n = dat$total,
                nsamples = nsamples)

  # convert to df and return
  out <- as.data.frame(out)
  names(out) <- dat$age_group

  return(out)
}


#' @noRd
#' @importFrom stats rbeta
sample_binomial_posterior <- function(k, n, nsamples) {
  rbeta(nsamples, 1+k, 1+(n-k))
}

