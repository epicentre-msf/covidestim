
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
    (Infection Fatality Risk) estimates based on data from 45 countries
  - [Levin et al. 2020](https://doi.org/10.1101/2020.07.23.20160895)
    meta regression IFR estimates based on data from 34 studies.

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

Get age-adjusted IFR estimates for countries according to an ensemble
estimate by [O’Driscoll et
al. 2020](https://doi.org/10.1101/2020.08.24.20180851) and compare them
to the results of a metaregression by [Levin et
al. 2020](https://doi.org/10.1101/2020.07.23.20160895).

``` r
#get list of all countries with available population
cntrys <- c("AFG", "SSD", "COD", "CHN", "USA", "FRA", "CHE", "JPN", "PER")

#compute IFRs, sort ascending, add continent
ifr <- compare_IFR(cntrys)
ifr$iso <- factor(ifr$iso, levels = unique(ifr$iso[order(ifr$mn)]))

#plot
ggplot(ifr) +
  geom_point(aes(x = iso, y = 100*mn, color = method), position = position_dodge(width = .3), size = 2) +
  geom_linerange(aes(x = iso, ymin = 100*low, ymax = 100*up, color = method), position = position_dodge(width = .3)) +
  labs(
    x = "Country",
    y = "IFR estimate [%]",
    color = "Method"
  ) +
  theme_bw() +
  theme(legend.position = "bottom")
```

![](man/figures/unnamed-chunk-6-1.png)<!-- -->

Plotting the same figure on a log-scale we can see the differences in
countries with younger populations too:

``` r
ggplot(ifr) +
  geom_point(aes(x = iso, y = 100*mn, color = method), position = position_dodge(width = .3), size = 2) +
  geom_linerange(aes(x = iso, ymin = 100*low, ymax = 100*up, color = method), position = position_dodge(width = .3)) +
  labs(
    x = "Country",
    y = "IFR estimate [%] (log-scale)",
    color = "Method"
  ) +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_y_log10()
```

![](man/figures/unnamed-chunk-7-1.png)<!-- -->

We can see that the differences in the estimated IFR come directly from
the different age-specific IFR estimates by the two groups of authors:

``` r
est_levin <- get_est_levin() %>% mutate(method = "levin")
est_odriscoll <- get_est_odriscoll(sex = "total") %>% mutate(method = "odriscoll")

est <- bind_rows(
    est_levin,
    est_odriscoll
  ) %>%
  select(-sex, -quantile) %>%
  tidyr::pivot_wider(names_from = stat, values_from = "p_dead_inf") %>%
  mutate(
    method = factor(method, levels = c("odriscoll", "levin")),
    age_group = factor(age_group,
      levels = c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39",
        "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79",
        "80-84", "80+", "85+")),
    )

ggplot(est) +
  geom_point(aes(age_group, 100*mean, col = method), size = 2) +
  geom_linerange(aes(age_group, ymin = 100*low_95, ymax = 100*up_95, col = method)) +
  labs(
    x = "Age-group",
    y = "IFR estimate [%] (log-scale)",
    color = "Method"
  ) +
  scale_y_log10() +
  theme_bw() +
  theme(legend.position = "bottom")
```

![](man/figures/unnamed-chunk-8-1.png)<!-- -->

Note that the ranges of the oldest age-groups are not matching exactly
between the two estimates.
