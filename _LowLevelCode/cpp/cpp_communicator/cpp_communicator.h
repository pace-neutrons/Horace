#pragma once
//
#include <memory>
#include <mex.h>

#include "MPI_wrapper.h"
#include "input_parser.h"

void set_numlab_and_nlabs(class_handle<MPI_wrapper> * const mpi_comm_ptr,
	int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]);