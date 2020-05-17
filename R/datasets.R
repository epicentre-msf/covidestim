#' Population estimates by country/region and 10-year age interval, derived from
#' the UN World Population Prospects 2019
#'
#' @description
#' From \url{https://population.un.org/wpp/Download/Standard/Population/}
#'
#' File: Population by Age Groups - Both Sexes (XLSX, 10.32 MB):
#' Quinquennial Population by Five-Year Age Groups - Both Sexes. De facto
#' population as of 1 July of the year indicated classified by five-year age
#' groups (0-4, 5-9, 10-14, ..., 95-99, 100+). (Accessed 2020-05-16)
#'
#' @format A data frame with 3765 rows and 16 variables:
#' \describe{
#'   \item{location}{country or region}
#'   \item{LocID}{location ID}
#'   \item{year}{year of populationestimates}
#'   \item{0-9}{population estimate for age group 0-9 years}
#'   \item{10-19}{population estimate for age group 10-19 years}
#'   \item{20-29}{population estimate for age group 20-29 years}
#'   \item{30-39}{population estimate for age group 30-39 years}
#'   \item{40-49}{population estimate for age group 40-49 years}
#'   \item{50-59}{population estimate for age group 50-59 years}
#'   \item{60-69}{population estimate for age group 60-69 years}
#'   \item{70-79}{population estimate for age group 70-79 years}
#'   \item{80-89}{population estimate for age group 80-89 years}
#'   \item{90-99}{population estimate for age group 90-99 years}
#'   \item{100-109}{population estimate for age group 100-109 years}
#'   \item{name}{location name}
#'   \item{iso_a3}{location ISO A3 code}
#' }
#'
#' @source \url{https://population.un.org/wpp/Download/Standard/Population/}
"wpp_pop"


#' Age-specific severity estimates from van Zandvoort et al. 2020
#'
#' Estimates from Table S2 of van Zandvoort et al. 2020.
#'
#' @format A data frame with 96 rows and 5 variables:
#' \describe{
#'   \item{age_group}{age group, in 10-year intervals}
#'   \item{p_hosp_clin}{probability of hospitalization given clinical}
#'   \item{p_icu_hosp}{probability of ICU given hospitalization}
#'   \item{p_dead_hosp}{probability of dying given hospitalization}
#' }
#'
#' @source van Zandvoort, K., Jarvis, C.I., Pearson, C., Davies, N.G., CMMID
#'   COVID-19 Working Group, Russell, T.W., Kucharski, A.J., Jit, M.J., Flasche,
#'   S., Eggo, R.M., and Checchi, F. (2020) Response strategies for COVID-19
#'   epidemics in African settings: a mathematical modelling study. medRxiv
#'   preprint. \url{https://doi.org/10.1101/2020.04.27.20081711}
"vanzandvoort"


#' Age-specific severity estimates from Salje et al. 2020
#'
#' Estimates from Tables S1 and S2 of Salje et al. 2020.
#'
#' @format A data frame with 96 rows and 5 variables:
#' \describe{
#'   \item{age_group}{age group, in 10-year intervals except for first group 0-19}
#'   \item{sex}{sex ("male", "female", or "total")}
#'   \item{stat}{statistic ("mean", "low_95", or "upp_95")}
#'   \item{quantile}{quantile corresponding to the relevant statistic}
#'   \item{p_hosp_inf}{probability of hospitalization given infection}
#'   \item{p_icu_hosp}{probability of ICU given hospitalization}
#'   \item{p_dead_hosp}{probability death given hospitalization}
#'   \item{p_dead_inf}{probability of death given infection}
#' }
#'
#' @source Salje, H., Kiem, C.T., Lefrancq, N., Courtejoie, N., Bosetti, P.,
#'   Paireau, J., Andronico, A., Hoze, N., Richet, J., Dubost, C.L., and Le
#'   Strat, Y. (2020) Estimating the burden of SARS-CoV-2 in France. Science.
#'   \url{https://doi.org/10.1126/science.abc3517}
"salje"


#' Age-specific clinical fraction estimates from Davies et al. 2020
#'
#' Estimates from Extended Data Table 1 of Davies et al. 2020
#'
#' @format A data frame with 48 rows and 4 variables:
#' \describe{
#'   \item{age_group}{age group, in 10-year intervals}
#'   \item{stat}{statistic, "mean", "median", "low_50", "upp_50", "low_95", or "upp_95"}
#'   \item{quantile}{quantile corresponding to the relevant statistic}
#'   \item{p_clin_inf}{probability clinical given infection}
#' }
#'
#' @source Davies, N.G., Klepac, P., Liu, Y., Prem, K., Jit, M., CMMID COVID-19
#'   Working Group, and Eggo, R.M. (2020) Age-dependent effects in the
#'   transmission and control of COVID-19 epidemics. medRxiv preprint.
#'   \url{https://doi.org/10.1101/2020.03.24.20043018}
"davies"


#' Age-specific severity estimates from Neher lab
#'
#' According to the source these estimaes are "informed by epidemiological and
#' clinical observations from China".
#'
#' @format A data frame with 9 rows and 9 variables:
#' \describe{
#'   \item{age_group}{age group, in 10-year intervals}
#'   \item{confirmed}{probability confirmed given infection}
#'   \item{severe}{probability severe case given confirmed}
#'   \item{critical}{probability of critical case given severe}
#'   \item{fatal}{probability of fatal case given critical}
#'   \item{p_icu_hosp}{probability of ICU given hospitalization}
#'   \item{p_hosp_inf}{probability of hospitalization given infection}
#'   \item{p_dead_hosp}{probability of dying given hospitalization}
#'   \item{p_dead_inf}{probability of dying given infection}
#' }
#' @source \url{https://covid19-scenarios.org/}
"neher"


#' Age-specific severity counts from Bi et al. 2020
#'
#' Based on data from Shenzhen CDC, China.
#'
#' @format A data frame with 8 rows and 7 variables:
#' \describe{
#'   \item{age_group}{age group, in 10-year intervals}
#'   \item{mild}{number of mild cases}
#'   \item{moderate}{number of moderate cases}
#'   \item{severe}{number of severe cases}
#'   \item{fever_no}{number of cases with no fever}
#'   \item{fever_yes}{number of cases with fever}
#'   \item{total}{total number of cases}
#' }
#' @source Bi, Q., Wu, Y., ..., and Feng, .T. (2020) Epidemiology and
#'   Transmission of COVID-19 in Shenzhen China: Analysis of 391 cases and 1,286
#'   of their close contacts. medRxiv preprint.
#'   \url{https://doi.org/10.1101/2020.03.03.20028423}
"bi"
