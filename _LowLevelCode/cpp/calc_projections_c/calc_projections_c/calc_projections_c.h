// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
// $Revision: 1524 $ $Date: 2017-09-27 15:48:11 +0100 (Wed, 27 Sep 2017) $

#ifndef H_CALC_PROJECTIONS_C
#define H_CALC_PROJECTIONS_C


#include "../../../build_all/CommonCode.h"


// $Revision: 1524 $ $Date: 2017-09-27 15:48:11 +0100 (Wed, 27 Sep 2017) $
enum eMode
{
  Elastic,
  Direct,
  Indirect
};
// the enum identifies the formats, output data (second output of the calc_projections function) can have
enum urangeModes
{
    noUrange,  // do not return any coordinates, output, if present will be empty
    urangeCoord,    // the the output will contain the array of 4d coordinates (4xnPixels array of transformed coordinates)
    urangePixels     // the the output will contain the array of pixels (9xnPixels array of pixels, including 
               // where each 9-element row contains 4 transformed coordinates, experiment ID (1 here), 
               // detector group number, energy bin number, pixels signal, pixels error squared)
};

void calc_projections_emode(double * const /*pMinMax */,
               double * const /*pTransfDetectors*/,
               eMode /*emode*/, urangeModes, /*mode */
               double const * const pSignal, double const * const pError,double const * const pDetGroup,
                             double const * const pMatrix,double const * const pEnergies, mwSize nEnergies,
                             double const * const pDetPhi,double const * const pDetPsi, mwSize nDetectors,
                 double efix, double k_to_e,int nThreads);
#endif