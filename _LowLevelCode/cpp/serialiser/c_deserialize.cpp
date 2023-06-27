/*=========================================================
 * c_deserialize.cpp
 * Deserialize serialized data back into a MATLAB object
 *
 * See also:
 * hlp_serialize
 * hlp_deserialize
 *
 * This is a MEX-file for MATLAB.
 *=======================================================*/
#include <iostream>
#include <string>
#include <cstring>
#include <cmath>
#include <vector>
#include "../utility/version.h"
#include "cpp_serialize.hpp"

template<typename T, typename A>
inline void deser(const uint8_t* data, size_t& memPtr, std::vector<T, A>& output, const size_t amount) {
    memcpy(output.data(), &data[memPtr], amount);
    memPtr += amount;
}

inline void deser(const uint8_t* data, size_t& memPtr, void* output, const size_t amount) {
    memcpy(output, &data[memPtr], amount);
    memPtr += amount;
}

inline void read_data(uint8_t* data, size_t& memPtr, mxArray* output, const size_t elemSize, const size_t nElem) {
    if (mxIsComplex(output)) {
        // Size of a complex component is half that of the whole complex
        size_t compSize = elemSize / 2;

#if MX_HAS_INTERLEAVED_COMPLEX
        void* toWrite = mxGetComplexDouble(output);
        // Offset imaginary to end
        size_t imPtr = memPtr + (1 + nElem) * compSize;

        for (size_t i = 0; i < nElem; i += elemSize, memPtr += compSize, imPtr += compSize) {
            memcpy(&toWrite[i], &data[memPtr], compSize);
            memcpy(&toWrite[i + compSize], &data[imPtr], compSize);
        }
        memPtr = imPtr; // Finally update memPtr

#else
        void* toWrite = mxGetPr(output);
        deser(data, memPtr, toWrite, compSize * nElem);
        toWrite = mxGetPi(output);
        deser(data, memPtr, toWrite, compSize * nElem);

#endif

    }
    else {
        void* toWrite = mxGetPr(output);
        deser(data, memPtr, toWrite, elemSize * nElem);
    }
}


