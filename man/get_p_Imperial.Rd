% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_p_Imperial.R
\name{get_p_Imperial}
\alias{get_p_Imperial}
\title{Estimate Covid2019 outcome probabilities for a population given its age
distribution, and age-severity estimates from MRC-IDE at Imperial College}
\source{
\url{https://mrc-ide.github.io/global-lmic-reports/parameters.html}
}
\usage{
get_p_Imperial(x, p_type = c("p_hosp_inf", "p_icu_hosp", "p_dead_icu",
  "p_dead_nonicu", "p_dead_inf"))
}
\arguments{
\item{x}{Either an ISO3 country code used to extract age-specific population
estimates from the UN World Population Prospects 2019 dataset, \emph{or}, a
data.frame containing age categories in the first column and population
counts (or proportions) in the second column. To match the severity
estimates, age groups must match or be aggregatable to 5-year intervals
(0-4, 5-9, ...).}

\item{p_type}{Outcome to estimate (either "p_hosp_inf", "p_icu_hosp",
"p_dead_icu", "p_dead_nonicu", or "p_dead_inf")}
}
\value{
Estimated outcome probability (scalar)
}
\description{
Estimate Covid19 outcome probabilities including hospitalizion|infection,
ICU|hospitalization, death|ICU, death|non-ICU, and death|infection, using
age-severity estimates from MRC-IDE at Imperial College, and the population
age distribution for a given country, either taken from the UN World
Population Prospects 2019 (WPP2019) or directly supplied by the user.
}
\examples{
# mean Pr(hospitalization|infection) for Canada (ISO3 code "CAN"), taking age
# distribution from WPP2019
get_p_Imperial(x = "CAN", p_type = "p_hosp_inf")

}
\author{
Patrick Barks <patrick.barks@epicentre.msf.org>
}
