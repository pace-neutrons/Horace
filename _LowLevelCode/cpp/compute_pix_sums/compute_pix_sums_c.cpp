#include "compute_pix_sums_helpers.h"
#include "compute_pix_sums.h"
#include "../utility/version.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  // Return version if no arguments
  if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
    plhs[0] = mxCreateString(Horace::VERSION);
    return;
  }

  /***************************************************************************/
  /* Handle inputs */
  validate_inputs(nlhs, plhs, nrhs, prhs);

  // npix can be 1-D to 4D double array
  const double *const pNpix = get_npix_array(prhs);

  const double *const pPixelData = get_pixel_array(prhs);

  const int n_threads = get_num_threads(prhs);

  mxClassID pix_data_class{mxGetClassID(prhs[Pixel_data])};

  const std::size_t nPixels = mxGetN(prhs[Pixel_data]);

  /***************************************************************************/
  /* Define outputs */
  mwSize num_of_dims = mxGetNumberOfDimensions(prhs[Npix_data]);
  const mwSize *p_dims = mxGetDimensions(prhs[Npix_data]);

  double *pSignal = get_output_signal_ptr(num_of_dims, p_dims, plhs);
  double *pVariance = get_output_variance_ptr(num_of_dims, p_dims, plhs);

  /***************************************************************************/
  /* Do calculations */
  std::size_t distr_size{1};
  for (std::size_t i = 0; i < num_of_dims; i++) {
    distr_size *= std::size_t(p_dims[i]);
  }

  try {
    if (pix_data_class == mxDOUBLE_CLASS) {
      compute_pix_sums<double>(pSignal, pVariance, distr_size, pNpix,
                                 pPixelData, nPixels, n_threads);
    } else if (pix_data_class == mxSINGLE_CLASS) {
      float const *const fPixData = (float *)pPixelData;
      compute_pix_sums<float>(pSignal, pVariance, distr_size, pNpix, fPixData,
                                nPixels, n_threads);
    } else {
      throw("Invalid data type for pixel array. Must be float or double.");
    }
  } catch (const char *err) {
    mexErrMsgTxt(err);
  }
}
