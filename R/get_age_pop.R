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
#' get_age_pop(iso = "FRA", format = "long")
#'
#' @export get_age_pop
get_age_pop <- function(iso, format = c("wide", "long")) {

  format <- match.arg(format)

  # fetch WPP2019 dataset
  dat <- get_pop_data()

  # subset to country and max year, and select only age-population columns
  pop_cols <- c("0-9", "10-19",
                "20-29", "30-39",
                "40-49", "50-59",
                "60-69", "70-79",
                "80-89", "90-99",
                "100-109")

  dat <- dat[dat$iso_a3 %in% iso,]
  dat <- dat[dat$year == max(dat$year, na.rm = TRUE), pop_cols]

  # strip rownames
  rownames(dat) <- NULL

  # output format
  if (format == "long") {
    dat <- data.frame(age_group = names(dat),
                      pop = as.numeric(dat[1,]),
                      stringsAsFactors = FALSE)
  }

  return(dat)
}
