
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
prob_mild <- readr::read_csv(file[1])
prob_moderate <- readr::read_csv(file[2])
prob_severe <- readr::read_csv(file[3])

age_cat <- c("0-9","10-19","20-29","30-39","40-49","50-59","60-69","70+")
names(prob_mild) <- names(prob_moderate) <- names(prob_severe) <- age_cat


## write
usethis::use_data(wpp_loc,
                  wpp_pop,
                  prob_mild,
                  prob_moderate,
                  prob_severe,
                  overwrite = TRUE)
