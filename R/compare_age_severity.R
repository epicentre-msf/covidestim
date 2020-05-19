#' Compile age-specific estimates of Pr(hospitalizion|infection) from four
#' research groups
#'
#' @description
#' Compile age-specific estimates of Pr(hospitalizion|infection) based on
#' methods from four different research groups (JHU, Neher, Pasteur, and LHSTM).
#'
#' @param jhu_model Which JHU model to use to derive posterior probabilities
#'   ("Update" or "JHU Original")
#'
#' @return
#' A data.frame with age-specific estimates of Pr(hospitalization|infection)
#' (mean and 95% CI) based on methods by four different research groups (JHU,
#' Neher lab, Pasteur Institute, and LHSTM)
#'
#' @author Patrick Barks <patrick.barks@@epicentre.msf.org>
#'
#' @examples
#' compare_age_severity()
#'
#' @importFrom stats aggregate quantile
#' @export compare_age_severity
compare_age_severity <- function(jhu_model = c("Update", "JHU Original")) {

  jhu_model <- match.arg(jhu_model)

  # JHU
  jhu <- fetch_data("shenzhen_samples")
  jhu <- jhu[jhu$model == jhu_model & jhu$outcome == "severe",]

  jhu_mean <- aggregate(list(mean = jhu$p), list(age_group = jhu$age_group), mean)
  jhu_low95 <- aggregate(list(low95 = jhu$p), list(age_group = jhu$age_group), quantile, probs = 0.025)
  jhu_upp95 <- aggregate(list(upp95 = jhu$p), list(age_group = jhu$age_group), quantile, probs = 0.975)

  jhu_out <- Reduce(merge, list(jhu_mean, jhu_low95, jhu_upp95))
  jhu_out$group <- "JHU"

  # Neher
  neher_out <- get_est_neher()
  neher_out <- neher_out[,c("age_group", "p_hosp_inf")]
  names(neher_out) <- c("age_group", "mean")
  neher_out$low95 <- NA_real_
  neher_out$upp95 <- NA_real_
  neher_out$group <- "Neher"

  # Pasteur
  pasteur <- get_est_salje(sex = "total")
  pasteur <- pasteur[,c("age_group", "stat", "p_hosp_inf")]
  pasteur_split <- split(pasteur, pasteur$stat)

  pasteur_out <- data.frame(age_group = pasteur_split[[1]]$age_group,
                            mean = pasteur_split$mean$p_hosp_inf,
                            low95 = pasteur_split$low_95$p_hosp_inf,
                            upp95 = pasteur_split$up_95$p_hosp_inf,
                            group = "Pasteur",
                            stringsAsFactors = FALSE)

  # split age group 0-19 into 0-9 and 10-19
  pasteur_out <- pasteur_out[c(1, 1:nrow(pasteur_out)),]
  pasteur_out$age_group[1] <- "0-9"
  pasteur_out$age_group[2] <- "10-19"

  # LHSTM
  est_vanzan <- get_est_vanzandvoort()
  davies <- get_est_davies()
  davies_split <- split(davies, davies$stat)

  lhstm_out <- data.frame(age_group = davies_split[[1]]$age_group,
                          mean = davies_split$mean$p_clin_inf * est_vanzan$p_hosp_clin,
                          low95 = davies_split$low_95$p_clin_inf * est_vanzan$p_hosp_clin,
                          upp95 = davies_split$up_95$p_clin_inf * est_vanzan$p_hosp_clin,
                          group = "LHSTM",
                          stringsAsFactors = FALSE)

  return(rbind(jhu_out, neher_out, pasteur_out, lhstm_out))
}

