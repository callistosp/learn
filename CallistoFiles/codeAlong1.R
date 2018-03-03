library(mrgsolve)

mod <- mread("simple", "model")

## if already run, use this to not compile again ()
mod <- mread_cache("simple", "model")

## can also load from model library instead of self-written models
mod <- mread("pk1", modlib())


## you can write a model on the fly, but this is bad practice!!!
## instead, load from a .cpp file as we are doing above
code <- '
$PARAM CL=1, V=20
$PKMODEL cmt="CENT"
'
mod <- mcode("DONT_DO_THIS", code)

data <- as_data_set(
  ev(amt = 100, ii = 12, addl = 19, ID = 1:2),  ## ID always starts from 1, even if multiple!!!
  ev(amt = 200, ii = 24, addl = 9,  ID = 1:3), 
  ev(amt = 150, ii = 24, addl = 9,  ID = 1:4)
)
data

################ WEEK 2 #####################
library(mrgsolve)
library(tidyverse)


mod <- mread_cache("pk1", modlib())

# x <- as.list(mod)
# x$pars
# x$cmt
# x$param
# names(param(mod))

mod %>%
  # ev(amt = 100, ii=8, addl=2, rate = 100/4, cmt = 2) %>%
  ev(amt = 100) %>%
  param(CL=1) %>%
  Req(CP) %>%
  obsonly() %>%
  mrgsim(end = 72, delta = 0.1) %>%
  # as_data_frame()
  plot()

## create individuals for the simulation
# idata <- data_frame(CL = seq(0.5, 1.5, 0.1))
## alternative helper function that automatically adds ID columns
idata <- expand.idata(CL = seq(0.5, 1.5, 0.1))

mod %>%
  ev(amt = 100) %>%
  ## built in filter functions for idata_set
  # idata_set(idata, CL>1) %>%
  idata_set(idata, ID>5) %>%
  mrgsim(end = 72, delta = 0.1) %>%
  plot()

## other helper functions for quick creation of datasets
data <- expand.ev(amt = c(100,300,1000), 
                  CL = c(0.5, 1, 1.5))
## amt is a special column name in mrgsolve, so if you want to carry_out, need to change the name
data <- mutate(data, dose=amt)

## model with dataset instead; used to explore
## lots of different doses and clearances, rather than individual variability
mod %>%
  data_set(data) %>%
  ## req only shows CP plot, rather than all cmts
  Req(CP) %>%
  ## carry_out pulls the CL values into the dataset for plotting purposes
  carry_out(CL, dose) %>%
  mrgsim(end = 72, delta = 0.1) %>%
  ## | to facet by CL in plot, set same scales for all plots
  plot(CP ~ time|factor(dose), scales = "same")

mod %>%
  ev(amt = 100, dose=100) %>%
  carry_out(amt, ss, evid, dose) %>%
  mrgsim(end = 72, delta = 0.1)
## amt only carried out for dosing event

out <- mrgsim(mod)
saveRDS(file = "sim.RDS", out, compress = F)
x <- readRDS(file = "sim.RDS")
## save the R object as an R object, rather than as a CSV. 
## Keeps format and everything associated with it.

mod <- mread_cache("pk1", modlib(), 
                   soloc = getwd())
## build the model in your working directory, and saves all them in your WD
## soloc defaults to tempdir()
mod <- update(mod, atol = 1E-20,
              rtol = 1E-16)
## in nonmem, the scale is opposite. Also sets them both to be the same.
## as this gets SMALLER it is more precise
## rtol determines what the value of the parameter is (closer to closed form solution value)
## TOL in NONMEM is what the negative exponent is (e.g. TOL(atol) = 20)
## atol is related to the tolerance on your machine. 
## Smaller TOLs (further from zero) may give negative predictions b/c of lack of precision

mod %>%
  ev(amt = 100, ss = 1, ii = 24, addl = 1) %>%
  mrgsim(recsort = 3, end = 120) %>% 
  plot
## use recsort for whether observation occurs before or after dosing
## defaults to obs pre-dose, recsort = 3 performs obs after dosing