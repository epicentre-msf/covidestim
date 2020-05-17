
#' @noRd
rename_col <- function(x, from, to) {
  names(x)[names(x) == from] <- to
  x
}


#' @noRd
#' @importFrom stats aggregate
aggregate_ages <- function(x, target) {

  if (FALSE) {
    x <- get_age_pop("CAN", format = "long")
    target <- c("0-9", "5-9", "10-19", "20-29", "30-39", "40+")
  }

  # reclassify age groups based on target
  age_reclass <- range_match(x$age_group, target)

  if (any(is.na(age_reclass))) {
    stop("The following age groups could not be matched: ",
         paste(x$age_group[is.na(age_reclass)], collapse = "; "))
  }

  ## sum population sizes by age group
  x$age_group <- age_reclass
  aggregate(population ~ age_group, sum, data = x)
}


#' @noRd
range_match <- function(x, y) {

  ex <- expand.grid(x = x, y = y, stringsAsFactors = FALSE)

  xmin <- extract_range(ex$x, 1)
  xmax <- extract_range(ex$x, 2)

  ymin <- extract_range(ex$y, 1)
  ymax <- extract_range(ex$y, 2)

  sub <- xmin >= ymin & xmax <= ymax

  # join matches (ex[sub,]) to x
  df_x <- data.frame(n = seq_along(x), x = x, stringsAsFactors = FALSE)
  df_merge <- merge(df_x, ex[sub,], all.x = TRUE)

  # reorder
  df_merge <- df_merge[order(df_merge$n),]

  return(df_merge$y)
}


#' @noRd
extract_range <- function(x, n = c(1, 2)) {
  r <- vapply(gsub("\\+", "-Inf", x),
              function(y, n) strsplit(y, "\\-")[[1]][n],
              "",
              n = n,
              USE.NAMES = FALSE)
  return(as.numeric(r))
}

