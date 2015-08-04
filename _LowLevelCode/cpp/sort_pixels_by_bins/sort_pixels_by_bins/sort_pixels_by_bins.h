#ifndef H_SORT_PIXELS_BY_BINS
#define H_SORT_PIXELS_BY_BINS

#include <float.h>
#include <limits>
#include <vector>
#include <sstream>
#include <cmath>
//#include <omp.h>

//
#include <mex.h>
#include <matrix.h>


#define iRound(x)  (int)floor((x)+0.5)

#define  PIXEL_DATA_WIDTH  9


// $Revision$ $Date$
template<class T, class N, class K>
void sort_pixels_by_bins( K * const pPixelSorted, size_t nPixelsSorted, std::vector<const T *> &PixelData, std::vector<size_t> &NPixels,
    std::vector<const N *> &PixelIndexes, std::vector<size_t> NIndexes,
    double const *const pCellDens, size_t distribution_size,    
    size_t *const ppInd) {


    ppInd[0] = 0;
    for (size_t i = 1; i < distribution_size; i++) {   // calculate the ranges of the cell arrays
        ppInd[i] = ppInd[i - 1] + (size_t)pCellDens[i - 1]; // the next cell starts from the the previous one
    };                                      // plus the number of pixels in the cell previous cell
    if (ppInd[distribution_size - 1] + (size_t)pCellDens[distribution_size - 1] != nPixelsSorted) {
        throw("Sort_pixels_by_bins: pixels data and their cell distributions are inconsistent ");
    }

    
    //#pragma omp parallel
    for(size_t nblock=0; nblock < PixelIndexes.size();nblock++)
    {
        size_t nBlockInd = NIndexes[nblock];
        const N* pCellInd = PixelIndexes[nblock];

        const T* pPixData= PixelData[nblock];

        for (size_t j = 0; j < nBlockInd ; j++) {    // sort pixels according to cells
            size_t i0 = j*PIXEL_DATA_WIDTH;
            size_t ind = (size_t)(pCellInd[j] - 1); // -1 as Matlab arrays start from one;
            size_t jBase = ppInd[ind] * PIXEL_DATA_WIDTH;
            ppInd[ind]++;

            for (size_t i = 0; i < PIXEL_DATA_WIDTH; i++) {  // copy all pixel data into the location requested
                pPixelSorted[jBase + i] = static_cast<K>(pPixData[i0 + i]);
            }
        }
    }

    
}


#endif