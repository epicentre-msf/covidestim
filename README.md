
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covidestim

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

An R package for estimating population-level covid19 outcome
probabilities (e.g. hospitalization|infection, death|hospitalization,
etc.), given the age-distribution of a population of interest and
severity estimates (by age, sex, etc.) from various research groups.

Includes functions to extract country-level age distributions from the
[UN World Population Prospects
2019](https://population.un.org/wpp/Download/Standard/Population/)
dataset, and age-severity estimates from:

  - [Salje et al. 2020](https://doi.org/10.1126/science.abc3517) (based
    on data from France)
  - [Neher Lab](https://doi.org/10.1101/2020.05.05.20091363) (China)
  - [Bi et al. 2020](https://doi.org/10.1101/2020.03.03.20028423)
    (Schenzhen, China)
  - [Davies et al. 2020](https://doi.org/10.1101/2020.03.24.20043018)
    and [van Zandvoort et
    al. 2020](https://doi.org/10.1101/2020.04.27.20081711) (China,
    Diamond Princess)
  - [O’Driscoll et
    al. 2020](https://doi.org/10.1101/2020.08.24.20180851) ensemble IFR
    (Infection Fatality Risk) estimates based on data from 45 countries.

## Installation

Install from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("epicentre-msf/covidestim")
```

## Usage

#### Extract population age-distributions from UN World Population Prospects 2019

``` r
library(covidestim)

covidestim::get_age_pop(iso = "AFG", format = "long") # AFG = Afghanistan
#>    age_group       pop
#> 1        0-9 11088.732
#> 2      10-19  9821.559
#> 3      20-29  7035.871
#> 4      30-39  4534.646
#> 5      40-49  2963.459
#> 6      50-59  1840.198
#> 7      60-69  1057.496
#> 8      70-79   480.455
#> 9      80-89   100.065
#> 10     90-99     5.821
#> 11      100+     0.039
```

#### Derive population-wide covid19 outcome probability estimates

``` r
# mean probability of death|infection in Afghanistan, based on age-severity
# estimates from different research groups
covidestim::get_p_Salje("AFG", p_type = "p_dead_inf")
#> [1] 0.0008886
covidestim::get_p_Neher("AFG", p_type = "p_dead_inf")
#> [1] 0.001087
covidestim::get_p_LSHTM("AFG", p_type = "p_dead_inf")
#> [1] 0.006092
```

#### Compare estimates of Pr(hospitalization|infection) from various research groups

``` r
library(ggplot2)

p_hosp <- covidestim::compare_age_severity()

ggplot(p_hosp, aes(x = age_group, y = mean, color = group)) +
  geom_point(size = 3, position = position_dodge(width = 0.6)) +
  geom_linerange(aes(ymin = low95, ymax = upp95), position = position_dodge(width = 0.6)) +
  labs(x = "Age group", y = "Pr(hospitalization|infection)", col = "Group") +
  theme_bw()
```

![](man/figures/unnamed-chunk-5-1.png)<!-- -->

#### Compare Infection Fatality Risk (IFR) of different countries

Get age-adjusted IFR estimates for countries according to ensemble
estimates by [O’Driscoll et
al. 2020](https://doi.org/10.1101/2020.08.24.20180851).

``` r
#get list of all countries with available population
pop <- get_pop_data()
cntrys <- pop$iso_a3
cntrys <- unique(cntrys)
cntrys <- cntrys[!is.na(cntrys)]

#compute IFRs, sort ascending, add continent
ifr <- compare_IFR(cntrys)
ifr$iso <- factor(ifr$iso, levels = ifr$iso[order(ifr$mn)])
ifr$continent <- countrycode::countrycode(ifr$iso, "iso3c", "continent")

#plot
ggplot(ifr[ifr$continent %in% c("Africa", "Asia"),]) +
  geom_point(aes(x = iso, y = 100*mn)) +
  geom_linerange(aes(x = iso, ymin = 100*low, ymax = 100*up)) +
  scale_y_log10(limits = c(0.05, 1)) +
  scale_x_discrete(guide = guide_axis(angle = 90, n.dodge = 2)) +
  labs(
    x = "Country",
    y = "IFR estimate (%)"
  ) +
  theme_bw() +
  theme(legend.position = "none") +
  facet_grid(cols = vars(continent), drop = T, scales = "free_x", space = "free_x")
```

![](man/figures/unnamed-chunk-6-1.png)<!-- -->

``` r

ggplot(ifr[ifr$continent %in% c("Americas", "Europe", "Oceania"),]) +
  geom_point(aes(x = iso, y = 100*mn)) +
  geom_linerange(aes(x = iso, ymin = 100*low, ymax = 100*up)) +
  scale_y_log10(limits = c(0.05, 1)) +
  scale_x_discrete(guide = guide_axis(angle = 90, n.dodge = 2)) +
  labs(
    x = "Country",
    y = "IFR estimate (%)"
  ) +
  theme_bw() +
  theme(legend.position = "none") +
  facet_grid(cols = vars(continent), drop = T, scales = "free_x", space = "free_x")
```

![](man/figures/unnamed-chunk-6-2.png)<!-- -->
