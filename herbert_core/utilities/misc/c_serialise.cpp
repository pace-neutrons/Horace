/*=========================================================
 * c_serialise.cpp
 * Serialise MATLAB object into a uint8 data stream
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

// Current byte to write
size_t memPtr;

inline void ser(uint8_t* data, const void* data_in, const double amount) {
  // Write bytes and move memory index
  memcpy(&data[memPtr], data_in, amount);
  memPtr += amount;
}

inline void write_data(uint8_t* data, const mxArray* input, const size_t elemSize, const size_t nElem) {
  if (mxIsComplex(input)) {
    // Size of a complex component is half that of the whole double
    size_t compSize = elemSize/2;

#if MX_HAS_INTERLEAVED_COMPLEX
    void* toWrite = mxGetComplexDouble(input);
    // Offset imaginary to end
    size_t imPtr = memPtr + (1+nElem)*compSize;

    for (int i = 0; i < nElem; i+=elemSize, memPtr += compSize, imPtr += compSize) {
      memcpy(&data[memPtr], &toWrite[i], compSize);
      memcpy(&data[imPtr], &toWrite[i+compSize], compSize);
    }

#else
    void* toWrite = mxGetPr(input);
    ser(data, toWrite, compSize*nElem);
    toWrite = mxGetPi(input);
    ser(data, toWrite, compSize*nElem);

#endif

  } else {
    void* toWrite = mxGetPr(input);
    ser(data, toWrite, elemSize*nElem);
  }
}

inline void write_header(uint8_t* data, tag_type& tag,
		  const size_t nElem, const mwSize* dims, const size_t nDims) {

  if (nElem == 0) { // Null
    tag.dim = 1;
    ser(data, &tag, 1);
    ser(data, &nElem, 4);
  }
  else if (nElem == 1) { // Scalar
    tag.dim = 0;
	ser(data, &tag, 1);
      }
      else if (nDims == 2 && dims[0] == 1) { // List
	tag.dim = 1;
	ser(data, &tag, 1);
	ser(data, &nElem, types_size[UINT32]);
      }
      else { // General array
	tag.dim = nDims;

	uint32_t* cast_dims = new uint32_t[nDims];
	for (int i = 0; i < nDims; i++) cast_dims[i] = (uint32_t) dims[i];

	ser(data, &tag, 1);
	ser(data, cast_dims, nDims*types_size[UINT32]);
      }

}


void serialise(uint8_t* data, const mxArray* input){

  tag_type tag = tag_data(input);

  const size_t nElem = mxGetNumberOfElements(input);
  const mwSize* dims = mxGetDimensions(input);
  const size_t nDims = mxGetNumberOfDimensions(input);

  switch (tag.type) {
    // Sparse
  case SPARSE_LOGICAL:
  case SPARSE_DOUBLE:
  case SPARSE_COMPLEX_DOUBLE:
    {

      mxArray* nnz;
      mxArray* arr = const_cast<mxArray*>(input);
      mexCallMATLAB(1, &nnz, 1, &arr, "nnz");
      uint32_t numNonZero = (uint32_t) mxGetPr(nnz)[0];

      uint32_t* cast_dims = new uint32_t[2];
      for (int i = 0; i < 2; i++) cast_dims[i] = (uint32_t) dims[i];

      mwIndex* ir = mxGetIr(input);
      mwIndex* jc = mxGetJc(input);
      uint64_t* map = new uint64_t[numNonZero];
      for (int c = 0, n = 0; n < numNonZero; c++) {
	for (int i = jc[c]; i < jc[c+1]; i++, n++) {
	  map[n] = c;
	}
      }
      tag.dim = 2;
      ser(data, &tag, 1);
      ser(data, cast_dims, tag.dim*types_size[UINT32]);
      ser(data, &numNonZero, types_size[UINT32]);

      ser(data, ir, types_size[UINT64]*numNonZero);
      ser(data, map, types_size[UINT64]*numNonZero);

      write_data(data, input, types_size[tag.type], numNonZero);
    }
    break;
  case CHAR:
    {

      write_header(data, tag, nElem, dims, nDims);
      char *arr = new char[nElem+1];
      // Copies with NULL terminator
      mxGetString(input, arr, nElem+1);
      ser(data, arr, nElem*types_size[CHAR]);

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

      write_header(data, tag, nElem, dims, nDims);
      write_data(data, input, types_size[tag.type], nElem);

    }
    break;

  case FUNCTION_HANDLE:
    {
      mxArray* conts;
      mxArray* arr = const_cast<mxArray*>(input);
      mexCallMATLAB(1, &conts, 1, &arr, "hlp_serialise");
      ser(data, mxGetPr(conts), mxGetNumberOfElements(conts)*types_size[UINT8]);
    }
    break;

  case VALUE_OBJECT:
    {
      write_header(data, tag, nElem, dims, nDims);
      const char* name = mxGetClassName(input);
      tag_type name_tag;
      name_tag.type = CHAR;
      const mwSize name_dim[] = {1, strlen(name)};
      write_header(data, name_tag, name_dim[1], name_dim, 2);
      ser(data, name, name_dim[1]*types_size[CHAR]);
      mxArray* arr = const_cast<mxArray*>(input);
      {
	mxArray* ser_type;
	mexCallMATLAB(1, &ser_type, 1, &arr, "get_ser_type");
	ser(data, mxGetPr(ser_type), types_size[UINT8]);
	mxDestroyArray(ser_type);
      }
      {
	mxArray* conts;
	mexCallMATLAB(1, &conts, 1, &arr, "get_object_conts");
	serialise(data, conts);
	mxDestroyArray(conts);
      }

    }
    break;

  case STRUCT:
    {
      uint32_t nFields = mxGetNumberOfFields(input);

      write_header(data, tag, nElem, dims, nDims);

      ser(data, &nFields, types_size[UINT32]);

      int namePtr = memPtr + nFields*types_size[UINT32];
      int namePtr_i = namePtr;

      int parsed = 0;
      for (int field=0; field < nFields; field++) {
	const char* name = mxGetFieldNameByNumber(input, field);
	uint32_t size = strlen(name);
	ser(data, &size, types_size[UINT32]);
	memcpy(&data[namePtr], name, size);
	namePtr += size;
	parsed += size;
      }

      memPtr += parsed;

      if (nFields > 0) {
	mxArray* conts;
	mxArray* arr = const_cast<mxArray*>(input);
	mexCallMATLAB(1, &conts, 1, &arr, "struct2cell");
	serialise(data, conts);
      }


    }
    break;

  case CELL:
    {

      write_header(data, tag, nElem, dims, nDims);
      for (mwIndex i = 0; i < nElem; i++){
	serialise(data, mxGetCell(input, i));
      }

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
