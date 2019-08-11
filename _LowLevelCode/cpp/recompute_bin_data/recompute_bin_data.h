#ifndef H_RECOMPUTE_BIN_DATA
#define H_RECOMPUTE_BIN_DATA

#include "../../build_all/CommonCode.h"

#include <sstream>
#include <memory>
//
// $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)" 
//

template<class T>
void recompute_pix_sums(double *const pSignal, double *const pError, size_t distr_size,
    double const *const pNpix, T const *const pPixelData, size_t nPixels, int num_OMP_Threads)
{


    omp_set_num_threads(num_OMP_Threads);
    size_t pixProcessed = 0;
    std::vector<size_t> cumSumData;
    bool multithreaded(false);
    if (num_OMP_Threads > 1) {
        multithreaded = true;
        cumSumData.resize(distr_size+1);
        cumSumData[0] = 0;
        for (size_t i = 1; i <= distr_size; i++) {
            cumSumData[i] = cumSumData[i - 1] + size_t(pNpix[i-1]);
        }
    }

#pragma omp parallel
    {
#pragma omp for
        for (long i = 0; i < distr_size; i++) {
            pSignal[i] = 0;
            pError[i] = 0;
        }
#pragma omp for
        for (long i = 0; i < distr_size; i++) {
            size_t npixels = (size_t)pNpix[i];
            size_t pix0;
            if (multithreaded) { // multithreaded mode
                pix0 = cumSumData[i];
            }
            else { // single threaded mode
                pix0 = pixProcessed;
                pixProcessed += npixels;
            }
            for (size_t ip = 0; ip < npixels; ip++) {
                size_t index = (pix0 + ip)*pix_fields::PIX_WIDTH;
                pSignal[i] += pPixelData[index + pix_fields::iSign];
                pError[i] += pPixelData[index + pix_fields::iErr];
            }
        }
#pragma omp for
        for (long i = 0; i < distr_size; i++) {
            double nPix = pNpix[i];
            if (nPix > 0) {
                pSignal[i] /= nPix;
                pError[i] /= (nPix*nPix);
            }
        }
    } // end parallel block
};





#endif

