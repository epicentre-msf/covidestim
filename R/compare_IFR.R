#' Compile age-adjusted IFR estimates from different countries based on ensemble
#' estimates by O'Driscoll et al. 2020.
#'
#' @description
#' Compile age-adjusted IFR estimates from different countries based on ensemble
#' estimates by O'Driscoll et al. 2020. The population age
#' distributions are either taken from the UN World Population
#' Prospects 2019 (WPP2019).
#'
#' @param countries A vector of ISO3 country codes used to extract age-specific population
#'   estimates from the UN World Population Prospects 2019 dataset.
#' @param p_sex Use severity estimate for which sex (either "female", "male", or
#'   "total")
#'
#' @return
#' A data.frame with IFR estimates (mean and 95% CI) for different countries
#'
#' @author Flavio Finger <flavio.finger@@epicentre.msf.org>
#'
#' @examples
#' compare_IFR(countries = c("AFG", "PAK", "IRN"))
#'
#' @export compare_IFR
compare_IFR <- function(countries = c("AFG", "PAK", "IRN"),
                        p_sex = c("total", "male", "female")) {

    p_sex <- match.arg(p_sex)

    ifr_df <- data.frame(
        iso = NULL,
        mn = NULL,
        low = NULL,
        up = NULL
    )

    for (cnt in countries) {
        up <- get_p_ODriscoll(x = cnt, p_stat = "up_95", p_sex = p_sex)
        mn <- get_p_ODriscoll(x = cnt, p_stat = "mean", p_sex = p_sex)
        low <- get_p_ODriscoll(x = cnt, p_stat = "low_95", p_sex = p_sex)

        ifr_df <- rbind(
            ifr_df,
            data.frame(iso = cnt, mn = mn, low = low, up = up)
        )
    }

    return(ifr_df)
}