#' Utility to fetch package data
#'
#' @param dataset Name of dataset to load
#'
#' @importFrom utils data
#' @noRd
fetch_data <- function(dataset) {
  env <- new.env()
  x <- data(list = dataset, envir = env)[1]
  return(env[[x]])
}


#' Get WPP population and age data
#'
#' @export get_pop_data
get_pop_data <- function() {
  fetch_data("wpp_pop")
}


#' Get posterior samples of prob(outcome | age) for Shenzhen
#'
#' @param outcome Outcome severity ("severe", "moderate", or "mild")
#'
#' @export get_posterior_shenzhen
get_posterior_shenzhen <- function(outcome = c("severe", "moderate", "mild")) {
  outcome <- match.arg(outcome)
  fetch_data(paste0("shenzhen_prob_", outcome))
}


#' Get estimates from Vanzand
#'
#' @export get_est_vanzand
get_est_vanzand <- function() {
  fetch_data("vanzand")
}


#' Get estimates from Salje
#'
#' @export get_est_salje
get_est_salje <- function() {
  fetch_data("salje")
}


#' Get estimates from Davies
#'
#' @export get_est_davies
get_est_davies <- function() {
  fetch_data("davies")
}


#' Get estimates from Neher
#'
#' @export get_est_neher
get_est_neher <- function() {
  fetch_data("neher")
}
