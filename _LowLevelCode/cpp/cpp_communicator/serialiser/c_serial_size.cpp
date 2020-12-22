/*=========================================================
 * c_serial_size.cpp
 * Calculate the size (in bytes) of Matlab structure, which would be produced by
 *  hpl_serialize routine. Deduced from hlp_serialise
 *
 * See also:
 * hlp_serialize
 * hlp_deserialize
 *
 * This is a MEX-file for MATLAB.
 *=======================================================*/

#include <iostream>
#include <cmath>
#include <cstring>
#include "mex.h"
#include "cpp_serialise.hpp"

double get_size(const mxArray *input) {
  double size = 0.0;

  tag_type tag = tag_data(input);

  switch (tag.type) {
  case SPARSE_LOGICAL:
  case SPARSE_COMPLEX_DOUBLE:
  case SPARSE_DOUBLE:
    {
      mxArray* nnz;
      mxArray* arr = const_cast<mxArray *>(input);
      mexCallMATLAB(1, &nnz, 1, &arr, "nnz");
      double nElem = mxGetPr(nnz)[0];

      double elemSize = types_size[tag.type];

      size += TAG_SIZE + 2*DIMS_SIZE + NELEMS_SIZE + 2*nElem*types_size[DOUBLE] + nElem*elemSize; // Tag & Dims

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
  case LOGICAL:
  case CHAR:
    {
      size_t nElem = mxGetNumberOfElements(input);
      const mwSize* dims = mxGetDimensions(input);
      size_t nDims = mxGetNumberOfDimensions(input);

      double elemSize = types_size[tag.type];

      if (nElem == 0) { // Null
        size += TAG_SIZE + NELEMS_SIZE;
      }
      else if (nElem == 1) { // Scalar
        size += TAG_SIZE + elemSize;
      }
      else if (nDims == 2 && dims[0] == 1) { // List
        size = 1 + NELEMS_SIZE + elemSize*nElem;
      }
      else { // General array
        size += TAG_SIZE + NELEMS_SIZE*nDims + elemSize * nElem;
      }
    }
    break;

  case FUNCTION_HANDLE:
    {
      mxArray* conts;
      mxArray* arr = const_cast<mxArray *>(input);
      mexCallMATLAB(1, &conts, 1, &arr, "hlp_serial_sise");
      size += mxGetPr(conts)[0];
    }
    break;

  case VALUE_OBJECT:
    {
      std::string name = std::string(mxGetClassName(input));

      size_t nElem = mxGetNumberOfElements(input);
      const mwSize* dims = mxGetDimensions(input);
      size_t nDims = mxGetNumberOfDimensions(input);

      mxArray* conts;
      // Get conts without copy
      mxArray* arr = const_cast<mxArray *>(input);
      double class_name_size = TAG_SIZE + NELEMS_SIZE + name.size() * types_size[CHAR];
      mexCallMATLAB(1, &conts, 1, &arr, "get_object_conts");
      double data_size = get_size(conts);

      if (nElem == 0) {
        size += TAG_SIZE + NELEMS_SIZE;
      }
      else if (nElem == 1) {
        size += TAG_SIZE + class_name_size + 1 + data_size;
      }
      else if (nDims == 2 && dims[0] == 1) {
        size += TAG_SIZE + NELEMS_SIZE + class_name_size + 1 + data_size;
      }
      else {
        size += TAG_SIZE + NELEMS_SIZE*nDims + class_name_size + 1 + data_size;
      }
    }

    break;

  case STRUCT:
    {

      size_t nElem = mxGetNumberOfElements(input);
      const mwSize* dims = mxGetDimensions(input);
      size_t nDims = mxGetNumberOfDimensions(input);

      size_t nFields = mxGetNumberOfFields(input);
      double fn_size = NELEMS_SIZE*(nFields+1); // Nfields + name lens

      for (int field=0; field < nFields; field++) {
        fn_size += strlen(mxGetFieldNameByNumber(input, field)) * types_size[CHAR];
      }

      double data_size = 0.0;
      if (nFields > 0) {
        mxArray* arr = const_cast<mxArray *>(input);
        mxArray* conts;
        mexCallMATLAB(1, &conts, 1, &arr, "struct2cell");
        data_size = get_size(conts);
      }

      if (nElem == 0) {
        size += TAG_SIZE + NELEMS_SIZE;
      }
      else if (nElem == 1) {
        size += TAG_SIZE + fn_size + data_size;
      }
      else if (nDims == 2 && dims[0] == 1) {
        size += TAG_SIZE + NELEMS_SIZE + fn_size + data_size;
      }
      else {
        size += TAG_SIZE + NELEMS_SIZE*nDims + fn_size + data_size;
      }

    }
    break;

  case CELL:
    {
      size_t nElem = mxGetNumberOfElements(input);
      const mwSize* dims = mxGetDimensions(input);
      size_t nDims = mxGetNumberOfDimensions(input);

      double data_size = 0.0;
      for (mwIndex i = 0; i < nElem; i++){
        mxArray* cellElem = mxGetCell(input, i);
        data_size += get_size(cellElem);
      }

      if (nElem == 0) { // Null (string?)
        size += TAG_SIZE + NELEMS_SIZE;
      }
      else if (nElem == 1) { // Scalar
        size += TAG_SIZE + data_size;
      }
      else if (nDims == 2 && dims[0] == 1) { // List
        size += TAG_SIZE + NELEMS_SIZE + data_size;
      }
      else { // General array
        size += TAG_SIZE + NELEMS_SIZE*nDims + data_size;
      }

    }
    break;
  }
  return size;

}

/* The gateway routine. */
void mexFunction( int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] ) {

  double size = 0.0;

#if defined(_LP64) || defined (_WIN64)
#ifdef MX_COMPAT_32
  for (i=0; i<nrhs; i++)  {
    if (mxIsSparse(prhs[i])) {
      mexErrMsgIdAndTxt("MATLAB:explore:NoSparseCompat",
                        "MEX-files compiled on a 64-bit platform that use sparse array functions "
                        "need to be compiled using -largeArrayDims.");
    }
  }
#endif
#endif

  if (nlhs > 1) mexErrMsgIdAndTxt("MATLAB:c_serial_size:badLHS", "Bad number of LHS arguments in c_serial_size");

  for (int i=0; i<nrhs; i++)  {
    size += get_size(prhs[i]);
  }
  plhs[0] = mxCreateDoubleScalar(size);
}
