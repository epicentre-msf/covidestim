#' Utility to fetch package data
#'
#' @param dataset Name of dataset to load
#'
#' @importFrom utils data
#' @noRd
fetch_data <- function(dataset) {
  env <- new.env()
  x <- data(list = dataset, package = "covidestim", envir = env)[1]
  return(env[[x]])
}


#' Get WPP population and age data
#'
#' @export get_pop_data
get_pop_data <- function() {
  fetch_data("wpp_pop")
}


#' Get posterior samples of Pr(outcome|age_group) based on data from Shenzhen,
#' China in Bi et al. (2020)
#'
#' @param outcome Outcome category ("severe", "moderate", or "mild")
#' @param model Model to use ("Update" or "JHU Original")
#'
#' @export get_posterior_shenzhen
get_posterior_shenzhen <- function(outcome = c("severe", "moderate", "mild"),
                                   model = c("Update", "JHU Original")) {

  outcome <- match.arg(outcome)
  model <- match.arg(model)

  # for testing purposes only
  if (FALSE) {
    outcome <- "severe"; model <- "Update"
  }

  # fetch data and subset to given outcome and type
  d <- fetch_data("shenzhen_samples")
  d <- d[d$outcome == outcome & d$model == model,]

  # split by age group
  dsplit <- split(d, d$age_group)

  # extract posterior samples for each age group and bind into data.frame
  out <- as.data.frame(sapply(dsplit, function(x) x$p))

  return(out)
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


#' Get estimates from O'Driscoll
#'
#' @param sex Optional sex to subset to (either "female", "male", or "total").
#'   Defaults to `NULL`, in which case all categories are returned.
#' @param stat Optional statistic to subset to (either "mean", "low_95", or
#'   "up_95"). Defaults to `NULL`, in which case all cagegories are returned.
#'
#' @export get_est_odriscoll
get_est_odriscoll <- function(sex = NULL, stat = NULL) {
  dat <- fetch_data("odriscoll")
  if (!is.null(sex)) dat <- dat[dat$sex == sex,]
  if (!is.null(stat)) dat <- dat[dat$stat == stat,]
  return(dat)
}


#' Get estimates from Brazeau
#'
#' @param type Optional type to subset to (either "p_dead_inf", "p_dead_inf_serorev").
#'   Defaults to "p_dead_inf".
#' @param stat Optional statistic to subset to (either "mean", "low_95", or
#'   "up_95"). Defaults to `NULL`, in which case all cagegories are returned.
#'
#' @export get_est_brazeau
get_est_brazeau <- function(type = "p_dead_inf", stat = NULL) {
  dat <- fetch_data("brazeau")
  if (!is.null(type)) dat <- dat[dat$type == type,]
  if (!is.null(stat)) dat <- dat[dat$stat == stat,]
  return(dat)
}

#' Get estimates from Levin
#'
#' @param stat Optional statistic to subset to (either "mean", "low_95", or
#'   "up_95"). Defaults to `NULL`, in which case all cagegories are returned.
#'
#' @export get_est_levin
get_est_levin <- function(stat = NULL) {
  dat <- fetch_data("levin")
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


#' Get estimates from Imperial
#'
#' @export get_est_imperial
get_est_imperial <- function() {
  fetch_data("imperial")
}

