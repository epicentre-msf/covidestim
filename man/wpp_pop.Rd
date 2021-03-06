% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datasets.R
\docType{data}
\name{wpp_pop}
\alias{wpp_pop}
\title{Population estimates by country/region and 10-year age interval, derived from
the UN World Population Prospects 2019}
\format{A data frame with 3765 rows and 16 variables:
\describe{
  \item{location}{country or region}
  \item{LocID}{location ID}
  \item{iso_a3}{location ISO A3 code}
  \item{name}{location name}
  \item{year}{year of populationestimates}
  \item{age_group}{age group, in 5-years intervals (0-4, 5-9, ..., 100+)}
  \item{pop}{population size estimate}
}}
\source{
\url{https://population.un.org/wpp/Download/Standard/Population/}
}
\usage{
wpp_pop
}
\description{
From \url{https://population.un.org/wpp/Download/Standard/Population/}

File: Population by Age Groups - Both Sexes (XLSX, 10.32 MB):
Quinquennial Population by Five-Year Age Groups - Both Sexes. De facto
population as of 1 July of the year indicated classified by five-year age
groups (0-4, 5-9, 10-14, ..., 95-99, 100+). (Accessed 2020-05-16)
}
\keyword{datasets}
