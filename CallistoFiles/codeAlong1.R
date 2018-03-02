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
