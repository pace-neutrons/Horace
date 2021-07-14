#pragma once

#include "../CommonCode.h"

enum InputArguments { Npix_data, Pixel_data, Num_threads, N_INPUT_Arguments };
enum OutputArguments { // unique output arguments,
  Signal,
  Variance,
  N_OUTPUT_Arguments
};

void validate_inputs(const int &nlhs, mxArray *plhs[], const int &nrhs,
                     const mxArray *prhs[]);

const double *const get_npix_array(const mxArray *prhs[]);

const double *const get_pixel_array(const mxArray *prhs[]);

int get_num_threads(const mxArray *prhs[]);

double *get_output_signal_ptr(mwSize &num_dims, const mwSize *dims,
                              mxArray *plhs[]);

double *get_output_variance_ptr(mwSize &num_dims, const mwSize *dims,
                                mxArray *plhs[]);
