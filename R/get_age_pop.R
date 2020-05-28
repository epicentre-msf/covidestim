#' Extract age-specific population estimates for a given country from the UN
#' World Population Prospects 2019
#'
#' Extract population estimates in 10-year age intervals for a given country
#' from the UN World Population Prospects 2019 (WPP2019).
#'
#' @param iso ISO3 code for country of interest
#' @param format Return format ("wide" or "long"). Format "wide" yields a
#'   single-row data.frame with age classes as column names, whereas "long"
#'   yields a 2-column data.frame with the first defining age classes and the
#'   second giving corresponding population sizes. Defaults to "wide".
#' @param interval Age interval ("5yr" or "10yr"). The WPP data is originally in
#'   5-year age intervals, but by default we aggregate to 10-year intervals to
#'   match the intervals at which covid severity estimates are usually
#'   available.
#'
#' @return
#' A data.frame. If \code{format = "wide"} returns a single-row data.frame with
#' age classes as column names, whereas if \code{format = "long"} returns a
#' 2-column data.frame with the first defining age classes and the second giving
#' corresponding population sizes.
#'
#' @source \url{https://population.un.org/wpp/Download/Standard/Population/}
#'
#' @examples
#' get_age_pop(iso = "FRA")
#' get_age_pop(iso = "FRA", format = "long", interval = "5yr")
#'
#' @importFrom stats setNames
#' @export get_age_pop
get_age_pop <- function(iso, format = c("wide", "long"), interval = c("10yr", "5yr")) {

  format <- match.arg(format)
  interval <- match.arg(interval)

  # fetch WPP2019 dataset
  dat <- get_pop_data()

  # subset to country and max year, and select only age-population columns
  dat <- dat[dat$iso_a3 %in% iso,]
  dat <- dat[dat$year == max(dat$year, na.rm = TRUE), c("age_group", "pop")]

  # set age-group interval (5 or 10 years)
  if (interval == "10yr") {
    target_intervals <- c(
      "0-9", "10-19", "20-29", "30-39", "40-49", "50-59",
      "60-69", "70-79", "80-89", "90-99", "100+"
    )
    dat <- aggregate_ages(dat, target = target_intervals)
  }

  # strip rownames
  rownames(dat) <- NULL

  # output format
  if (format == "wide") {
    dat <- setNames(dat$pop, dat$age_group)
  }

  return(dat)
}