mxArray* deserialize(uint8_t* data, size_t& memPtr, size_t size, bool recursed) {

    mxArray* output = nullptr;

    tag_type tag;
    deser(data, memPtr, &tag.type, types_size[UINT8]);

    size_t nDims;
    std::vector<uint32_t> cast_dims(2);
    std::vector<mwSize> vDims(2);
    size_t nElem;

    // Special case as function handles work differently
    switch (tag.type) {
    case FUNCTION_HANDLE:
    case FUNCTION_HANDLE + 64:
    case FUNCTION_HANDLE + 128:
    case FUNCTION_HANDLE + 192:
    {
        // Function handle always scalar
        std::fill(vDims.begin(), vDims.end(), 1);
        std::fill(cast_dims.begin(), cast_dims.end(), 1);
        nElem = 1;
        break;
    }
    default:
        deser(data, memPtr, &tag.dim, types_size[UINT8]);
        nDims = tag.dim;

        if (nDims > 2) {
            vDims.resize(nDims);
            cast_dims.resize(nDims);
        }

        deser(data, memPtr, cast_dims, nDims * types_size[UINT32]);

        switch (nDims) {
        case 0:
            nElem = 0;
            nDims = 2;
            std::fill(vDims.begin(), vDims.end(), 0);
            break;

        case 1:
            nElem = cast_dims[0];
            nDims = 2;
            vDims[0] = 1;
            vDims[1] = nElem;
            break;

        default:
            nElem = 1;

            for (size_t i = 0; i < nDims; i++) {
                vDims[i] = cast_dims[i];
                nElem *= vDims[i];
            }
            break;

        }
        break;
    }

    // C Mex API requires pointer, not vector
    mwSize* dims = vDims.data();

    switch (tag.type) {
        // Sparse
    case SPARSE_LOGICAL:
    case SPARSE_DOUBLE:
    case SPARSE_COMPLEX_DOUBLE:
    {
        uint32_t nnz;
        deser(data, memPtr, &nnz, types_size[UINT32]);

        if (tag.type == SPARSE_LOGICAL) {
            output = mxCreateSparseLogicalMatrix(dims[0], dims[1], nnz);
        }
        else {
            mxComplexity cmplx = (mxComplexity)(tag.type == SPARSE_COMPLEX_DOUBLE);
            output = mxCreateSparse(dims[0], dims[1], nnz, cmplx);
        }
        mwIndex* ir = mxGetIr(output);
        mwIndex* jc = mxGetJc(output);
        std::vector<uint64_t> map_jc(nnz);

        deser(data, memPtr, ir, types_size[UINT64] * nnz);
        deser(data, memPtr, map_jc, types_size[UINT64] * nnz);

        // Unmap Jc (see MATLAB docs on sparse arrays in MEX API)
        for (const uint64_t& row : map_jc) {
            jc[row + 1]++;
        }

        for (mwSize i = 1; i < dims[1] + 1; i++) {
            jc[i] += jc[i - 1];
        }

        read_data(data, memPtr, output, types_size[tag.type], nnz);

    }
    break;
    case CHAR:
    {
        std::vector<char> arr(nElem + 1);
        deser(data, memPtr, arr, nElem * types_size[CHAR]);
        output = mxCreateCharArray(nDims, dims);
        char* out = (char*)mxGetPr(output);
        for (size_t i = 0; i < nElem; i++) {
            out[2 * i] = arr[i];
        }
    }
    break;
    case LOGICAL:
        output = mxCreateLogicalArray(nDims, dims);
        read_data(data, memPtr, output, types_size[tag.type], nElem);
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
        // Complex tags are 13-22
        mxComplexity cmplx = (mxComplexity)(12 < tag.type && tag.type < 23);
        output = mxCreateNumericArray(nDims, dims, unmap_types[tag.type], cmplx);
        read_data(data, memPtr, output, types_size[tag.type], nElem);
    }
    break;

    case FUNCTION_HANDLE:
    case FUNCTION_HANDLE + 64:
    {
        mxArray* name = deserialize(data, memPtr, size, 1);
        mexCallMATLAB(1, &output, 1, &name, "str2func");
        mxDestroyArray(name);
    }
    break;
    case FUNCTION_HANDLE + 128:
    {
        mxArray* name = deserialize(data, memPtr, size, 1);
        mxArray* workspace = deserialize(data, memPtr, size, 1);
        std::vector<mxArray*> input{ name, workspace };
        mexCallMATLAB(1, &output, 2, input.data(), "restore_function");
        mxDestroyArray(name);
        mxDestroyArray(workspace);
    }
    break;
    case FUNCTION_HANDLE + 192:
    {
        mxArray* parentage = deserialize(data, memPtr, size, 1);
        const size_t len = (size_t)mxGetNumberOfElements(parentage);

        // Initial output
        output = mxDuplicateArray(mxGetCell(parentage, len - 1));

        std::vector<mxArray*> input(3);

        mxArray* stringHandle = mxCreateString("handle");
        input[0] = stringHandle;
        input[1] = output;
        for (int i = len - 2; i >= 0; i--) {
            input[2] = mxGetCell(parentage, i);
            mexCallMATLAB(1, &output, 3, input.data(), "arg_report");
        }
        mxDestroyArray(stringHandle);
        mxDestroyArray(parentage);
        break;
    }

    case VALUE_OBJECT:
    {

        memPtr += 2; // Skip name_tag and dim tag


        uint32_t nameLen;
        deser(data, memPtr, &nameLen, types_size[UINT32]);

        std::string name = std::string(nameLen, ' ');

        deser(data, memPtr, &name[0], nameLen * types_size[CHAR]);

        uint8_t ser_tag;
        deser(data, memPtr, &ser_tag, types_size[UINT8]);

        if (name == "MException") {
          name += "_her";
          ser_tag = 1;
        }

        switch (ser_tag) {
        case SELF_SER:
        {
            mxArray* mxName = mxCreateString(name.data());
            mxArray* mxData = mxCreateUninitNumericMatrix(0, 1, mxUINT8_CLASS, (mxComplexity)0);
            double* tmp = mxGetPr(mxData);
            mxSetM(mxData, size - memPtr);
            mxSetPr(mxData, (double*)&data[memPtr]);

            std::vector<mxArray*> results(2);
            std::vector<mxArray*> input{ mxName, mxData };
            mexCallMATLAB(2, results.data(), 2, input.data(), "c_hlp_deserialize_object_self");
            output = results[0];
            memPtr += (size_t)mxGetScalar(results[1]);
            mxDestroyArray(mxName);

            mxSetM(mxData, 0);
            mxSetPr(mxData, tmp);
            mxDestroyArray(mxData);
        }
        break;
        case SAVEOBJ:
        {
            mxArray* mxName = mxCreateString(name.data());
            mxArray* conts = deserialize(data, memPtr, size, 1);
            std::vector<mxArray*> input{ mxName, conts };
            mexCallMATLAB(1, &output, 2, input.data(), "c_hlp_deserialize_object_loadobj");
            mxDestroyArray(conts);
            mxDestroyArray(mxName);
        }
        break;
        case STRUCTED:
        {
            output = deserialize(data, memPtr, size, 1);
            mxSetClassName(output, name.data());
        }
        break;
        }

    }
    break;

    case STRUCT:
    {
        uint32_t nFields;
        deser(data, memPtr, &nFields, types_size[UINT32]);

        std::vector<uint32_t> fNameLens(nFields);
        deser(data, memPtr, fNameLens, nFields * types_size[UINT32]);

        std::vector<std::vector<char>> fNames(nFields);
        std::vector<char*> mxData(nFields);
        for (uint32_t field = 0; field < nFields; field++) {
            fNames[field] = std::vector<char>(fNameLens[field] + 1);
            mxData[field] = fNames[field].data();
            fNames[field][fNameLens[field]] = 0;
            deser(data, memPtr, fNames[field], fNameLens[field] * types_size[CHAR]);
        }

        output = mxCreateStructArray(nDims, dims, nFields, (const char**)mxData.data());
        if (nFields == 0) break;

        mxArray* cellData = deserialize(data, memPtr, size, 1);

        for (size_t obj = 0, elem = 0; obj < nElem; obj++) {
            for (uint32_t field = 0; field < nFields; field++, elem++) {
                mxArray* cellElem = mxGetCell(cellData, elem);
                mxSetFieldByNumber(output, obj, field, cellElem);
            }
        }

    }
    break;

    case CELL:
    {
        output = mxCreateCellArray(nDims, dims);
        for (mwIndex i = 0; i < nElem; i++) {
            mxArray* elem = deserialize(data, memPtr, size, 1);
            mxSetCell(output, i, elem);
        }
    }
    break;

    case SERIALIZABLE:
    {

        memPtr -= TAG_SIZE + nDims * types_size[UINT32]; // ndims, skip tag

        mxArray* mxData = mxCreateUninitNumericMatrix(0, 1, mxUINT8_CLASS, (mxComplexity)0);
        double* tmp = mxGetPr(mxData);
        mxSetM(mxData, size - memPtr);
        mxSetPr(mxData, (double*)&data[memPtr]);

        std::vector<mxArray*> results(2);
        mexCallMATLAB(2, results.data(), 1, &mxData, "hlp_deserialize");
        output = results[0];
        memPtr += (size_t)mxGetScalar(results[1]);

        mxSetM(mxData, 0);
        mxSetPr(mxData, tmp);
        mxDestroyArray(mxData);
        mxDestroyArray(results[1]);

    }
    break;
    }

    /* Avoid making plhs persistent,
       others *should* deallocate when the root object does
       (according to MEX docs) */
    if (recursed) {
        mexMakeArrayPersistent(output);
    }
    return output;
}

