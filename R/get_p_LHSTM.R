#' Get age specific probabilities estimated by LSHTM (Davies et al. 2020 and Van
#' Zandvoort et al. 2020)
#'
#' @param age_distr age distribution data-frame
#' @param p_type type of probablity to extract: p_hosp_inf = P(Hosp|Infection), etc
#' @param p_stat quantile of the original estimates used to compute probability
#'
#' @author Anton Camacho
#'
#' @examples
#' # overall propability of hospitalization given infection for France
#' age_dist_fr <- get_age_pop(iso = "FRA", format = "long")
#' get_p_LSHTM(age_dist_fr, p_type = "p_hosp_inf", p_stat = "median")
#'
#' @import dplyr tidyr
#' @export
get_p_LSHTM <- function(age_distr,
                        p_type = c("p_hosp_inf", "p_icu_hosp", "p_dead_hosp", "p_dead_inf"),
                        p_stat = c("mean", "median", "low_95", "up_95", "low_50", "up_50")) {

  p_type <- match.arg(p_type)
  p_stat <- match.arg(p_stat)

  if (0) {
    age_distr <- get_age_pop(iso = "FRA", format = "long")
    p_type <- "p_dead_inf"
    p_stat <- "mean"
  }

  # use P(Clinical|Infection) from Davies 2020 (with confidence intervals) and
  #  P(Hosp|Clinical) from VanZandvoort 2020 to compute P(Hosp|Infection)
  df_data_D <- get_est_davies() %>%
    filter(variable == "p_clin_inf", stat == p_stat) %>%
    select(variable, age_group, probability) %>%
    tidyr::pivot_wider(names_from = "variable", values_from = "probability")


  df_data <- get_est_vanzandvoort() %>%
    tidyr::pivot_wider(names_from = "variable", values_from = "probability") %>%
    left_join(df_data_D, "age_group") %>%
    mutate(p_hosp_inf = p_hosp_clin * p_clin_inf,
           p_dead_inf = p_dead_hosp * p_hosp_inf) %>%
    tidyr::pivot_longer(cols = -age_group,
                        names_to = "variable",
                        values_to = "probability") %>%
    filter(variable == p_type)

  # prepare age distr
  df_age <- age_distr %>%
    mutate(age_group = recode(age_class,
                              "70-79" = "70+",
                              "80-89" = "70+",
                              "90-99" = "70+",
                              "100-109" = "70+") %>%
             as.character(),
           population = population * 1000
    ) %>%
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
