
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covidestim

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

An R package for estimating population-level covid19 outcome
probabilities ( e.g. hospitalization|infection, death|hospitalization,
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
  - [O'Driscoll et al. 2020](https://doi.org/10.1101/2020.08.24.20180851) ensemble IFR (Infection Fatality Risk) estimates based on data from 45 countries.

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
#> 11   100-109     0.039
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
covidestim::get_p_ODriscoll("AFG", p_type = "p_dead_inf")
#> [1] 0.0006973
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
