#!/usr/bin/env Rscript
houseprice <- function() {
  library(rprojroot)
  paste0(find_root(has_file(".Rprofile")), "/Stats462/Data/houseprice.txt")
}
library(skimr)

main <- function(argv) {
  data <- read.table(houseprice(), header = TRUE)
  print(head(data))
  print(skimr::skim(data))
  data$ones <- 1
  reg <- lm(Price ~ ones + 0, data)
  print(reg)
  new_data <- data.frame(ones = c(1))
  print(predict(reg, newdata = new_data, interval = "prediction"))
  return(0)
}

if (identical(environment(), globalenv())) {
  quit(status = main(commandArgs(trailingOnly = TRUE)))
}
