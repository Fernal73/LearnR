#!/usr/bin/env Rscript
library(stats)
library(graphics)
## give the data set in the form it is used in S-PLUS:
longley.x <- data.matrix(longley[, 1:6])
longley.y <- longley[, "Employed"]
longley$RealGNP <- with(longley, GNP * 100 / GNP.deflator)
longley[1:8, ]
pairs(longley, main = "longley data")
summary(fm1 <- lm(Employed ~ ., data = longley))
opar <- par(
  mfrow = c(2, 2),
  oma = c(0, 0, 1.1, 0),
  mar = c(4.1, 4.1, 2.1, 1.1)
)
plot(fm1)
par(opar)
rm(list = ls())
