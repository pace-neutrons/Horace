#pragma once

#include "../CommonCode.h"

template <class T>
void compute_pix_sums(double *const pSignal, double *const pVariance,
                        size_t distr_size, double const *const pNpix,
                        T const *const pPixelData, size_t nPixels,
                        int num_OMP_Threads) {

  omp_set_num_threads(num_OMP_Threads);
  size_t pixProcessed = 0;
  std::vector<size_t> cumSumData;
  bool multithreaded(false);
  if (num_OMP_Threads > 1) {
    multithreaded = true;
    cumSumData.resize(distr_size + 1);
    cumSumData[0] = 0;
    for (size_t i = 1; i <= distr_size; i++) {
      cumSumData[i] = cumSumData[i - 1] + size_t(pNpix[i - 1]);
    }
  }

#pragma omp parallel
  {
#pragma omp for
    for (long i = 0; i < distr_size; i++) {
      pSignal[i] = 0;
      pVariance[i] = 0;
    }
#pragma omp for
    for (long i = 0; i < distr_size; i++) {
      size_t npix_in_bin = (size_t)pNpix[i];
      size_t pix0;
      if (multithreaded) {  // multithreaded mode
        pix0 = cumSumData[i];
      } else {  // single threaded mode
        pix0 = pixProcessed;
        pixProcessed += npix_in_bin;
      }
      for (size_t ip = 0; ip < npix_in_bin; ip++) {
        size_t index = (pix0 + ip) * pix_fields::PIX_WIDTH;
        pSignal[i] += pPixelData[index + pix_fields::iSign];
        pVariance[i] += pPixelData[index + pix_fields::iErr];
      }
    }
  } // end parallel block
}
