#!/usr/bin/env Rscript
library(graphics)
dotchart(log(islands, 10),
  main = "islands data: log10(area) (log10(sq. miles))"
)
dotchart(log(islands[order(islands)], 10),
  main = "islands data: log10(area) (log10(sq. miles))"
)
