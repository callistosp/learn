########################################
##
## UMN/Metrum Advanced R Workshop
## Pre-workshop Package Install Script
##
## For additional information regarding mrgsolve installation, please visit
## https://github.com/metrumresearchgroup/mrgsolve/wiki/mrgsolve-Installation
## 
## For Mac users encountering errors trying to install RcppArmadillo, please visit
## https://github.com/RcppCore/RcppArmadillo/issues/71
##
## 24 February 2018
########################################

## Do not run the next two lines of code for Mac installs
install.packages(c("installr"))
installr::updateR()
installr::install.Rtools()
## Choose Rtools version 32

## install necessary packages for workshop
## Mac users: if prompted to install Command Line Developer Tools, click "Install"
install.packages(c("tidyverse", "rmarkdown", "lattice", "devtools"))

devtools::install_github("metrumresearchgroup/mrgsolve", type="source", force=T)

## update system environment variable path
cat('Sys.setenv(BINPREF = "C:/RBuildTools/3.4/mingw_$(WIN)/bin/")', 
    file = file.path(Sys.getenv("HOME"), ".Rprofile"), sep = "\n", append = TRUE)

## test package install
library(mrgsolve)

mod <- mread("pk1", modlib())

## if output reads "Compiling example ... done.", you are all set!
## if not, please consult the GitHub link at the top of the document