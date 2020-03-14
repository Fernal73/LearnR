#!/usr/bin/env Rscript
library(deSolve)
library(readr)

# nolint start
SIR <- function(time, state, parameters) {
  par <- as.list(c(state, parameters))
  with(par, {
    dS <- -beta / N * I * S
    dI <- beta / N * I * S - gamma * I
    dR <- gamma * I
    list(c(dS, dI, dR))
  })
}
# nolint end

main <- function(argv) {
  data <- readr::read_csv("world_data.csv")
  infected <- data$confirmed
  recovered <- data$recovered
  dates <- data$date

  init <- c(S = N - infected[1], I = infected[1], R = 0)

  # nolint start
  RSS <- function(parameters) {
    names(parameters) <- c("beta", "gamma")
    out <-
      deSolve::ode(
        y = init,
        times = seq(length(dates)), func = SIR, parms = parameters
      )
    fit <- out[, 3]
    sum((infected - fit)^2)
  }
  # nolint end

  # optimize with some sensible conditions
  opt <- optim(c(0.5, 0.5), RSS,
    method = "L-BFGS-B", lower = c(0, 0), upper =
      c(1, 1)
  )
  print(opt$message)
  ## [1] "CONVERGENCE: REL_REDUCTION_OF_F <= FACTR*EPSMCH"

  opt_par <- setNames(opt$par, c("beta", "gamma"))
  print(opt_par)
  ##      beta     gamma
  ## 0.6746089 0.3253912

  # time in days
  t <- 1:365
  fit <- data.frame(
    deSolve::ode(
      y = init, times = t, func = SIR, parms =
        opt_par
    )
  )
  # colour
  col <- 1:3

  matplot(fit$time, fit[, 2:4], type = "l", xlab = "Day", ylab = "Number of
          subjects", lwd = 2, lty = 1, col = col)
  matplot(fit$time, fit[, 2:4], type = "l", xlab = "Day", ylab = "Number of
          subjects", lwd = 2, lty = 1, col = col, log = "y")
  ## Warning in xy.coords(x, y, xlabel, ylabel, log = log): 1 y value <= 0
  ## omitted from logarithmic plot

  points(seq(length(dates)), infected)
  legend("bottomright", c("Susceptibles", "Infecteds", "Recovereds"),
    lty = 1,
    lwd = 2, col = col, inset = 0.05
  )
  title("SIR model 2019-nCoV World", outer = TRUE, line = -2)

  # nolint start
  R0 <- setNames(opt_par["beta"] / opt_par["gamma"], "R0")
  # nolint end
  print(R0)

  fit[fit$I == max(fit$I), "I", drop = FALSE] # height of pandemic

  print(max(fit$I) * 0.02)
  # max deaths with supposed 2% fatality rate
  return(0)
}

# nolint start
# world population 7.7 billion
N <- 7700000000
# nolint end
if (identical(environment(), globalenv())) {
  quit(status = main(commandArgs(trailingOnly = TRUE)))
}