#' Utility to fetch package data
#'
#' @param dataset Name of dataset to load
#'
#' @importFrom utils data
#' @export fetch_data
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


#' Get WPP location data
#'
#' @export get_wpp_locations
get_wpp_locations <- function() {
  fetch_data("wpp_loc")
}


#' Get posterior samples of prob(outcome | age) for Shenzhen
#'
#' @param outcome Outcome severity ("severe", "moderate", or "mild")
#'
#' @export get_posterior_shenzhen
get_posterior_shenzhen <- function(outcome = c("severe", "moderate", "mild")) {
  outcome <- match.arg(outcome)
  fetch_data(paste0("prob_", outcome))
}

