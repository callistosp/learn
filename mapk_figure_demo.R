library(rbenchmark)
library(mrgsolve)
library(dmutate)
library(tidyverse)
library(magrittr)

source("functions.R")

mod <- mread("mapk", "model")

vp <- readRDS("data/s10vpop_pk.RDS")

sim <- function(Data,Vp,Mod, label = -9) {
  Mod %>%
    ev(as.ev(Data)) %>%
    mrgsim(idata=vp,end=-1, add = 56) %>%
    filter(time==56) %>% mutate(label = label)
}
comb <- function(...) {
  x <- lapply(list(...), as.data.frame)
  bind_rows(x) %>% arrange(time)
}

# CETUX_dose = 450;   %mg, weekly
# VEMU_dose = 960;    %mg, BID
# COBI_dose = 60;     %mg, daily
# GD ERKI_dose = 400;    %mg, daily 

##' Nothing
data0 <- data_frame(amt=0,evid=1,cmt=8,time=0)

##' BFRAF-i CMT 8  - vemurafanib VEMU
dataV <- data_frame(amt=960, evid=1, cmt=8, ii=0.5, addl=120, time=0)

##' ERKi CMT 12 - GDC-0994 
dataG <- ev(amt = 400, cmt = 12, ii = 1, addl = 20)
dataG <- seq(dataG, wait = 7, dataG)

out <- mrgsim(mod, ev=dataG, end=56)
plot(out, ERKi~time)

## MEKi CMT 10 - cobimetinib COBI
dataCO <- mutate(dataG,amt=60,cmt=10)

##' EGFR CMT 7 - cetuximab CETUX
dataCE <- data_frame(time=0,cmt=7,ii=7,addl=7,evid=1,amt=450)


benchmark(
  mrgsim(mod, ev = as.ev(dataCE), end = -1, add = 56),
  mrgsim(mod, ev = dataG, end = -1, add = 56), 
  mrgsim(mod, ev = as.ev(dataV), end = -1, add = 56), 
  replications = 100
)

comb(dataCE,dataV)


sim1 <- data0  %>% sim(vp, mod, 1) 
sim2 <- dataCE %>% sim(vp, mod, 2) 
sim3 <- dataV  %>% sim(vp, mod, 3) 
sim4 <- dataCO %>% sim(vp, mod, 4) 
sim5 <- dataG  %>% sim(vp, mod, 5) 

sim23 <- comb(dataCE, dataV)  %>% sim(vp, mod, 23) 
sim24 <- comb(dataCE, dataCO) %>% sim(vp, mod, 24) 
sim25 <- comb(dataCE, dataG)  %>% sim(vp, mod, 25) 
sim34 <- comb(dataV,  dataCO) %>% sim(vp, mod, 34) 
sim35 <- comb(dataV,  dataG)  %>% sim(vp, mod, 35) 
sim45 <- comb(dataCO, dataG)  %>% sim(vp, mod, 45) 

sim234 <- comb(dataCE, dataV,  dataCO) %>% sim(vp, mod, 234) 
sim235 <- comb(dataCE, dataV,  dataG)  %>% sim(vp, mod, 235) 
sim245 <- comb(dataCE, dataCO, dataG)  %>% sim(vp, mod, 246)
sim345 <- comb(dataV,  dataCO, dataG)  %>% sim(vp, mod, 354)

sim2345 <- comb(dataCE,dataV,dataCO,dataG) %>% sim(vp, mod, 2345)


lab <- c("No TREAT", "CETUX", "VEMU", "COBI", "GDC",
         "CETUX+VEMU", "CETUX+COBI", "CETUX+GDC", "VEMU+COBI","VEMU+GDC", 
         "COBI+GDC", "CETUX+VEMU+COBI", "CETUX+VEMU+GDC", "CETUX+COBI+GDC", 
         "VEMU+COBI+GDC","CETUX+VEMU+COBI+GDC")

sims <- bind_rows(sim1,sim2,sim3,sim4,sim5,sim23,sim24,sim25,sim34,
                  sim35,sim45,sim234,sim235,sim245,sim345,sim2345)

ulab <- unique(sims$label)
sims %<>% mutate(labelf = factor(label,levels=ulab,labels=as.character(ulab)))
sims %<>% mutate(labelff = factor(label,levels=ulab,labels=lab))


p1 <- 
  ggplot(data=sims) + 
  geom_point(aes(x=labelff, y=TUMOR),position=position_jitter(width=0.15),col="grey") +
  scale_y_continuous(limits=c(0,2.5),name="Tumor size",breaks=c(0,0.5,1,1.5,2,2.5,3)) +
  scale_x_discrete(name="") + 
  geom_hline(yintercept=0.7,col="firebrick", lty=1,lwd=1)  +
  geom_boxplot(aes(x=labelff,y=TUMOR),fill="darkslateblue",col="darkslateblue",alpha=0.2) +
  theme_plain() + rotx(30)

p1
