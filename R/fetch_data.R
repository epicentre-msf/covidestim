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


#' Get estimates from van Zandvoort
#'
#' @export get_est_vanzandvoort
get_est_vanzandvoort <- function() {
  fetch_data("vanzandvoort")
}


#' Get estimates from Salje
#'
#' @param sex Optional sex to subset to (either "female", "male", or "total").
#'   Defaults to `NULL`, in which case all categories are returned.
#' @param stat Optional statistic to subset to (either "mean", "low_95", or
#'   "up_95"). Defaults to `NULL`, in which case all cagegories are returned.
#'
#' @export get_est_salje
get_est_salje <- function(sex = NULL, stat = NULL) {
  dat <- fetch_data("salje")
  if (!is.null(sex)) dat <- dat[dat$sex == sex,]
  if (!is.null(stat)) dat <- dat[dat$stat == stat,]
  return(dat)
}


#' Get estimates from Davies
#'
#' @param stat Optional statistic to subset to (either "mean", "median",
#'   "low_50", "up_50", "low_95", or "up_95"). Defaults to `NULL`, in which case
#'   all statistics are returned.
#'
#' @export get_est_davies
get_est_davies <- function(stat = NULL) {
  dat <- fetch_data("davies")
  if (!is.null(stat)) dat <- dat[dat$stat == stat,]
  return(dat)
}


#' Get estimates from Neher
#'
#' @export get_est_neher
get_est_neher <- function() {
  fetch_data("neher")
}
