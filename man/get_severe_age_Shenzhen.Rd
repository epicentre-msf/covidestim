% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_severe_age_shenzhen.R
\name{get_severe_age_Shenzhen}
\alias{get_severe_age_Shenzhen}
\title{Model the probability of Covid19 outcome type (mild, moderate, severe) by age
group based on data from Shenzen, China (Bi et al. 2020)}
\source{
Bi, Q., Wu, Y., Mei, S., Ye, C., Zou, X., Zhang, Z., Liu, X., Wei, L.,
Truelove, S., Zhang, T., Gao, W., Cheng, C., Tang, X., ..., and Feng, .T.
(2020) Epidemiology and Transmission of COVID-19 in Shenzhen China: Analysis
of 391 cases and 1,286 of their close contacts. medRxiv preprint.
\url{https://doi.org/10.1101/2020.03.03.20028423}
}
\usage{
get_severe_age_Shenzhen(outcome = c("severe", "moderate", "mild"),
  nsamples = 2000)
}
\arguments{
\item{outcome}{Outcome category ("severe", "moderate", or "mild")}

\item{nsamples}{Number of samples to draw (defaults to 2000)}
}
\value{
A data.frame with \code{nsamples} rows and 8 columns, corresponding to each
age group (`0-9`, `10-19`, ..., `70+`)
}
\description{
Adapted from https://github.com/HopkinsIDD/covidSeverity
}
\examples{
# draws from the posterior distribution of probability of severe outcome
post_samples <- get_severe_age_Shenzhen("severe")

# posterior median probability of severe outcomes for each age group
apply(post_samples, 2, median)

}
\author{
Patrick Barks <patrick.barks@epicentre.msf.org>
}
