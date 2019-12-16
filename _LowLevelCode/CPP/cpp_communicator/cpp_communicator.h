#pragma once
//
// $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)" 
//
//
#include <memory>
#include <mex.h>
#include "MPI_wrapper.h"
#include "input_parser.h"

void set_numlab_and_nlabs(class_handle<MPI_wrapper> const *const pCommunicatorHolder, int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);;