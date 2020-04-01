#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(skimr))
suppressPackageStartupMessages(library(nortest))
suppressPackageStartupMessages(library(lawstat))
suppressPackageStartupMessages(library(e1071))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(magrittr))

main <- function(argv) {
  data <- read.table("../Data/shortleaf.txt",
    header = TRUE
  )
  print(head(data))
  print(skimr::skim(data))

  data %<>%
    mutate(lndiam = log(Diam))
  data %<>%
    mutate(lnvol = log(Vol))

  reg <- lm(Vol ~ Diam, data = data)
  print(reg)
  coefs <- reg$coefficients
  summ <- summary(reg)

  eqn <- paste(round(coefs["(Intercept)"], 4),
  sprintf("%+0.4f", round(coefs["Diam"], 4)), "Diam")
  with(data,
  plot(Diam, Vol,
       main = "Scatterplot: Volume versus Diameter",
       sub = eqn))
  labels <- c(paste0("Sigma: ", round(summ$sigma, 4)),
              paste0("R-squared: ", round(summ$r.squared, 4)),
              paste0("Adj R-squared: ", round(summ$adj.r.squared, 4)))
  with(data, {
  abline(reg, col = "red")
  lines(lowess(Diam, Vol),
        col = "blue")
  legend("topright", legend = labels)
  })
  plot(reg, which = 1,
  caption = "Residuals versus Fitted")

  residuals <- resid(reg)
  plot(data$Diam, residuals, xlab = "Diameter", main = "Residuals versus Diameter")
  abline(h = mean(residuals))

  probplot(residuals,
           probs = c(0.10, 0.25, 0.5, 0.75, 0.9, 0.99),
  xlab = "Residuals",
  ylab = "Probabilities (Percent)")

  ad <- nortest::ad.test(residuals)
  print(ad)
  labels <- c(paste0("Mean: ", round(mean(residuals), 4)),
  paste0("Stdev: ", round(sd(residuals), 2)),
  paste0("Count: ", round(length(residuals), 2)),
  paste0("AD: ", round(ad$statistic, 4)),
  paste0("p-value: ", round(ad$p.value, 4)))
  legend("bottomright", legend = labels)

  reg <- lm(Vol ~ lndiam, data = data)
  print(reg)
  coefs <- reg$coefficients
  summ <- summary(reg)

  eqn <- paste(round(coefs["(Intercept)"], 4),
  sprintf("%+0.4f", round(coefs["lndiam"], 4)), "lndiam")
  with(data,
  plot(lndiam, Vol,
       main = "Scatterplot: Volume versus log(Diam)",
       sub = eqn))
  labels <- c(paste0("Sigma: ", round(summ$sigma, 4)),
              paste0("R-squared: ", round(summ$r.squared, 4)),
              paste0("Adj R-squared: ", round(summ$adj.r.squared, 4)))
  with(data, {
  abline(reg, col = "red")
  lines(lowess(lndiam, Vol),
        col = "blue")
  legend("topright", legend = labels)
  })
  plot(reg, which = 1,
  caption = "Residuals versus Fitted")

  residuals <- resid(reg)
  plot(data$lndiam,
       residuals,
       xlab = "log(Diam)",
       main = "Residuals versus log(Diam)")
  abline(h = mean(residuals))

  probplot(residuals,
           probs = c(0.10, 0.25, 0.5, 0.75, 0.9, 0.99),
  xlab = "Residuals",
  ylab = "Probabilities (Percent)")

  ad <- nortest::ad.test(residuals)
  print(ad)
  labels <- c(paste0("Mean: ", round(mean(residuals), 4)),
  paste0("Stdev: ", round(sd(residuals), 2)),
  paste0("Count: ", round(length(residuals), 2)),
  paste0("AD: ", round(ad$statistic, 4)),
  paste0("p-value: ", round(ad$p.value, 4)))
  legend("bottomright", legend = labels)

  reg <- lm(lnvol ~ lndiam, data = data)
  print(reg)
  coefs <- reg$coefficients
  summ <- summary(reg)

  eqn <- paste(round(coefs["(Intercept)"], 4),
  sprintf("%+0.4f", round(coefs["lndiam"], 4)), "lndiam")
  with(data,
  plot(lndiam, lnvol,
       main = "Scatterplot: log(Volume) versus log(Diam)",
       sub = eqn))
  labels <- c(paste0("Sigma: ", round(summ$sigma, 4)),
              paste0("R-squared: ", round(summ$r.squared, 4)),
              paste0("Adj R-squared: ", round(summ$adj.r.squared, 4)))
  with(data, {
  abline(reg, col = "red")
  lines(lowess(lndiam, lnvol),
        col = "blue")
  legend("topright", legend = labels)
  })
  plot(reg, which = 1,
  caption = "Residuals versus Fitted")

  residuals <- resid(reg)
  plot(data$lndiam,
       residuals,
       xlab = "log(Diam)",
       main = "Residuals versus log(Diam)")
  abline(h = mean(residuals))

  probplot(residuals,
           probs = c(0.10, 0.25, 0.5, 0.75, 0.9, 0.99),
  xlab = "Residuals",
  ylab = "Probabilities (Percent)")

  ad <- nortest::ad.test(residuals)
  print(ad)
  labels <- c(paste0("Mean: ", round(mean(residuals), 4)),
  paste0("Stdev: ", round(sd(residuals), 2)),
  paste0("Count: ", round(length(residuals), 2)),
  paste0("AD: ", round(ad$statistic, 4)),
  paste0("p-value: ", round(ad$p.value, 4)))
  legend("bottomright", legend = labels)

  return(0)
}

if (identical(environment(), globalenv())) {
  quit(status = main(commandArgs(trailingOnly = TRUE)))
}