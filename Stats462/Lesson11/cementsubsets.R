#!/usr/bin/env Rscript
cement.txt <- function() {
  library(rprojroot)
  paste0(
    find_root(has_file(".Rprofile")),
    "/Stats462/Data/cement.txt"
  )
}

lib_path <- function() {
  library(rprojroot)
  paste0(
    find_root(has_file(".Rprofile")),
    "/Stats462/Lib/libfunc.R"
  )
}

library(skimr)
source(lib_path())
suppressPackageStartupMessages(library(PerformanceAnalytics))
suppressPackageStartupMessages(library(olsrr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(stringr))

main <- function(argv) {
  cement <- read.table(cement.txt(),
    header = TRUE, as.is = TRUE
  )
  print(head(cement))
  print(skimr::skim(cement))

  chart.Correlation(cement,
    histogram = TRUE,
    pch = 15
  )
  model <- lm(y ~ ., data = cement)
  best <- ols_step_best_subset(model)
  print(str(best))
  best_rsq <- best_model_rsquare(best, model)
  best_adjr <- best_model_adjrsquare(best, model)
  best_cp <- best_model_cp(best, model, "mincp")
  best_cp2 <- best_model_cp(best, model, "relcp")
  print(best_rsq)
  print(best_adjr)
  print(best_cp)
  print(best_cp2)
  print(compute_cp(model, best_cp))
  print(compute_cp(model, best_cp2))
  return(0)
}

compute_cp <- function(full_model, model) {
  res <- NULL
  if (length(full_model$coefficients) <
      length(model$coefficients))
    res <- anova(model, full_model)
  else
    res <- anova(full_model, model)
  res %<>%
    mutate(mse = RSS / Res.Df)
  n <- nrow(model$model)
  p <- length(model$coefficients)
  ssek <- res$RSS[2]
  mseall <- res$mse[1]
  cp <-  ssek / mseall  +
    2 * p - n
  return(cp)
}

best_model_rsquare <- function(models, model, rsqinc = 0.05) {
  if (!inherits(models, "ols_step_best_subset")) {
    stop("Class has to be ols_step_best_subset")
  }
  models %<>%
    mutate(rsq.inc = ((rsquare / lag(rsquare) - 1)))
  models %<>%
    filter(rsq.inc >= rsqinc) %>%
    filter(n == max(n))
  predictors <- models$predictors
  rhs <- str_replace_all(predictors, " ", "+")
  formula <- update(formula(model), paste0(". ~ ", rhs))
  data <- model$model
  return(lm(formula, data))
}

best_model_adjrsquare <- function(models, model) {
  if (!inherits(models, "ols_step_best_subset")) {
    stop("Class has to be ols_step_best_subset")
  }
  models %<>%
    filter(adjr == max(adjr))
  predictors <- models$predictors
  rhs <- str_replace_all(predictors, " ", "+")
  formula <- update(formula(model), paste0(". ~ ", rhs))
  data <- model$model
  return(lm(formula, data))
}

best_model_cp <- function(models, model, criteria = "mincp") {
  if (!inherits(models, "ols_step_best_subset")) {
    stop("Class has to be ols_step_best_subset")
  }
  data <- model$model
  cols <- ncol(data)
  models %<>%
    mutate(p = n + 1) %>%
    mutate(cpratio = cp / p) %>%
    filter(p != cols)
  if (criteria == "mincp") {
    models %<>%
      filter(cp == min(cp))
  } else if (criteria == "relcp") {
    models %<>%
      filter(cpratio == min(cpratio))
  } else {
    stop("Criteria should be mincp or relcp")
  }
  models %<>%
    filter(n == min(n))
  predictors <- models$predictors
  rhs <- str_replace_all(predictors, " ", "+")
  formula <- update(formula(model), paste0(". ~ ", rhs))
  return(lm(formula, data))
}

if (identical(environment(), globalenv())) {
  quit(status = main(commandArgs(trailingOnly = TRUE)))
}