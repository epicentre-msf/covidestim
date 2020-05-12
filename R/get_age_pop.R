#' Get population distribution and aggregate it to 10 year age groups
#'
#' This is set up to use population estimates from the World Populaiton
#' Prospects data
#'
#' @param iso country of interest
#'
#' @example
#' get_age_pop(iso = "FRA")
#'
#' @importFrom tibble as_tibble
#' @export get_age_pop
get_age_pop <- function(iso) {

  # iso <- "USA"

  pop_data <- get_pop_data()

  # subset to country and max year
  pop_data <- pop_data[pop_data$iso_a3 %in% iso,]
  pop_data <- pop_data[pop_data$year == max(pop_data$year, na.rm = TRUE),]

  # print for a double check
  # print(pop_data$location)
  pop_data <- pop_data[,c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59",
                          "60-69", "70-79", "80-89", "90-99", "100-109")]

  # ensure all columns numeric
  out <- tibble::as_tibble(lapply(pop_data, as.numeric))

  return(out)
}
