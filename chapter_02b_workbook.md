Vignette Title
================

-   [Problems](#problems)
    -   [Warm-up](#warm-up)
    -   [Meropenem PK](#meropenem-pk)
    -   [Z-Pak](#z-pak)
    -   [Output](#output)
-   [Answers](#answers)
    -   [Warm-up](#warm-up-1)
    -   [Meropenem PK](#meropenem-pk-1)
    -   [Z-Pak](#z-pak-1)
    -   [Output](#output-1)

Problems
========

Warm-up
-------

Choose a `PKPD` model from the internal model library (`?modlib_pkpd`) to explore

-   Check the parameter values (`param`)
-   Check the compartments and initial values (`init`)
-   Review the model code (\`see)

``` r
mod <- mread_cache("", modlib())
```

Extra credit: can you match up the output what what is going on in the code?

``` r
mod %>% mrgsim()
```

Meropenem PK
------------

-   Load the `meropenem` model from the model directory
-   Simulate the following scenarios:
    -   100 mg IV bolus q8h x 3
    -   100 mg IV over 3 hours q8h x3

Look at the `CP` output

Z-Pak
-----

You've been sick for the last two weeks and can't take it any more. Finally, you decide to go to the doctor, who gives you a diagnosis of walking pneumonia. When you get home with your azithromycin prescription, you start wondering about the directions: take 500 mg as a single dose on Day 1, followed by 250 mg once daily on Days 2 through 5.

Explore this regimen using the following model:

-   Model name: `azithro`
-   Model location: `model`

Simulate out to at least day 14 to see what is happening.

``` r
mod <- mread("", "") %>% zero_re
```

Output
------

Run the following code and check the output

``` r
mod <- mread_cache("azithro", "model")

out <- 
  mod %>% 
  ev(amt = 500) %>%
  mrgsim(end = 24, delta = 4)


out

class(out)

head(out)

out$CP

as.data.frame(out)

as_data_frame(out)

filter(out, time==12)

mutate(out, success = TRUE) %>% class
```

Answers
=======

Warm-up
-------

``` r
mod <- mread_cache("irm4", modlib())
```

    ## Compiling irm4 ... done.

``` r
param(mod)
```

    ## 
    ##  Model parameters (N=13):
    ##  name value . name value
    ##  CL   1     | KOUT 2    
    ##  EC50 2     | n    1    
    ##  EMAX 1     | Q    0    
    ##  KA1  0.5   | VC   10   
    ##  KA2  0.5   | VMAX 0    
    ##  KIN  10    | VP   10   
    ##  KM   2     | .    .

``` r
init(mod)
```

    ## 
    ##  Model initial conditions (N=5):
    ##  name       value . name         value
    ##  CENT (2)   0     | PERIPH (3)   0    
    ##  EV1 (1)    0     | RESP (4)     5    
    ##  EV2 (5)    0     | . ...        .

``` r
see(mod)
```

    ## 
    ## Model file:  irm4.cpp 
    ## $PARAM
    ## CL=1, VC=10, KA1=0.5, KA2=0.5
    ## Q = 0, VP=10
    ## KIN = 10, KOUT=2, EC50 = 2, EMAX=1
    ## VMAX = 0, KM=2, n=1
    ## 
    ## $CMT EV1 CENT PERIPH RESP EV2
    ## 
    ## $GLOBAL
    ## #define CP (CENT/VC)
    ## #define CT (PERIPH/VP)
    ## #define CLNL (VMAX/(KM+CP))
    ## #define STIM (EMAX*pow(CP,n)/(pow(EC50,n)+pow(CP,n)))
    ## 
    ## $MAIN
    ## RESP_0 = KIN/KOUT;
    ## 
    ## $ODE
    ## dxdt_EV1 = -KA1*EV1;
    ## dxdt_EV2 = -KA2*EV2;
    ## dxdt_CENT = KA1*EV1 + KA2*EV2 - (CL+CLNL+Q)*CP  + Q*CT;
    ## dxdt_PERIPH = Q*CP - Q*CT;
    ## dxdt_RESP = KIN - KOUT*(1+STIM)*RESP;
    ## 
    ## $CAPTURE CP

``` r
mod %>% mrgsim()
```

Meropenem PK
------------

``` r
mod <- mread_cache("meropenem", "model")
```

    ## Compiling meropenem ... done.

``` r
mod %>% 
  ev(amt = 100, ii = 8, addl = 2) %>% 
  mrgsim() %>%
  plot
```

![](chapter_02b_workbook_files/figure-markdown_github/unnamed-chunk-5-1.png)

``` r
mod <- mread_cache("meropenem", "model")
```

    ## Loading model from cache.

``` r
mod %>% 
  ev(amt = 100, ii = 8, rate = 100/3, addl = 2) %>% 
  mrgsim() %>%
  plot
```

![](chapter_02b_workbook_files/figure-markdown_github/unnamed-chunk-6-1.png)

Z-Pak
-----

``` r
mod <- mread("azithro", "model") %>% zero_re
```

    ## Compiling azithro ... done.

``` r
param(mod)
```

    ## 
    ##  Model parameters (N=8):
    ##  name value . name value
    ##  KA   0.259 | TVV1 186  
    ##  Q3   10.6  | TVV2 2890 
    ##  TVCL 100   | V3   2610 
    ##  TVQ2 180   | WT   70

``` r
param(mod)$TVV1 + param(mod)$TVV2
```

    ## [1] 3076

Set up an dosing event

``` r
load <- ev(amt = 500, ii = 24,  addl = 0)
maint <- ev(amt = 250, ii = 24, addl = 3)
dose <- seq(load, maint)

mod %>% 
  ev(dose) %>%
  mrgsim (end = 24*21) %>% 
  plot(CP + PER2 + PER3 ~time/24)
```

![](chapter_02b_workbook_files/figure-markdown_github/unnamed-chunk-7-1.png)

Output
------

``` r
mod <- mread_cache("azithro", "model")
```

    ## Compiling azithro ... (waiting) ...
    ## done.

``` r
out <- 
  mod %>% 
  ev(amt = 500) %>%
  mrgsim(end = 24, delta = 4)

out
```

    ## Model:  azithro 
    ## Dim:    8 x 7 
    ## Time:   0 to 24 
    ## ID:     1 
    ##      ID time      GUT  CENT  PER2  PER3     CP
    ## [1,]  1    0   0.0000  0.00   0.0  0.00   0.00
    ## [2,]  1    0 500.0000  0.00   0.0  0.00   0.00
    ## [3,]  1    4 177.4357 39.46 198.5 13.06 262.42
    ## [4,]  1    8  62.9668 21.97 277.5 21.05 146.10
    ## [5,]  1   12  22.3451 15.23 292.4 25.77 101.29
    ## [6,]  1   16   7.9296 12.37 285.4 29.16  82.30
    ## [7,]  1   20   2.8140 10.93 271.4 31.93  72.67
    ## [8,]  1   24   0.9986 10.01 255.7 34.33  66.56

``` r
class(out)
```

    ## [1] "mrgsims"
    ## attr(,"package")
    ## [1] "mrgsolve"

``` r
head(out)
```

    ##   ID time        GUT     CENT     PER2     PER3        CP
    ## 1  1    0   0.000000  0.00000   0.0000  0.00000   0.00000
    ## 2  1    0 500.000000  0.00000   0.0000  0.00000   0.00000
    ## 3  1    4 177.435666 39.45744 198.4662 13.06208 262.42189
    ## 4  1    8  62.966831 21.96791 277.4826 21.04728 146.10325
    ## 5  1   12  22.345123 15.22947 292.3891 25.76579 101.28752
    ## 6  1   16   7.929644 12.37389 285.3878 29.15888  82.29574

``` r
out$CP
```

    ## [1]   0.00000   0.00000 262.42189 146.10325 101.28752  82.29574  72.67145
    ## [8]  66.56097

``` r
as.data.frame(out)
```

    ##   ID time         GUT     CENT     PER2     PER3        CP
    ## 1  1    0   0.0000000  0.00000   0.0000  0.00000   0.00000
    ## 2  1    0 500.0000000  0.00000   0.0000  0.00000   0.00000
    ## 3  1    4 177.4356660 39.45744 198.4662 13.06208 262.42189
    ## 4  1    8  62.9668313 21.96791 277.4826 21.04728 146.10325
    ## 5  1   12  22.3451232 15.22947 292.3891 25.76579 101.28752
    ## 6  1   16   7.9296436 12.37389 285.3878 29.15888  82.29574
    ## 7  1   20   2.8140031 10.92679 271.4229 31.92838  72.67145
    ## 8  1   24   0.9986091 10.00803 255.7436 34.33409  66.56097

``` r
as_data_frame(out)
```

    ## # A tibble: 8 x 7
    ##      ID  time     GUT  CENT  PER2  PER3    CP
    ##   <dbl> <dbl>   <dbl> <dbl> <dbl> <dbl> <dbl>
    ## 1  1.00  0      0       0       0   0     0  
    ## 2  1.00  0    500       0       0   0     0  
    ## 3  1.00  4.00 177      39.5   198  13.1 262  
    ## 4  1.00  8.00  63.0    22.0   277  21.0 146  
    ## 5  1.00 12.0   22.3    15.2   292  25.8 101  
    ## 6  1.00 16.0    7.93   12.4   285  29.2  82.3
    ## 7  1.00 20.0    2.81   10.9   271  31.9  72.7
    ## 8  1.00 24.0    0.999  10.0   256  34.3  66.6

``` r
filter(out, time==12)
```

    ## # A tibble: 1 x 7
    ##      ID  time   GUT  CENT  PER2  PER3    CP
    ##   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
    ## 1  1.00  12.0  22.3  15.2   292  25.8   101

``` r
mutate(out, success = TRUE) %>% class
```

    ## [1] "tbl_df"     "tbl"        "data.frame"
