#pragma once

#include "CommonCode.h"

#include <memory>
#include <sstream>

void validate_inputs(const int &nlhs, mxArray *plhs[], const int &nrhs,
                     const mxArray *prhs[]);
const double *const get_npix_array(const mxArray *prhs[]);
const double *const get_pixel_array(const mxArray *prhs[]);
int get_num_threads(const mxArray *prhs[]);

double *get_output_signal_ptr(mwSize &num_dims, const mwSize *dims,
                              mxArray *plhs[]);
double *get_output_error_ptr(mwSize &num_dims, const mwSize *dims,
                             mxArray *plhs[]);
