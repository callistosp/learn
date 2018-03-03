// Source MD5: 227a7897844e72a95f7e950b23dc134d


// FIXED:
// No fixed parameters.

// INCLUDES:
// No includes found.

// NAMESPACES:

// BASIC MODELHEADER FILE:
#include "modelheader.h"

// GLOBAL CODE BLOCK:
// GLOBAL VARS FROM BLOCKS & TYPEDEFS:

// GLOBAL START USER CODE:
#define CP (CENT/V)

// DEFS:
#define __INITFUN___ _model_pk1_main__
#define __ODEFUN___ _model_pk1_ode__
#define __TABLECODE___ _model_pk1_table__
#define __CONFIGFUN___ _model_pk1_config__
#define __REGISTERFUN___ R_init_pk1
#define _nEQ 2
#define _nPAR 3
#define EV _A_[0]
#define CENT _A_[1]
#define EV_0 _A_0_[0]
#define CENT_0 _A_0_[1]
#define dxdt_EV _DADT_[0]
#define dxdt_CENT _DADT_[1]
#define CL _THETA_[0]
#define V _THETA_[1]
#define KA _THETA_[2]

// PREAMBLE CODE BLOCK:
__BEGIN_config__
__END_config__

// MAIN CODE BLOCK:
__BEGIN_main__
__ADVAN2_TRANS2__
__END_main__

// DIFFERENTIAL EQUATIONS:
__BEGIN_ode__
DXDTZERO();
__END_ode__

// TABLE CODE BLOCK:
__BEGIN_table__
_capture_[0] = CP;
__END_table__
