// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
// $Revision$ $Date$

#ifndef H_CALC_PROJECTIONS_C
#define H_CALC_PROJECTIONS_C



#include <float.h>
#include <limits>
#include <sstream>
#include <cmath>
#include <omp.h>
//
#include <mex.h>
#include <matrix.h>


// $Revision$ $Date$
enum eMode
{
	Elastic,
	Direct,
	Indirect
};


void calc_projections_emode(double * const /*pMinMax */,
							 double * const /*pTransfDetectors*/,
							 eMode /*emode*/,
							 double const * const pSignal, double const * const pError,double const * const pDetGroup,
                             double const * const pMatrix,double const * const pEnergies, mwSize nEnergies,
                             double const * const pDetPhi,double const * const pDetPsi, mwSize nDetectors,
						     double efix, double k_to_e,int nThreads);
#endif