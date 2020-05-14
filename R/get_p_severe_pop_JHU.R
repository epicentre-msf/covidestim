#' Estimate proportion of severe cases adjusted for population structure
#'
#' @param age_distr age distribution data-frame
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
get_p_severe_pop_JHU <- function(age_distr) {

  # age_distr <- get_age_pop("FRA", format = "long")

  # Load prob(severe | age) from Shenzhen
  prob <- fetch_data("shenzhen_prob_severe")

  # sum all proportion of age old than 70
  nage_ <- age_distr$population * 1000
  names(nage_) <- age_distr$age_class
  nage_[8] <- sum(nage_[8:11])          # merge >=70 years into 1 category
  nage_ <- nage_[1:8]                   # discard >= 80
  pr_age10_ <- nage_ / sum(nage_)       # proportion

  p_severe_ <- as.numeric(as.matrix(prob) %*% pr_age10_)

  fit_ <- fitdistrplus::fitdist(p_severe_, "gamma", "mle")

  out <- list(ests = p_severe_,
              mean = mean(p_severe_),
              ll = quantile(p_severe_, .025),
              ul = quantile(p_severe_, .975),
              q25 = quantile(p_severe_, .25),
              q75 = quantile(p_severe_, .75),
              shape = coef(fit_)["shape"],
              rate = coef(fit_)["rate"])

  return(out)
}
