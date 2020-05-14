#' Get the age-adjusted proportion severe by country (giving ISO A3 code)
#' according to the assumptions taken by the Neher lab model
#'
#' @author Flavio Finger
#'
#' @param iso iso_a3 of country of interest (defaults to China, "CHN")
#'
#' @examples
#' get_p_severe_neher(iso = "USA")
#'
#' @export get_p_severe_neher
get_p_severe_neher <- function(iso = "CHN") {

  # population by age
  nage_ <- get_age_pop(iso) * 1000
  nage_[9] <- sum(nage_[9:11])    # merge >=80 years into 1 category
  nage_ <- nage_[1:9]             # discard >=90
  pr_age10 <- nage_ / sum(nage_)  # proportion

  prob <- get_severity_neher()$severe_of_tot

  p_severe <- sum(as.vector(pr_age10) * prob)

  return(p_severe)
}
