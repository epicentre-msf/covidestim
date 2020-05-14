#' Get age-sex specific probabilities estimated by Salje et al. 2020
#'
#' @param age_distr age distribution data-frame
#' @param p_type type of probablity to extract: p_hosp_inf = P(Hosp|Infection), etc
#' @param p_stat quantile of the original estimates used to compute probability
#' @param p_sex get estimates by sex or for total population
#'
#' @author Anton Camacho
#'
#' @examples
#' # overall propability of hospitalization given infection for France
#' age_dist_fr <- get_age_pop(iso = "FRA", format = "long")
#' get_p_Salje2020(age_dist_fr, p_type = "p_hosp_inf", p_stat = "mean", p_sex = "total")
#'
#' @import dplyr
#' @export get_p_Salje2020
get_p_Salje2020 <- function(age_distr,
                            p_type = c("p_hosp_inf", "p_icu_hosp", "p_dead_hosp", "p_dead_inf"),
                            p_stat = c("mean", "low_95", "up_95"),
                            p_sex = c("total", "male", "female")) {

  p_type <- match.arg(p_type)
  p_stat <- match.arg(p_stat)

  if (0) {
    p_type <- "p_dead_hosp"
    p_stat <- "mean"
    p_sex <- "total"
    age_distr <- get_age_pop(iso = "FRA", format = "long")
  }

  # filter data
  df_data <- get_est_salje()
  df_data <- df_data[df_data$variable == p_type & df_data$stat == p_stat & df_data$sex == p_sex,]

  # prepare age distr
  df_age <- age_distr %>%
    mutate(age_group = recode(age_class,
                              "0-9" = "0-20",
                              "10-19" = "0-20",
                              "80-89" = "80+",
                              "90-99" = "80+",
                              "100-109" = "80+")) %>%
    group_by(age_group) %>%
    summarize(population = sum(population)) %>%
    ungroup() %>%
    mutate(prop_population = population / sum(population))

  ## return
  df_age %>%
    left_join(df_data, "age_group") %>%
    summarize(p = sum(prop_population * probability)) %>%
    pull(p)
}

