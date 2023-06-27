/*=========================================================
 * c_serial_size.cpp
 * Calculate the size (in bytes) of Matlab structure, which would be produced by
 *  hpl_serialize routine. Deduced from hlp_serialize
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
#include <vector>
#include "../utility/version.h"
#include "cpp_serialize.hpp"

size_t get_size(const mxArray *input) {
  size_t size = 0;

  tag_type tag = tag_data(input);

  switch (tag.type) {
  case SPARSE_LOGICAL:
  case SPARSE_COMPLEX_DOUBLE:
  case SPARSE_DOUBLE:
    {

      const mwSize* dims = mxGetDimensions(input);
      // Assume null
      bool isNotNull = false;
      for (int i = 0; i < 2; i++) {
        isNotNull = isNotNull || dims[i] > 0;
      }

      if (isNotNull) {
        mxArray* arr = const_cast<mxArray *>(input);
        mxArray* nnz;
        mexCallMATLAB(1, &nnz, 1, &arr, "nnz");
        size_t nElem = (size_t) mxGetScalar(nnz);

        size_t elemSize = types_size[tag.type];

        size += TAG_SIZE + 2*DIMS_SIZE + NELEMS_SIZE + 2*nElem*types_size[DOUBLE] + nElem*elemSize; // Tag & Dims

      } else {

        size += TAG_SIZE + NELEMS_SIZE; // Tag & Dims;
      }

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

      size_t elemSize = types_size[tag.type];

      if (nElem == 0) { // Null
        size += TAG_SIZE; // + NELEMS_SIZE;
      }
      else if (nElem == 1) { // Scalar
        size += TAG_SIZE + NELEMS_SIZE + elemSize*nElem;
        // size += TAG_SIZE + elemSize;
      }
      else if (nDims == 2 && dims[0] == 1) { // List
        size += TAG_SIZE + NELEMS_SIZE + elemSize*nElem;
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
      size += (size_t) mxGetPr(conts)[0];
    }
    break;

  case VALUE_OBJECT:
    {
      std::string name = std::string(mxGetClassName(input));
      size_t class_name_size = TAG_SIZE + NELEMS_SIZE + name.size() * types_size[CHAR];


      mxArray* arr = const_cast<mxArray*>(input);
      mxArray* ser_type;
      mexCallMATLAB(1, &ser_type, 1, &arr, "get_ser_type");
      if (*static_cast<uint8_t*>(mxGetData(ser_type)) == 0) { // object serializes itself so has serial_size method
          mxArray* ser_size(nullptr);
          mexCallMATLAB(1, &ser_size, 1, &arr, "get_serial_size");
          size += (size_t)mxGetScalar(ser_size)+ TAG_SIZE + class_name_size + 1;
          break;
      }

      size_t nElem = mxGetNumberOfElements(input);
      const mwSize* dims = mxGetDimensions(input);
      size_t nDims = mxGetNumberOfDimensions(input);


      mxArray* conts;
      mexCallMATLAB(1, &conts, 1, &arr, "get_object_conts");
      size_t data_size = get_size(conts);

      if (nElem == 0) {
        size += TAG_SIZE; // + NELEMS_SIZE;
      }
      else if (nElem == 1) {
        size += TAG_SIZE + NELEMS_SIZE + class_name_size + 1 + data_size;
        // size += TAG_SIZE + class_name_size + 1 + data_size;
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

      int nFields = mxGetNumberOfFields(input);
      size_t fn_size = NELEMS_SIZE*(nFields+1); // Nfields + name lens

      for (int field=0; field < nFields; field++) {
        fn_size += strlen(mxGetFieldNameByNumber(input, field)) * types_size[CHAR];
      }

      size_t data_size = 0;
      if (nFields > 0) {
        mxArray* arr = const_cast<mxArray *>(input);
        mxArray* conts;
        mexCallMATLAB(1, &conts, 1, &arr, "struct2cell");
        data_size = get_size(conts);
      }

      if (nElem == 0) {
        size += TAG_SIZE; // + NELEMS_SIZE;
      }
      else if (nElem == 1) {
        size += TAG_SIZE + NELEMS_SIZE + fn_size + data_size;
        // size += TAG_SIZE + fn_size + data_size;
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

      size_t data_size = 0;
      for (mwIndex i = 0; i < nElem; i++){
        mxArray* cellElem = mxGetCell(input, i);
        data_size += (cellElem == nullptr) ? 2 : get_size(cellElem);
      }

      if (nElem == 0) { // Null (string?)
        size += TAG_SIZE; // + NELEMS_SIZE;
      }
      else if (nElem == 1) { // Scalar
        size += TAG_SIZE + NELEMS_SIZE + data_size;
        // size += TAG_SIZE + data_size;
      }
      else if (nDims == 2 && dims[0] == 1) { // List
        size += TAG_SIZE + NELEMS_SIZE + data_size;
      }
      else { // General array
        size += TAG_SIZE + NELEMS_SIZE*nDims + data_size;
      }

    }
    break;

  case SERIALIZABLE:
    {
      mxArray* arr = const_cast<mxArray *>(input);
      mxArray* conts;
      mexCallMATLAB(1, &conts, 1, &arr, "serial_size");
      double out = *static_cast<double *>(mxGetData(conts));
      size += types_size[UINT8] + out;
    }
    break;

  }
  return size;

}

/* The gateway routine. */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] ) {

  //--------->  RETURN MEX-file version if requested;
  if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
        plhs[0] = mxCreateString(Horace::VERSION);
        return;
  }


  size_t size = 0;

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
  plhs[0] = mxCreateDoubleScalar((double) size);
}
