#pragma once

#include <mex.h>
#include <matrix.h>
#include <limits>

enum ser_types{
  SELF_SER,
  SAVEOBJ,
  STRUCTED
};

const uint32_t DIM_MAX = std::numeric_limits<uint32_t>::max();

const size_t types_size[] = {
  1,  //   LOGICAL
  1,  //   CHAR
  2,  //   STRING
  8,  //   DOUBLE
  4,  //   SINGLE
  1,  //   INT8
  1,  //   UINT8
  2,  //   INT16
  2,  //   UINT16
  4,  //   INT32
  4,  //   UINT32
  8,  //   INT64
  8,  //   UINT64
  16, //   COMPLEX_DOUBLE
  8,  //   COMPLEX_SINGLE
  2,  //   COMPLEX_INT8
  2,  //   COMPLEX_UINT8
  4,  //   COMPLEX_INT16
  4,  //   COMPLEX_UINT16
  8,  //   COMPLEX_INT32
  8,  //   COMPLEX_UINT32
  16, //   COMPLEX_INT64
  16, //   COMPLEX_UINT64
  0,  //   CELL
  0,  //   STRUCT,
  0,  //   FUNCTION_HANDLE,
  0,  //   VALUE_OBJECT,
  0,  //   HANDLE_OBJECT_REF,
  0,  //   ENUM,
  1,  //   SPARSE_LOGICAL,
  8,  //   SPARSE_DOUBLE,
  16, //   SPARSE_COMPLEX_DOUBLE,
}; // Sizes

const mxClassID unmap_types[] = {
  mxLOGICAL_CLASS, //   LOGICAL
  mxCHAR_CLASS,    //   CHAR
  mxCHAR_CLASS,    //   STRING
  mxDOUBLE_CLASS,  //   DOUBLE
  mxSINGLE_CLASS,  //   SINGLE
  mxINT8_CLASS,    //   INT8
  mxUINT8_CLASS,   //   UINT8
  mxINT16_CLASS,   //   INT16
  mxUINT16_CLASS,  //   UINT16
  mxINT32_CLASS,   //   INT32
  mxUINT32_CLASS,  //   UINT32
  mxINT64_CLASS,   //   INT64
  mxUINT64_CLASS,  //   UINT64
  mxDOUBLE_CLASS,  //   COMPLEX_DOUBLE
  mxSINGLE_CLASS,  //   COMPLEX_SINGLE
  mxINT8_CLASS,    //   COMPLEX_INT8
  mxUINT8_CLASS,   //   COMPLEX_UINT8
  mxINT16_CLASS,   //   COMPLEX_INT16
  mxUINT16_CLASS,  //   COMPLEX_UINT16
  mxINT32_CLASS,   //   COMPLEX_INT32
  mxUINT32_CLASS,  //   COMPLEX_UINT32
  mxINT64_CLASS,   //   COMPLEX_INT64
  mxUINT64_CLASS,  //   COMPLEX_UINT64
  mxCELL_CLASS,    //   CELL
  mxSTRUCT_CLASS,  //   STRUCT,
  mxUNKNOWN_CLASS, //   FUNCTION_HANDLE,
  mxUNKNOWN_CLASS, //   VALUE_OBJECT,
  mxUNKNOWN_CLASS, //   HANDLE_OBJECT_REF,
  mxUNKNOWN_CLASS, //   ENUM,
  mxLOGICAL_CLASS, //   SPARSE_LOGICAL,
  mxDOUBLE_CLASS,  //   SPARSE_DOUBLE,
  mxDOUBLE_CLASS,  //   SPARSE_COMPLEX_DOUBLE,
};

const std::string types_names[] = {
  "LOGICAL",                //  0
  "CHAR",                   //  1
  "MATLAB_STRING",          //  2
  "DOUBLE",                 //  3
  "SINGLE",                 //  4
  "INT8",                   //  5
  "UINT8",                  //  6
  "INT16",                  //  7
  "UINT16",                 //  8
  "INT32",                  //  9
  "UINT32",                 // 10
  "INT64",                  // 11
  "UINT64",                 // 12
  "COMPLEX_DOUBLE",         // 13
  "COMPLEX_SINGLE",         // 14
  "COMPLEX_INT8",           // 15
  "COMPLEX_UINT8",          // 16
  "COMPLEX_INT16",          // 17
  "COMPLEX_UINT16",         // 18
  "COMPLEX_INT32",          // 19
  "COMPLEX_UINT32",         // 20
  "COMPLEX_INT64",          // 21
  "COMPLEX_UINT64",         // 22
  "CELL",                   // 23
  "STRUCT",                 // 24
  "FUNCTION_HANDLE",        // 25
  "VALUE_OBJECT",           // 26
  "HANDLE_OBJECT_REF",      // 27
  "ENUM",                   // 28
  "SPARSE_LOGICAL",         // 29
  "SPARSE_DOUBLE",          // 30
  "SPARSE_COMPLEX_DOUBLE",  // 31
};

