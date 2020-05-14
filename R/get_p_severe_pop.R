#' Estimate proportion of severe cases adjusted for population structure
#'
#' @param pr_age10 proportion of population in 10 year age bins
#'
#' @examples
#' # population age-distribution for France
#' pop_age_dist_france <- get_age_pop("FRA")
#'
#' # expected distribution of severe cases for France
#' get_p_severe_pop(pop_age_dist_france)
#'
#' @importFrom stats quantile coef
#' @importFrom fitdistrplus fitdist
#' @export get_p_severe_pop
get_p_severe_pop <- function(pr_age10) {

  # Load prob(severe | age) from Shenzhen
  prob <- fetch_data("shenzhen_prob_severe")

  # sum all proportion of age old than 70
  pr_age10[8] <- sum(pr_age10[8:length(pr_age10)])

  p_severe_ <- rowSums(
    t(apply(prob, 1, function(x, pr) x * pr, pr = as.numeric(pr_age10)))
  )

  fit_ <- fitdistrplus::fitdist(p_severe_, "gamma", "mle")

  p_severe_ <- list(ests = p_severe_,
                    mean = mean(p_severe_),
                    ll = quantile(p_severe_, .025),
                    ul = quantile(p_severe_, .975),
                    q25 = quantile(p_severe_, .25),
                    q75 = quantile(p_severe_, .75),
                    shape = coef(fit_)["shape"],
                    rate = coef(fit_)["rate"])

  return(p_severe_)
}
