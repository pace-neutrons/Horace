#include "recompute_bin_data/recompute_bin_data_c.h"
#include "recompute_bin_data/recompute_pix_sums.h"
#include "utility/version.h"

enum InputArguments { Npix_data, Pixel_data, Num_threads, N_INPUT_Arguments };
enum OutputArguments { // unique output arguments,
  Signal,
  Error,
  N_OUTPUT_Arguments
};

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
  double *pError = get_output_error_ptr(num_of_dims, p_dims, plhs);

  /***************************************************************************/
  /* Do calculations */
  std::size_t distr_size{1};
  for (std::size_t i = 0; i < num_of_dims; i++) {
    distr_size *= std::size_t(p_dims[i]);
  }

  try {
    if (pix_data_class == mxDOUBLE_CLASS) {
      recompute_pix_sums<double>(pSignal, pError, distr_size, pNpix, pPixelData,
                                 nPixels, n_threads);
    } else if (pix_data_class == mxSINGLE_CLASS) {
      float const *const fPixData = (float *)pPixelData;
      recompute_pix_sums<float>(pSignal, pError, distr_size, pNpix, fPixData,
                                nPixels, n_threads);
    } else {
      throw("Invalid data type for pixel array. Must be float or double.");
    }
  } catch (const char *err) {
    mexErrMsgTxt(err);
  }
}

void validate_inputs(const int &nlhs, mxArray *plhs[], const int &nrhs,
                     const mxArray *prhs[]) {
  if (nrhs != N_INPUT_Arguments && nrhs != N_INPUT_Arguments - 1) {
    std::stringstream buf;
    buf << "ERROR::recompute_bin_data_c needs " << (short)N_INPUT_Arguments
        << " but got " << (short)nrhs << " input arguments and " << (short)nlhs
        << " output argument(s)\n";
    mexErrMsgTxt(buf.str().c_str());
  }

  if (nlhs != N_OUTPUT_Arguments) {
    std::stringstream buf;
    buf << "ERROR::recompute_bin_data_c needs " << (short)N_OUTPUT_Arguments
        << " outputs but requested to return" << (short)nlhs << " arguments\n";
    mexErrMsgTxt(buf.str().c_str());
  }

  for (int i = 0; i < nrhs - 1; i++) {
    if (prhs[i] == NULL) {
      std::stringstream buf;
      buf << "ERROR::recompute_bin_data_c => argument N" << i << " undefined\n";
      mexErrMsgTxt(buf.str().c_str());
    }
  }
}

const double *const get_npix_array(const mxArray *prhs[]) {
  const double *const p_pixel_data =
      (double *)mxGetPr(prhs[InputArguments::Npix_data]);

  if (!p_pixel_data) {
    mexErrMsgTxt(
        "ERROR::recompute_bin_data_c-> undefined or empty pixels array");
  }

  return p_pixel_data;
}

const double *const get_pixel_array(const mxArray *prhs[]) {
  // Validate number of pixel data columns
  std::size_t nPixDataCols = mxGetM(prhs[Pixel_data]);
  if (nPixDataCols != pix_fields::PIX_WIDTH) {
    mexErrMsgTxt("ERROR::recompute_bin_data_c-> the pixel data should be a "
                 "9*num_of_pixels array");
  }

  double const *const p_pixel_data = (double *)mxGetPr(prhs[Pixel_data]);
  if (!p_pixel_data) {
    mexErrMsgTxt(
        "ERROR::recompute_bin_data_c-> undefined or empty pixels array");
  }

  return p_pixel_data;
}

int get_num_threads(const mxArray *prhs[]) {
  int n_threads{(int)*mxGetPr(prhs[Num_threads])};
  if (n_threads > 128) {
    n_threads = 8;
  } else if (n_threads <= 0) {
    n_threads = 1;
  }
  return n_threads;
}

double *get_output_signal_ptr(mwSize &num_dims, const mwSize *dims,
                              mxArray *plhs[]) {
  plhs[Signal] = mxCreateNumericArray(num_dims, dims, mxDOUBLE_CLASS, mxREAL);
  if (!plhs[Signal]) {
    mexErrMsgTxt("ERROR::recompute_bin_data_c-> can not allocate memory for "
                 "output signal array");
  }
  return (double *)mxGetPr(plhs[Signal]);
}

double *get_output_error_ptr(mwSize &num_dims, const mwSize *dims,
                             mxArray *plhs[]) {
  plhs[Error] = mxCreateNumericArray(num_dims, dims, mxDOUBLE_CLASS, mxREAL);
  if (!plhs[Error]) {
    mexErrMsgTxt("ERROR::recompute_bin_data_c-> can not allocate memory for "
                 "output error array");
  }
  return (double *)mxGetPr(plhs[Error]);
}
