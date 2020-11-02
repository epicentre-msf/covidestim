
library(dplyr)

# get_pop_data()
wpp_loc <- readxl::read_xlsx("data-raw/pop-age-distrib/WPP2019_F01_LOCATIONS.XLSX", skip = 16) %>%
  dplyr::transmute(name = `Region, subregion, country or area*`,
                   LocID = `Location code`,
                   iso_a3 = `ISO3 Alpha-code`,
                   parent_LocID = `Parent Location code`)

# download.file(
#   paste0("https://population.un.org/wpp/Download/Files/",
#          "1_Indicators%20(Standard)/EXCEL_FILES/1_Population/",
#          "WPP2019_POP_F07_1_POPULATION_BY_AGE_BOTH_SEXES.xlsx"),
#   destfile = file.path("data-raw/pop-age-distrib",
#                        "WPP2019_POP_F07_1_POPULATION_BY_AGE_BOTH_SEXES.xlsx")
# )

wpp_pop <- file.path("data-raw/pop-age-distrib/WPP2019_POP_F07_1_POPULATION_BY_AGE_BOTH_SEXES.xlsx") %>%
  readxl::read_xlsx(skip = 16) %>%
  filter(Type != "Label/Separator") %>%
  mutate_at(vars(9:29), as.numeric) %>%
  select(location = `Region, subregion, country or area *`,
         LocID = `Country code`,
         year = `Reference date (as of 1 July)`,
         `0-4`,
         `5-9`,
         `10-14`,
         `15-19`,
         `20-24`,
         `25-29`,
         `30-34`,
         `35-39`,
         `40-44`,
         `45-49`,
         `50-54`,
         `55-59`,
         `60-64`,
         `65-69`,
         `70-74`,
         `75-79`,
         `80-84`,
         `85-89`,
         `90-94`,
         `95-99`,
         `100+`) %>%
  left_join(wpp_loc, by = "LocID") %>%
  select(-parent_LocID) %>%
  tidyr::gather("age_group", "pop", `0-4`:`100+`) %>%
  select(location, LocID, iso_a3, name, year, age_group, pop) %>%
  as.data.frame()



# each col contains samples for an age category
## saved output from get_severe_age_shenzhen()
age_cat <- c("0-9","10-19","20-29","30-39","40-49","50-59","60-69","70+")

shenzhen_update <- bind_rows(
  get_severe_age_Shenzhen("mild") %>%
    tidyr::gather("age_group", "p") %>%
    mutate(outcome = "mild"),
  get_severe_age_Shenzhen("moderate") %>%
    tidyr::gather("age_group", "p") %>%
    mutate(outcome = "moderate"),
  get_severe_age_Shenzhen("severe") %>%
    tidyr::gather("age_group", "p") %>%
    mutate(outcome = "severe")
) %>%
  mutate(model = "Update")

shenzhen_orig <- bind_rows(
  read.csv("data-raw/severity/shenzhen_mild_age_prob.csv") %>%
    setNames(age_cat) %>%
    tidyr::gather("age_group", "p") %>%
    mutate(outcome = "mild"),
  read.csv("data-raw/severity/shenzhen_moderate_age_prob.csv") %>%
    setNames(age_cat) %>%
    tidyr::gather("age_group", "p") %>%
    mutate(outcome = "moderate"),
  read.csv("data-raw/severity/shenzhen_severe_age_prob.csv") %>%
    setNames(age_cat) %>%
    tidyr::gather("age_group", "p") %>%
    mutate(outcome = "severe")
) %>%
  mutate(model = "JHU Original") %>%
  group_by(age_group, outcome) %>%
  slice(sample(1:n(), 2000)) %>%
  ungroup() %>%
  as.data.frame()

shenzhen_samples <- bind_rows(
  shenzhen_orig,
  shenzhen_update
)


## Davies et al. 2020, preprint
# Age-dependent effects in the transmission and control of COVID-19 epidemics
# https://doi.org/10.1101/2020.03.24.20043018
# Extended Data Table 1
davies <- readr::read_csv("data-raw/severity/tabS1_Davies2020.csv") %>%
  filter(variable == "p_clin_inf") %>%
  tidyr::pivot_wider(names_from = "variable", values_from = "probability") %>%
  as.data.frame()
  # tidyr::pivot_wider(-quantile, names_from = "stat", values_from = "p_clin_inf")


