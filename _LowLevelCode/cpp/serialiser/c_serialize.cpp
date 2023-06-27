/*=========================================================
 * c_serialize.cpp
 * Serialize MATLAB object into a uint8 data stream
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

template<typename T>
inline void ser(uint8_t* data, size_t& memPtr, const std::vector<T>& data_in, const size_t amount) {
  memcpy(&data[memPtr], data_in.data(), amount);
  memPtr += amount;
}

inline void ser(uint8_t* data, size_t& memPtr, const void* const data_in, const size_t amount) {
  // Write bytes and move memory index
  memcpy(&data[memPtr], data_in, amount);
  memPtr += amount;
}

inline void write_data(uint8_t* data, size_t& memPtr, const mxArray* const input, const size_t elemSize, const size_t nElem) {
  if (mxIsComplex(input)) {
    // Size of a complex component is half that of the whole complex
    size_t compSize = elemSize/2;

#if MX_HAS_INTERLEAVED_COMPLEX
    void* toWrite = mxGetComplexDoubles(input);
    // Offset imaginary to end
    size_t imPtr = memPtr + (1+nElem)*compSize;

    for (size_t i = 0; i < nElem; i+=elemSize, memPtr += compSize, imPtr += compSize) {
      memcpy(&data[memPtr], &toWrite[i], compSize);
      memcpy(&data[imPtr], &toWrite[i+compSize], compSize);
    }
    memPtr = imPtr; // Finally update memPtr

#else
    void* toWrite = mxGetPr(input);
    ser(data, memPtr, toWrite, compSize*nElem);
    toWrite = mxGetPi(input);
    ser(data, memPtr, toWrite, compSize*nElem);

#endif

  } else {
    void* toWrite = mxGetPr(input);
    ser(data, memPtr, toWrite, elemSize*nElem);
  }
}

inline void write_header(uint8_t* data, size_t& memPtr, tag_type& tag,
                         const size_t nElem, const mwSize* dims, const size_t nDims) {

  if (nElem == 0) { // Null
    tag.dim = 0;
    ser(data, memPtr, &tag, TAG_SIZE);
    // ser(data, memPtr, &nElem, types_size[UINT32]);
  }
  else if (nElem == 1) { // Scalar
    tag.dim = 1;
    ser(data, memPtr, &tag, TAG_SIZE);
    ser(data, memPtr, &nElem, types_size[UINT32]);
  }
  else if (nDims == 2 && dims[0] == 1) { // List
    tag.dim = 1;
    ser(data, memPtr, &tag, TAG_SIZE);
    ser(data, memPtr, &nElem, types_size[UINT32]);
  }
  else { // General array
    tag.dim = nDims;

    std::vector<uint32_t> cast_dims(nDims);
    for (size_t i = 0; i < nDims; i++) cast_dims[i] = (uint32_t) dims[i];

    ser(data, memPtr, &tag, TAG_SIZE);
    ser(data, memPtr, cast_dims, nDims*types_size[UINT32]);
  }

}


void serialize(uint8_t* data, size_t& memPtr, const mxArray* input){


  tag_type tag = tag_data(input);
  size_t nElem = mxGetNumberOfElements(input);
  const mwSize* dims = mxGetDimensions(input);
  size_t nDims = mxGetNumberOfDimensions(input);

  for (size_t i=0; i < nDims; i++) {
    if (dims[i] > DIM_MAX) {
      mexErrMsgIdAndTxt("MATLAB:serialize:bad_size", "Dimensions of array exceed limit of uint32, cannot serialize.");
    }
  }


  switch (tag.type) {
    // Sparse
  case SPARSE_LOGICAL:
  case SPARSE_DOUBLE:
  case SPARSE_COMPLEX_DOUBLE:
    {


      // Assume null
      bool isNotNull = false;
      for (int i = 0; i < nDims; i++) {
        isNotNull = isNotNull || dims[i] > 0;
      }

      if (isNotNull) {

        std::vector<uint32_t> cast_dims(2);
        for (int i = 0; i < 2; i++) cast_dims[i] = (uint32_t) dims[i];

        mwIndex* ir = mxGetIr(input);
        mwIndex* jc = mxGetJc(input);
        size_t nnz = jc[dims[1]];
        std::vector<uint64_t> map_jc(nnz);

        // map Jc (see MATLAB docs on sparse arrays in MEX API)
        for (mwIndex c = 0, n = 0; n < nnz; c++) {
          for (mwIndex i = jc[c]; i < jc[c+1]; i++, n++) {
            map_jc[n] = c;
          }
        }

        tag.dim = 2;
        ser(data, memPtr, &tag, TAG_SIZE);
        ser(data, memPtr, cast_dims, tag.dim*types_size[UINT32]);
        ser(data, memPtr, &nnz, types_size[UINT32]);

        ser(data, memPtr, ir, types_size[UINT64]*nnz);
        ser(data, memPtr, map_jc, types_size[UINT64]*nnz);

        write_data(data, memPtr, input, types_size[tag.type], nnz);

      } else {

        uint32_t nil = 0;

        ser(data, memPtr, &tag.type, types_size[UINT8]);
        ser(data, memPtr, &nil, types_size[UINT32]);
      }
    }
    break;
  case CHAR:
    {

      write_header(data, memPtr, tag, nElem, dims, nDims);
      std::vector<char> arr(nElem+1);
      // Copies with NULL terminator, don't write with
      mxGetString(input, arr.data(), nElem+1);
      ser(data, memPtr, arr, nElem*types_size[CHAR]);
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

      write_header(data, memPtr, tag, nElem, dims, nDims);
      write_data(data, memPtr, input, types_size[tag.type], nElem);

    }
    break;

  case FUNCTION_HANDLE:
    {
      // Fall back to MATLAB
      mxArray* conts;
      mxArray* arr = const_cast<mxArray*>(input);
      mexCallMATLAB(1, &conts, 1, &arr, "hlp_serialize");
      ser(data, memPtr, mxGetPr(conts), mxGetNumberOfElements(conts)*types_size[UINT8]);
    }
    break;

  case VALUE_OBJECT:
    {
      mxArray* arr = const_cast<mxArray*>(input);
      mxArray* ser_type;
      mexCallMATLAB(1, &ser_type, 1, &arr, "get_ser_type");

      if (!(bool) mxGetScalar(ser_type)) { // object serializes itself together with dimensions transforming array structure into structure array
          nElem = 1;
          nDims = 2;
      }

      write_header(data, memPtr, tag, nElem, dims, nDims);

      const char* name = mxGetClassName(input);
      tag_type name_tag;
      name_tag.type = CHAR;
      const mwSize name_dim[] = {1, strlen(name)};
      write_header(data, memPtr, name_tag, name_dim[1], name_dim, 2);
      ser(data, memPtr, name, name_dim[1]*types_size[CHAR]);


      ser(data, memPtr, mxGetPr(ser_type), types_size[UINT8]);
      mxDestroyArray(ser_type);

      mxArray* conts;
      mexCallMATLAB(1, &conts, 1, &arr, "get_object_conts");
      serialize(data, memPtr, conts);
      mxDestroyArray(conts);


    }
    break;

  case STRUCT:
    {
      uint32_t nFields = mxGetNumberOfFields(input);

      write_header(data, memPtr, tag, nElem, dims, nDims);

      ser(data, memPtr, &nFields, types_size[UINT32]);

      size_t namePtr = memPtr + nFields*types_size[UINT32];

      size_t parsed = 0;
      for (uint32_t field=0; field < nFields; field++) {
        const char* name = mxGetFieldNameByNumber(input, field);
        size_t size = strlen(name);
        ser(data, memPtr, &size, types_size[UINT32]);
        memcpy(&data[namePtr], name, size);
        namePtr += size;
        parsed += size;
      }

      memPtr += parsed;

      if (nFields > 0) {
        mxArray* conts;
        mxArray* arr = const_cast<mxArray*>(input);
        mexCallMATLAB(1, &conts, 1, &arr, "struct2cell");
        serialize(data, memPtr, conts);
      }


    }
    break;

  case CELL:
    {

      write_header(data, memPtr, tag, nElem, dims, nDims);
      for (mwIndex i = 0; i < nElem; i++){
        mxArray* cellElem = mxGetCell(input, i);
        if (cellElem == nullptr) {
          cellElem = mxCreateUninitNumericMatrix(0, 0, mxDOUBLE_CLASS, (mxComplexity) 0);
        }
        serialize(data, memPtr, cellElem);
      }

    }
    break;
  case SERIALIZABLE:
    {
      ser(data, memPtr, &tag.type, types_size[UINT8]);
      mxArray* conts;
      mxArray* arr = const_cast<mxArray*>(input);
      mexCallMATLAB(1, &conts, 1, &arr, "serialize");
      ser(data, memPtr, mxGetPr(conts), mxGetNumberOfElements(conts)*types_size[UINT8]);
    }
    break;
  }
}


/* MATLAB entry point c_serialize */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] ) {

  //--------->  RETURN MEX-file version if requested;
  if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
        plhs[0] = mxCreateString(Horace::VERSION);
        return;
  }


