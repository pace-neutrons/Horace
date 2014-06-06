#ifndef H_SORT_PIXELS_BY_BINS
#define H_SORT_PIXELS_BY_BINS

#include <float.h>
#include <limits>
#include <sstream>
#include <cmath>
#include <omp.h>
//
#include <mex.h>
#include <matrix.h>

#define iRound(x)  (int)floor((x)+0.5)


// $Revision$ $Date$
void sort_pixels_by_bins(double const *const pPixelData,size_t nDataRows,size_t nDataCols,double const *const pCellInd,
                         double const *const pCellDens,size_t distribution_size,
                         size_t * const ppInd,double *const pPixelSorted);
#endif