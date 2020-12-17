/*=========================================================
 * c_deserialise.cpp
 * Deserialise serialised data back into a MATLAB object
 *
 * See also:
 * hlp_serialize
 * hlp_deserialize
 *
 * This is a MEX-file for MATLAB.
 *=======================================================*/

#include <iostream>
#include <cstring>
#include <cmath>
#include "mex.h"
#include "cpp_serialise.hpp"

size_t memPtr = 0;

void read

void deserialise(uint8_t* data, mxArray* output){

  tag_type tag = tag_data(output);

  const size_t nElem = mxGetNumberOfElements(output);
  const mwSize* dims = mxGetDimensions(output);
  const size_t nDims = mxGetNumberOfDimensions(output);

  switch (tag.type) {
    // Sparse
  case SPARSE_LOGICAL:
  case SPARSE_DOUBLE:
  case SPARSE_COMPLEX_DOUBLE:
    {

    }
    break;
  case CHAR:
    {

    }
    break;
  case INT8:
  case UINT8:
  case INT16:
  case UINT16:
  case INT32:
  case UINT32:
  case INT64:
  case UINT64:
  case SINGLE:
  case DOUBLE:
  case LOGICAL:
  case COMPLEX_INT8:
  case COMPLEX_UINT8:
  case COMPLEX_INT16:
  case COMPLEX_UINT16:
  case COMPLEX_INT32:
  case COMPLEX_UINT32:
  case COMPLEX_INT64:
  case COMPLEX_UINT64:
  case COMPLEX_SINGLE:
  case COMPLEX_DOUBLE:
    {

    }
    break;

  case FUNCTION_HANDLE:
    {

    }
    break;

  case VALUE_OBJECT:
    {

    }
    break;

  case STRUCT:
    {

    }
    break;

  case CELL:
    {


    }
    break;
  }
}



/* The gateway routine. */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] ) {

#if defined(_LP64) || defined (_WIN64)
#ifdef MX_COMPAT_32
  for (i=0; i<nrhs; i++)  {
    if (mxIsSparse(prhs[i])) {
      mexErrMsgIdAndTxt("MATLAB:c_serialise:NoSparseCompat",
			"MEX-files compiled on a 64-bit platform that use sparse array functions "
			"need to be compiled using -largeArrayDims.");
    }
  }
#endif
#endif

  if (nlhs > 1) mexErrMsgIdAndTxt("MATLAB:c_serialise:badLHS", "Bad number of LHS arguments in c_serialise");
  if (nrhs != 1) mexErrMsgIdAndTxt("MATLAB:c_serialise:badRHS", "Bad number of RHS arguments in c_serialise");

  mxArray* size_arr;
  mxArray* arr = const_cast<mxArray *>(prhs[0]);
  mexCallMATLAB(1, &size_arr, 1, &arr, "c_serial_size");
  double size = mxGetPr(size_arr)[0];
  mxArray* ser_arr = mxCreateUninitNumericMatrix(size, 1, mxUINT8_CLASS, (mxComplexity) 0);
  uint8_t* serialised = (uint8_t *) mxGetData(ser_arr);
  memPtr = 0;
  serialise(serialised, arr);

  plhs[0] = ser_arr;
}