/* MATLAB entry point c_deserialize */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {

    //--------->  RETURN MEX-file version if requested;
    if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
        plhs[0] = mxCreateString(Horace::VERSION);
        return;
    }

#if defined(_LP64) || defined (_WIN64)
#ifdef MX_COMPAT_32
    for (i = 0; i < nrhs; i++) {
        if (mxIsSparse(prhs[i])) {
            mexErrMsgIdAndTxt("MATLAB:c_deserialize:NoSparseCompat",
                "MEX-files compiled on a 64-bit platform that use sparse array functions "
                "need to be compiled using -largeArrayDims.");
        }
    }
#endif
#endif

    if (nlhs > 2) {
        mexErrMsgIdAndTxt("MATLAB:c_deserialize:badLHS", "Bad number of LHS arguments in c_deserialize");
    }
    if (nrhs < 1 || nrhs > 2) {
        mexErrMsgIdAndTxt("MATLAB:c_deserialize:badRHS", "Bad number of RHS arguments in c_deserialize");
    }

    // the position of the data in the input bytes array. By default, it's 0
    size_t initial_pos(0);
    if (nrhs == 2) { // get the position from second argument. Convert from Matlab to C indexing convention
        initial_pos = (size_t)mxGetScalar(prhs[1]) - 1;
    }

    size_t memPtr = initial_pos;
    mwSize size = mxGetNumberOfElements(prhs[0]);
    uint8_t* data = (uint8_t*)mxGetPr(prhs[0]);

    plhs[0] = deserialize(data, memPtr, size, 0);
    size_t size_count = memPtr - initial_pos;
    if (nlhs == 2) {
        plhs[1] = mxCreateDoubleScalar((double)size_count);
    }
}