## Salje et al. 2020, Science
# Estimating the burden of SARS-CoV-2 in France
# https://doi.org/10.1126/science.abc3517
# Table S1 and S2
salje <- readr::read_csv("data-raw/severity/tabS1S2_Salje_2020.csv") %>%
  tidyr::pivot_wider(names_from = "variable", values_from = "probability") %>%
  as.data.frame()


## van Zandvoort et al. 2020, preprint
# Response strategies for COVID-19 epidemics in African settings: a mathematical
#  modelling study
# https://doi.org/10.1101/2020.04.27.20081711
# Table S2
vanzandvoort <- readr::read_csv("data-raw/severity/tabS2_VanZandvoort2020.csv") %>%
  tidyr::pivot_wider(names_from = "variable", values_from = "probability") %>%
  as.data.frame()


## Neher lab age-severity estimates
# https://covid19-scenarios.org/
# Table "AGE-GROUP-SPECIFIC PARAMETERS"
# Estimates "informed by epidemiological and clinical observations in China"
neher <- readr::read_csv("data-raw/severity/age_specific_params_Neher.csv") %>%
  setNames(c("age_group", "confirmed", "severe", "critical", "fatal")) %>%
    mutate_at(vars(-age_group), ~ .x / 100) %>%
    mutate(p_hosp_inf = confirmed * severe,
           p_icu_hosp = critical,
           p_dead_hosp = critical * fatal,
           p_dead_inf = p_dead_hosp * p_hosp_inf) %>%
  as.data.frame()


## Bi et al. 2020, preprint
# https://doi.org/10.1101/2020.03.03.20028423
bi <- data.frame(
  age_group = c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70+"),
  mild = c(7, 3, 13, 22, 15, 21, 17, 4),
  moderate = c(13, 9, 21, 64, 40, 46, 49, 12),
  severe = c(0, 0, 0, 1, 5, 7, 20, 2),
  fever_no = c(6, 3, 3, 13, 6, 10, 16, 4),
  fever_yes = c(14, 9, 31, 74, 54, 64, 70, 14),
  stringsAsFactors = FALSE
) %>%
  mutate(total = fever_no + fever_yes)


## Model by MRC Centre for Global Infectious Disease Analysis, Imperial College
# https://mrc-ide.github.io/global-lmic-reports/parameters.html
imperial <- readr::read_csv("data-raw/severity/age_specific_params_Imperial.csv") %>%
  mutate(age_group = gsub(" to ", "-", age_group)) %>%
  mutate(p_dead_icu = 0.5) %>%
  mutate(p_icu_inf = (p_hosp_inf * p_icu_hosp),
         p_dead_inf = (p_icu_inf * p_dead_icu) + ((1 - p_icu_inf) * p_dead_nonicu)) %>%
  select(age_group, p_hosp_inf, p_icu_hosp, p_dead_icu, p_dead_nonicu, p_icu_inf, p_dead_inf) %>%
  as.data.frame()


## Data from O'Driscoll et al. 2020, preprint
# https://www.medrxiv.org/content/10.1101/2020.08.24.20180851v1
odriscoll <- readr::read_csv("data-raw/severity/odriscoll_table_s3.csv") %>%
  mutate(age_group = paste0(age_l, "-", age_u)) %>%
  mutate(age_group = if_else(age_group == "80-999", "80+", age_group)) %>%
  select(-age_u, -age_l) %>%
  tidyr::pivot_longer(-age_group, values_to = "p_dead_inf") %>%
  mutate(
    stat = case_when(
      grepl("_m", name) ~ "mean",
      grepl("_u", name) ~ "up_95",
      grepl("_l", name) ~ "low_95",
      TRUE ~ NA_character_
    ),
    sex = case_when(
      grepl("female", name) ~ "female",
      grepl("male", name) ~ "male",
      grepl("both", name) ~ "total",
      TRUE ~ NA_character_
    )
  ) %>%
  select(-name) %>%
  mutate(quantile = case_when(
    stat == "low_95" ~ .025,
    stat == "up_95" ~ .975,
    stat == "mean" ~ 0.5
  )) %>%
  mutate(p_dead_inf = p_dead_inf/100) %>% #percent!
  as.data.frame()