#if defined(_LP64) || defined (_WIN64)
#ifdef MX_COMPAT_32
  for (i=0; i<nrhs; i++)  {
    if (mxIsSparse(prhs[i])) {
      mexErrMsgIdAndTxt("MATLAB:c_serialize:NoSparseCompat",
                        "MEX-files compiled on a 64-bit platform that use sparse array functions "
                        "need to be compiled using -largeArrayDims.");
    }
  }
#endif
#endif

  if (nlhs > 1) {
    mexErrMsgIdAndTxt("MATLAB:c_serialize:badLHS", "Bad number of LHS arguments in c_serialize");
  }
  if (nrhs != 1) {
    mexErrMsgIdAndTxt("MATLAB:c_serialize:badRHS", "Bad number of RHS arguments in c_serialize");
  }

  mxArray* size_arr;
  mxArray* arr = const_cast<mxArray *>(prhs[0]);
  mexCallMATLAB(1, &size_arr, 1, &arr, "c_serial_size");
  size_t size = (size_t) mxGetScalar(size_arr);
  mxArray* ser_arr = mxCreateUninitNumericMatrix(size, 1, mxUINT8_CLASS, (mxComplexity) 0);
  uint8_t* serialized = (uint8_t *) mxGetData(ser_arr);
  size_t memPtr = 0;
  serialize(serialized, memPtr, arr);

  plhs[0] = ser_arr;
}
