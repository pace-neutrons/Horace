#pragma once

#include "CommonCode.h"

#include <memory>
#include <sstream>

void validate_inputs(const int &nlhs, mxArray *plhs[], const int &nrhs,
                     const mxArray *prhs[]);
const double *const get_npix_array(const mxArray *prhs[]);
const double *const get_pixel_array(const mxArray *prhs[]);
