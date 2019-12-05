#pragma once
//
// $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)" 
//
//
#include <memory>
#include <mex.h>
#include "MPI_wrapper.h"
#include "input_parser.h"

void set_numlab_and_nlabs(class_handle<MPI_wrapper> const *const pCommunicatorHolder, int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);;