## Data from Brazeau et al. 2020, Imperial MRC Report 34
# https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis/covid-19/report-34-ifr/
brazeau <- readr::read_csv("data-raw/severity/brazeau_table_2.csv") %>%
  mutate(age_group = paste0(age_l, "-", age_u)) %>%
  mutate(age_group = if_else(age_group == "90-999", "90+", age_group)) %>%
  select(-age_u, -age_l) %>%
  tidyr::pivot_longer(-age_group, values_to = "p_dead_inf") %>%
  mutate(
    stat = case_when(
      grepl("_m", name) ~ "mean",
      grepl("_u", name) ~ "up_95",
      grepl("_l", name) ~ "low_95",
      TRUE ~ NA_character_
    ),
    type = case_when(
      grepl("^ifr_serorev_", name) ~ "p_dead_inf",
      grepl("^ifr_", name) ~ "p_dead_inf_serorev",
      TRUE ~ NA_character_
    )
  ) %>%
  select(-name) %>%
  mutate(quantile = case_when(
    stat == "low_95" ~ .025,
    stat == "up_95" ~ .975,
    stat == "mean" ~ 0.5
  )) %>%
  mutate(p_dead_inf = p_dead_inf/100) %>% #percent!
  as.data.frame()



#' Compute estimates acording to Levin et al.
#'
#' @param stat Optional statistic to subset to (either "mean", "low_95", or
#'   "up_95"). Defaults to `NULL`, in which case all cagegories are returned.
#'
#' @source
#' Assessing the Age Specificity of Infection Fatality Rates for COVID-19:
#' Systematic Review, Meta-Analysis, and Public Policy Implications
#' Andrew T. Levin, William P. Hanage, Nana Owusu-Boaitey, Kensington B.
#' Cochran, Seamus P. Walsh, Gideon Meyerowitz-Katz
#' medRxiv 2020.07.23.20160895;
#' doi: \url{https://doi.org/10.1101/2020.07.23.20160895}
#'
#' @export compute_est_Levin
compute_est_Levin <- function(stat = NULL) {
    #compute estimates for each age
    ages <- seq(0, 89, by = 1)
    ifr <- 10**(-3.27 + 0.0524*ages)/100
    ifr_low <- 10**(-3.27-(1.96*0.07) + (0.0524 - 1.96*0.0013)*ages)/100
    ifr_high <- 10**(-3.271+(1.96*0.07) + (0.0524 + 1.96*0.0013)*ages)/100
    
    #aggregate
    lower_age <- seq(0, 80, by = 5)
    upper_age <- seq(4, 84, by = 5)

    age_group <- c(paste0(lower_age, "-", upper_age), "85+")
    age_group <- rep(age_group, each = 5)
    

    out <- data.frame(
        age_group = rep(age_group, 3),
        p_dead_inf = c(ifr, ifr_low, ifr_high),
        stat = c(
            rep("mean", length(age_group)),
            rep("low_95", length(age_group)),
            rep("up_95", length(age_group))
        ),
        quantile = c(
            rep(.5, length(age_group)),
            rep(.025, length(age_group)),
            rep(.975, length(age_group))
        )
    )

    out <- aggregate(p_dead_inf ~ age_group + stat + quantile, out, mean) #aggregate by age group and stat

    if (!is.null(stat)) out <- out[out$stat == stat,]

    return(out)
}

levin <- compute_est_Levin()


## write
usethis::use_data(wpp_pop,
                  shenzhen_samples,
                  neher,
                  davies,
                  salje,
                  vanzandvoort,
                  bi,
                  imperial,
                  odriscoll,
                  brazeau,
                  levin,
                  overwrite = TRUE)



# library(ggplot2)
# library(ggsci)
#
# ests_full <- compare_age_severity(jhu_model = "JHU Original")
#
# ggplot(ests_full, aes(x = age_group, y = mean, color = group)) +
#   geom_point(position = position_dodge(width = 0.51), size = 3) +
#   geom_linerange(aes(ymin = low95, ymax = upp95), position = position_dodge(width = 0.51), size = 1.1) +
#   labs(x = "Age group",
#        y = "Pr(hospitalization|infection)",
#        color = "Research group") +
#   scale_color_nejm() +
#   theme_bw() +
#   theme(legend.position = "top")
