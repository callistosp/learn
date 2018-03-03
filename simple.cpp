// can also use $PROB or $PROBLEM, but R likes the [] style better
// order of blocks does NOT matter in C++
$PROB
This is a simple model!

// markdown format
# My model
- one compartment
- no iiv

$PARAM TVCL = 1, TVV = 20, KA = 1.1
WT = 70, FLAG = 0
WTonCL = 0.75, BASE = 0

$GLOBAL
// way to add C++ code that is accessible throughout model
int flag = 1;
// kyles uses this mostly for preprocessor directive loading
#define CP (CENT/V)

$CMT GUT CENT
// assumes all compartments start at zero
// dose will go to first listed compartment (GUT) by default

// ODE is the first C++ code that we are writing
// the above syntax was just made up by kyle

$MAIN // PK equivalent in NONMEM
double CL = TVCL * pow(WT/70, WTonCL) * exp(ETA(1));
double V = TVV * exp(ETA(2));

// setting initial conditions for a compartment
// can set equal to a parameter so we can control it later on
CENT_0 = BASE;

// equivalent to F1 in NONMEM
F_GUT = 0.5;

// equivalent to ALAG1 in NONMEM
ALAG_GUT = 0.25;

$OMEGA
0.04 // CL
0.09 // V

$ODE // DES equivalent in NONMEM

dxdt_GUT = -KA*GUT;
dxdt_CENT = KA*GUT - (CL/V)*CENT;

$SIGMA 0.2

$TABLE  // ERROR equivalent in NONMEM
// capture assumes type double, and automatically adds to capture block
// capture CP = CENT/V;
// don't need to define here if use #define in #GLOBAL
capture DAY = floor(TIME/24) + 1;
// other types: double, int, bool
capture DV = CP*exp(EPS(1));

$CAPTURE // TABLE equivalent in NONMEM
CP CL