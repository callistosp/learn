// Li et al. Population pharmacokinetic analysis of meropenem
// Model obtained from ddmore Model library
$PKMODEL cmt = "CENT PERIPH"

$PARAM
AGE = 35

$THETA
//1.50E+01  1.27E+01  1.52E+01  1.24E+01 -4.47E-01  8.20E-01  1.88E-01  4.76E-01  6.20E-01
1.5 1.27 1.52 1.24 -0.447 0.82 0.188 0.476 0.620

//$NMXML // NONMEM XML Import
//run = 1001
//proj = "C:\Users\Sam\Documents\GitHub\learn\nonmem\meropenem\"
//proj = "nonmem/meropenem"

$MAIN 
double CL = THETA1 * pow(AGE/35, THETA5) * exp(ETA(1));
double V1 = THETA2 * exp(ETA(2));
double Q = THETA3 * exp(ETA(3));
double V2 = THETA4 * exp(ETA(4));

$TABLE
double RUV_PROP = THETA7;
double RUV_ADD = THETA8;
double IPRED = (CENT/V1);
double W = sqrt((RUV_ADD*RUV_ADD)+ (RUV_PROP*RUV_PROP*IPRED*IPRED));
capture Y = IPRED+W*EPS(1);