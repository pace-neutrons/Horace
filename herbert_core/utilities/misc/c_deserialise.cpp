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

size_t memPtr;

inline void deser(const uint8_t* data, void* output, const double amount) {
  memcpy(output, &data[memPtr], amount);
  memPtr += amount;
}

inline void read_data(uint8_t* data, mxArray* output, const size_t elemSize, const size_t nElem) {
  if (mxIsComplex(output)) {
    // Size of a complex component is half that of the whole double
    size_t compSize = elemSize/2;

#if MX_HAS_INTERLEAVED_COMPLEX
    void* toWrite = mxGetComplexDouble(input);
    // Offset imaginary to end
    size_t imPtr = memPtr + (1+nElem)*compSize;

    for (int i = 0; i < nElem; i+=elemSize, memPtr += compSize, imPtr += compSize) {
      memcpy(&toWrite[i]         , &data[memPtr],  compSize);
      memcpy(&toWrite[i+compSize], &data[imPtr] ,  compSize);
    }
    memPtr = imPtr; // Finally update memPtr

#else
    void* toWrite = mxGetPr(output);
    deser(data, toWrite, compSize*nElem);
    toWrite = mxGetPi(output);
    deser(data, toWrite, compSize*nElem);

#endif

  } else {
    void* toWrite = mxGetPr(output);
    deser(data, toWrite, elemSize*nElem);
  }
}


