library(mrgsolve)
library(tidyverse)
## load the model file that we have written
mod <- mread("simple")
omat(mod)
revar(mod)

## reserved words to avoid in model code: 
## mrgsolve:::Reserved

set.seed(651)
mrgsim(mod, events = ev(amt = 100)) %>%
  plot

###############Sensitivity analysis of WT################

mod <- mread("simple") %>% zero_re
## zero_re() sets random effects to zero
omat(mod)

idata <- expand.idata(WT = seq(40, 140, 10))

out <- 
  mod %>%
  idata_set(idata) %>%
  ev(amt=100) %>%
  mrgsim()

plot(out)

#########Looking at error model#######################

mod <- mread("simple")

idata <- expand.idata(WT = seq(40, 140, 10))

out <- 
  mod %>%
  idata_set(idata) %>%
  ev(amt=100) %>%
  mrgsim() %>%
  plot

#############editing RE matrices on the fly################
## diagonal matrix
mat <- dmat(1,2)
## correlation matrix
mat <- cmat(1,0.5,2)
## equivalent smat() for sigma matrix
mod <- omat(mod, mat)
revar(mod)

#################mero model####################
mod <- mread("mero")

data <- as_data_set(
  ev(amt = 1000, rate = 1000/0.5, ID = 1:50),
  ev(amt = 1000, rate = 1000/3,   ID = 1:50)
) %>% mutate(DUR = amt/rate)

out <- 
  mod %>%
  data_set(data) %>%
  carry_out(DUR) %>%
  mrgsim(end = 8, delta = 0.1) %>%
  as_data_frame

summ <- 
  out %>%
  filter(Y>0) %>%
  group_by(time, DUR) %>%
  summarise(med = median(Y), 
            lo = quantile(Y, 0.025),
            hi = quantile(Y, 0.975))

ggplot(data = summ) +
  geom_ribbon(aes(x = time, ymin = lo, ymax = hi), 
                  col = "darkslateblue", alpha = 0.5) + 
  facet_wrap(~DUR)
