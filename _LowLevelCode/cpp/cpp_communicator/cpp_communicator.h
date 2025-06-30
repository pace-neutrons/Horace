#pragma once
//
#include <memory>
#include "MPI_wrapper.h"
#include "input_parser.h"

void set_numlab_and_nlabs(std::unique_ptr<class_handle<MPI_wrapper> >& pCommunicatorHolder,
	int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]);