#pragma once
//
// $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)" 
//
//
#include <memory>
#include <mex.h>
#include "MPI_wrapper.h"
#include "input_parser.h"

void set_numlab_and_nlabs(class_handle<MPI_wrapper> const *const pCommunicatorHolder, int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);