enum types{
  LOGICAL,                  //  0
  CHAR,                     //  1
  MATLAB_STRING,            //  2
  DOUBLE,                   //  3
  SINGLE,                   //  4
  INT8,                     //  5
  UINT8,                    //  6
  INT16,                    //  7
  UINT16,                   //  8
  INT32,                    //  9
  UINT32,                   // 10
  INT64,                    // 11
  UINT64,                   // 12
  COMPLEX_DOUBLE,           // 13
  COMPLEX_SINGLE,           // 14
  COMPLEX_INT8,             // 15
  COMPLEX_UINT8,            // 16
  COMPLEX_INT16,            // 17
  COMPLEX_UINT16,           // 18
  COMPLEX_INT32,            // 19
  COMPLEX_UINT32,           // 20
  COMPLEX_INT64,            // 21
  COMPLEX_UINT64,           // 22
  CELL,                     // 23
  STRUCT,                   // 24
  FUNCTION_HANDLE,          // 25
  VALUE_OBJECT,             // 26
  HANDLE_OBJECT_REF,        // 27
  ENUM,                     // 28
  SPARSE_LOGICAL,           // 29
  SPARSE_DOUBLE,            // 30
  SPARSE_COMPLEX_DOUBLE,    // 31
};

struct tag_type {
  unsigned int type:5;
  unsigned int dim:3;
  tag_type() {};
};

const size_t TAG_SIZE = types_size[UINT8];
const size_t NELEMS_SIZE = types_size[UINT32];
const size_t DIMS_SIZE = types_size[UINT32];

tag_type tag_data(const mxArray* input) {
  int category = mxGetClassID(input);
  tag_type tag;

  if (category == mxUNKNOWN_CLASS) {
    mexErrMsgIdAndTxt("MATLAB:c_serial_size:unknownClass", "Unknown class.");
  }

  if (mxIsSparse(input)) {
    switch(category) {
    case mxLOGICAL_CLASS:
      tag.type = SPARSE_LOGICAL;
      break;

    case mxDOUBLE_CLASS:
      if (mxIsComplex(input)) {
        tag.type = SPARSE_COMPLEX_DOUBLE;
      } else {
        tag.type = SPARSE_DOUBLE;
      }
      break;

    }
  } else {
    switch(category) {
    case mxLOGICAL_CLASS:
      tag.type = LOGICAL;
      break;
    case mxCHAR_CLASS:
      tag.type = CHAR;
      break;
    case mxDOUBLE_CLASS:
      tag.type = DOUBLE;
      break;
    case mxSINGLE_CLASS:
      tag.type = SINGLE;
      break;
    case mxINT8_CLASS:
      tag.type = INT8;
      break;
    case mxUINT8_CLASS:
      tag.type = UINT8;
      break;
    case mxINT16_CLASS:
      tag.type = INT16;
      break;
    case mxUINT16_CLASS:
      tag.type = UINT16;
      break;
    case mxINT32_CLASS:
      tag.type = INT32;
      break;
    case mxUINT32_CLASS:
      tag.type = UINT32;
      break;
    case mxINT64_CLASS:
      tag.type = INT64;
      break;
    case mxUINT64_CLASS:
      tag.type = UINT64;
      break;
    case mxCELL_CLASS:
      tag.type = CELL;
      break;
    case mxSTRUCT_CLASS:
      tag.type = STRUCT;
      break;
    default:
      if (!strcmp(mxGetClassName(input), "function_handle")) {
        tag.type = FUNCTION_HANDLE;
      } else {
        tag.type = VALUE_OBJECT;
      }
      break;
    }
    if (mxIsComplex(input)) tag.type += 10;
  }
  return tag;
}
