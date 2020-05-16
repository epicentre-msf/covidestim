#' Run Stan model to return posterior probability of case severity by age based
#' on Shenzen results
#'
#' @description
#' Estimates probability of being a severe case by age from Shenzen data
#' results from this STAN model.
#'
#' Data in Qifang et al. 2020
#' https://www.medrxiv.org/content/10.1101/2020.03.03.20028423v3.full.pdf
#'
#' Adapted from https://github.com/HopkinsIDD/COVID19_refugees/
#'
#' @param outcome Outcome severity ("severe", "moderate", or "mild")
#'
#' @import dplyr
#' @importFrom rstanarm student_t stan_glm posterior_predict
#' @importFrom stats binomial
#' @export get_severe_age_shenzhen
get_severe_age_shenzhen <- function(outcome = list("severe", "moderate", "mild")) {

  # Functions in this repo are adapted from
  # FROM https://github.com/HopkinsIDD/COVID19_refugees/
  # now https://github.com/HopkinsIDD/covidSeverity

  outcome <- match.arg(outcome)

  sym_dat <- data.frame(
    age_cat=c("0-9","10-19","20-29","30-39","40-49","50-59","60-69","70+"),
    mild=c(7,3,13,22,15,21,17,4),
    moderate=c(13,9,21,64,40,46,49,12),
    severe=c(0,0,0,1,5,7,20,2)
  )

  fev_dat <- data.frame(
    age_cat=c("0-9","10-19","20-29","30-39","40-49","50-59","60-69","70+"),
    no=c(6,3,3,13,6,10,16,4),
    yes=c(14,9,31,74,54,64,70,14)
  )


  dat <- full_join(sym_dat, fev_dat) %>%
    as.data.frame() %>%
    mutate(tot = yes + no,
           include = case_when(outcome == "severe" ~ severe,
                               outcome == "moderate" ~ moderate,
                               outcome == "mild" ~ mild),
           exclude = tot-include
    )

  # Use stan
  t_prior <- rstanarm::student_t(df = 7,
                                 location = 0,
                                 scale = 2.5,
                                 autoscale = FALSE)

  fit1 <- rstanarm::stan_glm(cbind(include, exclude) ~ age_cat,
                             data = dat,
                             family = binomial(link = "logit"),
                             prior = t_prior,
                             prior_intercept = t_prior,
                             cores = 2,
                             seed = 12345)

  PPD <- rstanarm::posterior_predict(fit1)
  prob <- PPD

  for (i in 1:nrow(PPD)) {
    prob[i,] <- PPD[i,] / dat$tot
  }

  # # each col contains samples for one age category
  # outfile <- paste0("data/", outcome, "_age_prob.csv")
  # write.csv(as.data.frame(prob), outfile, row.names = FALSE)

  return(prob)
}