mxArray* deserialise(uint8_t* data, size_t size, bool recursed) {

  mxArray* output = NULL;

  tag_type tag;
  deser(data, &tag, types_size[UINT8]);
  size_t nDims;
  uint32_t* cast_dims;
  mwSize* dims;
  size_t nElem;

  // Special case as function handles work differently
  if (tag.type != FUNCTION_HANDLE) {
    nDims = tag.dim;
    cast_dims = new uint32_t[nDims];
    deser(data, cast_dims, nDims*types_size[UINT32]);
    switch (nDims) {
    case 0:
      nElem = 1;
      nDims = 2;
      dims = new mwSize[2] {1, 1};
      break;
    case 1:
      nElem = cast_dims[0];
      nDims = 2;
      if (nElem == 0) { // Handle null
        dims = new mwSize[2] {0, 0};
      } else {
        dims = new mwSize[2] {1, nElem};
      }
      break;
    default:
      dims = new mwSize[nDims];
      nElem = 1;
      for (size_t i = 0; i < nDims; i++) {
        dims[i] = cast_dims[i];
        nElem *= dims[i];
      }
      break;
    }
  }
  else {
    dims = new mwSize[2] {1, 1};
    cast_dims = new uint32_t[2] {1, 1};
    nElem = 1;
  }

  switch (tag.type) {
    // Sparse
  case SPARSE_LOGICAL:
  case SPARSE_DOUBLE:
  case SPARSE_COMPLEX_DOUBLE:
    {
      uint32_t nnz;
      deser(data, &nnz, types_size[UINT32]);

      if (tag.type == SPARSE_LOGICAL) {
        output = mxCreateSparseLogicalMatrix(dims[0], dims[1], nnz);
      } else {
        mxComplexity cmplx = (mxComplexity) (tag.type == SPARSE_COMPLEX_DOUBLE);
        output = mxCreateSparse(dims[0], dims[1], nnz, cmplx);
      }
      mwIndex* ir = mxGetIr(output);
      mwIndex* jc = mxGetJc(output);
      uint64_t* map_jc = new uint64_t[nnz];

      deser(data, ir, types_size[UINT64]*nnz);
      deser(data, map_jc, types_size[UINT64]*nnz);

      // Unmap Jc
      for (int i = 0; i < nnz; i++) {
        jc[map_jc[i]+1]++;
      }

      for (int i = 1; i < dims[1]+1; i++) {
        jc[i] += jc[i-1];
      }

      read_data(data, output, types_size[tag.type], nnz);
      delete map_jc;

    }
    break;
  case CHAR:
    {
      char* arr = new char[nElem];
      deser(data, arr, nElem*types_size[CHAR]);
      output = mxCreateCharArray(nDims, dims);
      char* out = (char*) mxGetPr(output);
      for (int i =0; i < nElem; i++) {
        out[2*i] = arr[i];
      }
      delete arr;
    }
    break;
  case LOGICAL:
    output = mxCreateLogicalArray(nDims, dims);
    read_data(data, output, types_size[tag.type], nElem);
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
    {
      mxComplexity cmplx = (mxComplexity) (12 < tag.type && tag.type < 23);
      output = mxCreateNumericArray(nDims, dims, unmap_types[tag.type], cmplx);
      read_data(data, output, types_size[tag.type], nElem);
    }
    break;

  case FUNCTION_HANDLE:
    {
      switch(tag.dim) {
      case 1:
        {
          mxArray* name = deserialise(data, size, 1);
          mexCallMATLAB(1, &output, 1, &name, "str2func");
          mxDestroyArray(name);
        }
        break;
      case 2:
        {
          mxArray* name = deserialise(data, size, 1);
          mxArray* workspace = deserialise(data, size, 1);
          mxArray** input = new mxArray*[2] {name, workspace};
          mexCallMATLAB(1, &output, 2, input, "restore_function");
          mxDestroyArray(name);
          mxDestroyArray(workspace);
          delete input;
        }
        break;
      case 3:
        {
          mxArray* parentage = deserialise(data, size, 1);
          const int len = mxGetNumberOfElements(parentage);

          // Initial output
          output = mxGetCell(parentage, len-1);

          mxArray** input = new mxArray*[3];

          mxArray* stringHandle = mxCreateString("handle");
          input[0] = stringHandle;
          for (int i = len-2; i >= 0; i--) {
            input[1] = output;
            input[2] = mxGetCell(parentage, i);
            mexCallMATLAB(1, &output, 3, input, "arg_report");
          }
          mxDestroyArray(stringHandle);
          mxDestroyArray(parentage);
          delete input;
          break;
        }
      }
    }
    break;

  case VALUE_OBJECT:
    {
      memPtr++; // Skip name_tag
      uint32_t nameLen;
      deser(data, &nameLen, types_size[UINT32]);
      char* name = new char[nameLen+1] {0};
      deser(data, name, nameLen*types_size[CHAR]);

      uint8_t ser_tag;
      deser(data, &ser_tag, types_size[UINT8]);

      switch (ser_tag) {
      case 0:
        {
          mxArray* mxData = mxCreateNumericMatrix(size-memPtr,1,mxUINT8_CLASS, (mxComplexity) 0);
          mxArray* mxName = mxCreateString(name);
          mxSetPr(mxData, (double *) &data[memPtr]);
          mxArray** results = new mxArray*[2];
          mxArray** input = new mxArray*[2] {mxName, mxData};
          mexCallMATLAB(2, results, 2, input, "c_hlp_deserialise_object_self");
          output = results[0];
          memPtr += mxGetScalar(results[1]);
          mxDestroyArray(mxName);
          mxDestroyArray(mxData);
          delete input;
          delete results;
        }
        break;
      case 1:
        {
          mxArray* mxName = mxCreateString(name);
          mxArray* conts = deserialise(data, size, 1);
          mxArray** input = new mxArray*[2] {mxName, conts};
          mexCallMATLAB(1, &output, 2, input, "c_hlp_deserialise_object_loadobj");
          mxDestroyArray(conts);
          mxDestroyArray(mxName);
          delete input;
        }
        break;
      case 2:
          {
            mxArray* conts = deserialise(data, size, 1);
            int nFields = mxGetNumberOfFields(conts);
          }
        break;
      }

      delete name;
    }
    break;

  case STRUCT:
    {
      uint32_t nFields;
      deser(data, &nFields, types_size[UINT32]);
      uint32_t* fNameLens = new uint32_t[nFields];
      deser(data, fNameLens, nFields*types_size[UINT32]);

      char** fNames = new char *[nFields];
      for (int field=0; field < nFields; field++) {
        fNames[field] = new char[fNameLens[field]+1] {0};
        deser(data, fNames[field], fNameLens[field]*types_size[CHAR]);
      }

      output = mxCreateStructArray(nDims, dims, nFields, (const char**) fNames);
      if (nFields == 0) break;

      mxArray* cellData = deserialise(data, size, 1);

      for (int obj=0, elem=0; obj < nElem; obj++) {
        for (int field=0; field < nFields; field++, elem++) {
          mxArray* cellElem = mxGetCell(cellData, elem);
          mxSetFieldByNumber(output, obj, field, cellElem);
        }
      }
      delete fNameLens;
      for (int field = 0; field < nFields; field++) {
        delete fNames[field];
      }
      delete fNames;
    }
    break;

  case CELL:
    {
      output = mxCreateCellArray(nDims, dims);
      for (mwIndex i = 0; i < nElem; i++) {
        mxSetCell(output, i, deserialise(data, size, 1));
      }

    }
    break;
  }

  delete dims;
  delete cast_dims;

  // Avoid making plhs persistent
  if (recursed) {
    mexMakeArrayPersistent(output);
  }
  return output;
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

  memPtr = 0;
  mwSize size = mxGetNumberOfElements(prhs[0]);
  uint8_t* data = (uint8_t*) mxGetPr(prhs[0]);
  plhs[0] = deserialise(data, size, 0);
}
