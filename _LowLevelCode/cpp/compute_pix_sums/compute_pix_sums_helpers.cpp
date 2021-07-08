#include "compute_pix_sums_helpers.h"

#include <memory>
#include <sstream>

void validate_inputs(const int &nlhs, mxArray *plhs[], const int &nrhs,
                     const mxArray *prhs[]) {
  if (nrhs != N_INPUT_Arguments && nrhs != N_INPUT_Arguments - 1) {
    std::stringstream buf;
    buf << "ERROR::compute_pix_sums_c needs " << (short)N_INPUT_Arguments
        << " but got " << (short)nrhs << " input arguments and " << (short)nlhs
        << " output argument(s)\n";
    mexErrMsgTxt(buf.str().c_str());
  }

  if (nlhs != N_OUTPUT_Arguments) {
    std::stringstream buf;
    buf << "ERROR::compute_pix_sums_c needs " << (short)N_OUTPUT_Arguments
        << " outputs but requested to return" << (short)nlhs << " arguments\n";
    mexErrMsgTxt(buf.str().c_str());
  }

  for (int i = 0; i < nrhs - 1; i++) {
    if (prhs[i] == NULL) {
      std::stringstream buf;
      buf << "ERROR::compute_pix_sums_c => argument N" << i << " undefined\n";
      mexErrMsgTxt(buf.str().c_str());
    }
  }
}

const double *const get_npix_array(const mxArray *prhs[]) {
  const double *const p_npix_data = (double *)mxGetPr(prhs[Npix_data]);
  if (!p_npix_data) {
    mexErrMsgTxt("ERROR::compute_pix_sums_c-> undefined or empty npix array");
  }

  return p_npix_data;
}

const double *const get_pixel_array(const mxArray *prhs[]) {
  // Validate number of pixel data columns
  std::size_t nPixDataCols = mxGetM(prhs[Pixel_data]);
  if (nPixDataCols != pix_fields::PIX_WIDTH) {
    mexErrMsgTxt("ERROR::compute_pix_sums_c-> the pixel data should be a "
                 "9*num_of_pixels array");
  }

  const double *const p_pixel_data = (double *)mxGetPr(prhs[Pixel_data]);
  if (!p_pixel_data) {
    mexErrMsgTxt(
        "ERROR::compute_pix_sums_c-> undefined or empty pixels array");
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
    mexErrMsgTxt("ERROR::compute_pix_sums_c-> can not allocate memory for "
                 "output signal array");
  }
  return (double *)mxGetPr(plhs[Signal]);
}

double *get_output_variance_ptr(mwSize &num_dims, const mwSize *dims,
                                mxArray *plhs[]) {
  plhs[Variance] = mxCreateNumericArray(num_dims, dims, mxDOUBLE_CLASS, mxREAL);
  if (!plhs[Variance]) {
    mexErrMsgTxt("ERROR::compute_pix_sums_c-> can not allocate memory for "
                 "output variance array");
  }
  return (double *)mxGetPr(plhs[Variance]);
}
