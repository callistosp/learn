library(mrgsolve)
library(tidyverse)

mod <- mread_cache("opg", "model")

post <- readRDS("data/opgpost.RDS") %>% 
  ## only grab 300 patients from the full RDS file
  sample_n(300)

mod <- zero_re(mod)
revar(mod)

## can use purrr(?) instead of lapply
## doing a simulation to look at the profile to determine uncertainty in the parameters
## shortcut to doing large number of replicate simulations to save time
out <- lapply(1:100, function(i){
  mod %>% 
    ev(amt = 210) %>%
    param(slice(post, i)) %>% ## for each parameter, slice off i-th row of the posterior
    Req(DV = PKDV) %>%
    mrgsim(end = 24*14, delta = 0.2) %>%
    mutate(irep = i)
}) %>% bind_rows()

summ <- 
  out %>%
  group_by(time) %>%
  summarize(med = median(DV),
            lo = quantile(DV, 0.025),
            hi = quantile(DV, 0.975))
## write summarize wrapper function to auto-generate 90% and 95%

ggplot(data = summ) +
  geom_ribbon(aes(time, ymin=lo, ymax=hi), alpha = 0.6) + 
  geom_line(aes(time, med), lwd=1)

############## same exercise with PD instead #####################################

data <- expand.ev(amt = c(0.3, 1, 3) * 70, time = 4*24) %>% mutate(dose = amt)

out2 <- lapply(1:100, function(i){
  mod %>% 
    ## 1 week lead-in period to see changes after dosing starts
    #ev(amt = 210, time = 7*24) %>%
    ## use data event instead
    data_set(data) %>%
    param(slice(post, i)) %>% ## for each parameter, slice off i-th row of the posterior
    Req(DV = PDDV) %>%
    carry_out(dose) %>%
    mrgsim(end = 24*28, delta = 0.2) %>%
    mutate(irep = i)
}) %>% bind_rows()

summ2 <- 
  out2 %>%
  group_by(time, dose) %>%
  summarize(med = median(DV),
            lo = quantile(DV, 0.025),
            hi = quantile(DV, 0.975))
## TODO: write summarize wrapper function to auto-generate 90% and 95%

ggplot(data = summ2) +
  geom_ribbon(aes(time, ymin=lo, ymax=hi), alpha = 0.6) + 
  geom_line(aes(time, med), lwd=1) + 
  facet_grid(~dose)

## Dick's question: why is there so much variability in the baseline?
readRDS("data/opgpost.RDS") %>% 
  select(contains("TV")) %>%
  gather(variable, value, TVCL:TVIC50) %>%
  group_by(variable) %>%
  summarize(CV = sd(value)/mean(value))
