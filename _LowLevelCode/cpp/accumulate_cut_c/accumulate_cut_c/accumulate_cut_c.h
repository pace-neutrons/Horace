#ifndef H_ACCUMULATE_CUT
#define H_ACCUMULATE_CUT

//#include "targetver.h"

//#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files:
//#include <windows.h>

// TODO: reference additional headers your program requires here
#include <float.h>
#include <limits>
#include <sstream>
#include <cmath>
#include <omp.h>
//
#include <mex.h>
#include <matrix.h>
#include <cfloat>

#define iRound(x)  (int)floor((x)+0.5)




mwSize accumulate_cut(double *s, double *e, double *npix,
					double const* pixel_data,size_t data_size,
                    mxLogical *ok,mxArray *&ix_final_pixIndex,double *actual_pix_range,
					double const* rot_ustep,double const* trans_bott_left,double ebin,double trans_elo, // transformation matrix
					double const* cut_range,
					mwSize grid_size[4],	int const *iAxis,int nAxis, 
					double const* pProg_settings);

#endif