
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
  mutate(`0-9` = `0-4` + `5-9`,
         `10-19` = `10-14` + `15-19`,
         `20-29` = `20-24` + `25-29`,
         `30-39` = `30-34` + `35-39`,
         `40-49` = `40-44` + `45-49`,
         `50-59` = `50-54` + `55-59`,
         `60-69` = `60-64` + `65-69`,
         `70-79` = `70-74` + `75-79`,
         `80-89` = `80-84` + `85-89`,
         `90-99` = `90-94` + `95-99`,
         `100-109` = `100+`) %>%
  select(location = `Region, subregion, country or area *`,
         LocID = `Country code`,
         year = `Reference date (as of 1 July)`,
         `0-9`,
         `10-19`,
         `20-29`,
         `30-39`,
         `40-49`,
         `50-59`,
         `60-69`,
         `70-79`,
         `80-89`,
         `90-99`,
         `100-109`) %>%
  left_join(wpp_loc, by = "LocID") %>%
  select(-parent_LocID)


# each col contains samples for an age category
## saved output from get_severe_age_shenzhen()

shenzhen_prob_mild <- get_severe_age_Shenzhen("mild")
shenzhen_prob_moderate <- get_severe_age_Shenzhen("moderate")
shenzhen_prob_severe <- get_severe_age_Shenzhen("severe")

outcome <- c("mild", "moderate", "severe")
file <- paste0("data-raw/severity/shenzhen_", outcome, "_age_prob.csv")

shenzhen_prob_mild_orig <- readr::read_csv(file[1])
shenzhen_prob_moderate_orig <- readr::read_csv(file[2])
shenzhen_prob_severe_orig <- readr::read_csv(file[3])

age_cat <- c("0-9","10-19","20-29","30-39","40-49","50-59","60-69","70+")
names(shenzhen_prob_mild_orig) <- names(shenzhen_prob_moderate_orig) <- names(shenzhen_prob_severe_orig) <- age_cat


## Davies et al. 2020, preprint
# Age-dependent effects in the transmission and control of COVID-19 epidemics
# https://doi.org/10.1101/2020.03.24.20043018
# Extended Data Table 1
davies <- readr::read_csv("data-raw/severity/tabS1_Davies2020.csv") %>%
  filter(variable == "p_clin_inf") %>%
  tidyr::pivot_wider(names_from = "variable", values_from = "probability")
  # tidyr::pivot_wider(-quantile, names_from = "stat", values_from = "p_clin_inf")


## Salje et al. 2020, Science
# Estimating the burden of SARS-CoV-2 in France
# https://doi.org/10.1126/science.abc3517
# Table S1 and S2
salje <- readr::read_csv("data-raw/severity/tabS1S2_Salje_2020.csv") %>%
  tidyr::pivot_wider(names_from = "variable", values_from = "probability")


## van Zandvoort et al. 2020, preprint
# Response strategies for COVID-19 epidemics in African settings: a mathematical
#  modelling study
# https://doi.org/10.1101/2020.04.27.20081711
# Table S2
vanzandvoort <- readr::read_csv("data-raw/severity/tabS2_VanZandvoort2020.csv") %>%
  tidyr::pivot_wider(names_from = "variable", values_from = "probability")


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
           p_dead_inf = p_dead_hosp * p_hosp_inf)


## Bi et al. 2020, preprint
# https://doi.org/10.1101/2020.03.03.20028423
bi <- tibble::tibble(
  age_group = c("0-9","10-19","20-29","30-39","40-49","50-59","60-69","70+"),
  mild = c(7,3,13,22,15,21,17,4),
  moderate = c(13,9,21,64,40,46,49,12),
  severe = c(0,0,0,1,5,7,20,2),
  fever_no = c(6,3,3,13,6,10,16,4),
  fever_yes = c(14,9,31,74,54,64,70,14)
) %>%
  mutate(total = fever_no + fever_yes)



## write
usethis::use_data(wpp_pop,
                  shenzhen_prob_mild,
                  shenzhen_prob_moderate,
                  shenzhen_prob_severe,
                  shenzhen_prob_mild_orig,
                  shenzhen_prob_moderate_orig,
                  shenzhen_prob_severe_orig,
                  neher,
                  davies,
                  salje,
                  vanzandvoort,
                  bi,
                  overwrite = TRUE)

