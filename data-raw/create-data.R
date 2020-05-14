
library(dplyr)

# get_wpp_locations()
wpp_loc <- readxl::read_xlsx("data-raw/WPP2019_F01_LOCATIONS.XLSX", skip = 16) %>%
  dplyr::transmute(name = `Region, subregion, country or area*`,
                   LocID = `Location code`,
                   iso_a3 = `ISO3 Alpha-code`,
                   parent_LocID = `Parent Location code`)

# get_pop_data()
wpp_pop <- readr::read_csv("data-raw/WPP2019_POP.csv") %>%
  rename(LocID = `Country code`) %>%
  left_join(wpp_loc, by = "LocID") %>%
  select(-parent_LocID)



## saved output from get_severe_age_shenzhen()
outcome <- c("mild", "moderate", "severe")
file <- paste0("data-raw/", outcome, "_age_prob.csv")

# each col contains samples for an age category
shenzhen_prob_mild <- readr::read_csv(file[1])
shenzhen_prob_moderate <- readr::read_csv(file[2])
shenzhen_prob_severe <- readr::read_csv(file[3])

age_cat <- c("0-9","10-19","20-29","30-39","40-49","50-59","60-69","70+")
names(shenzhen_prob_mild) <- names(shenzhen_prob_moderate) <- names(shenzhen_prob_severe) <- age_cat


## Davies
davies <- readr::read_csv("data-raw/tabS1_Davies2020.csv")

## Salje
salje <- readr::read_csv("data-raw/tabS1S2_Salje_2020.csv")

## Vanzandervoort
vanzand <- readr::read_csv("data-raw/tabS2_VanZandvoort2020.csv")


## write
usethis::use_data(wpp_loc,
                  wpp_pop,
                  shenzhen_prob_mild,
                  shenzhen_prob_moderate,
                  shenzhen_prob_severe,
                  davies,
                  salje,
                  vanzand,
                  overwrite = TRUE)
