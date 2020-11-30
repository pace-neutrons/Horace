/* hlp_serial_size
   Calculate the size (in bytes) of Matlab structure, which would be produced by
   hpl_serialize routine. Deduced from hpl_serialize/

   See also:
   hlp_serialize
   hlp_deserialize

   Examples:
   >>num_bytes = hlp_serial_size(mydata);
   >>bytes = hlp_serialize(mydata)
   >>numel(bytes) == num_bytes
   >>True

   dispatch according to type
*/

#include <iostream>
#include "mex.hpp"
#include "mexAdapter.hpp"

using matlab::mex::ArgumentList;
using namespace matlab::data;

const uint32_t types_size[] = {
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
  8, //   INT64
  8, //   UINT64
  1 + 1 + 4 + 16, //   COMPLEX_DOUBLE
  1 + 1 + 4 + 8,  //   COMPLEX_SINGLE
  1 + 1 + 4 + 2,  //   COMPLEX_INT8
  1 + 1 + 4 + 2,  //   COMPLEX_UINT8
  1 + 1 + 4 + 4,  //   COMPLEX_INT16
  1 + 1 + 4 + 4,  //   COMPLEX_UINT16
  1 + 1 + 4 + 8, //   COMPLEX_INT32
  1 + 1 + 4 + 8, //   COMPLEX_UINT32
  1 + 1 + 4 + 16, //   COMPLEX_INT64
  1 + 1 + 4 + 16, //   COMPLEX_UINT64
  0,  //   CELL
  0,  //   STRUCT,
  0,  //   UNKNOWN,
  0,  //   VALUE_OBJECT,
  0,  //   HANDLE_OBJECT_REF,
  0,  //   ENUM,
  1,  //   SPARSE_LOGICAL,
  8,  //   SPARSE_DOUBLE,
  16, //   SPARSE_COMPLEX_DOUBLE,
  0,  //   UNKNOWN
}; // Sizes

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
  "UNKNOWN",
  "VALUE_OBJECT",           // 26
  "HANDLE_OBJECT_REF",      // 27
  "ENUM",                   // 28
  "SPARSE_LOGICAL",         // 29
  "SPARSE_DOUBLE",          // 30
  "SPARSE_COMPLEX_DOUBLE",  // 31
  "UNKNOWN"                 // 32
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
  RANDOM_BLANK,             // 25
  VALUE_OBJECT,             // 26
  HANDLE_OBJECT_REF,        // 27
  ENUM,                     // 28
  SPARSE_LOGICAL,           // 29
  SPARSE_DOUBLE,            // 30
  SPARSE_COMPLEX_DOUBLE,    // 31
  UNKNOWN,                  // 32
};

const uint32_t TAG_SIZE = types_size[UINT8];
const uint32_t NDIMS_SIZE = types_size[UINT8];
const uint32_t NELEMS_SIZE = types_size[UINT32];

class MexFunction : public matlab::mex::Function {
  std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();

  // Factory to create MATLAB data arrays
  ArrayFactory factory;

  // Create an output stream
  std::ostringstream stream;
public:
  void operator()(ArgumentList outputs, ArgumentList inputs) {

    // Assign the input object to a matlab::data::Array
    uint32_t size = 0;
    for (matlab::data::Array input: inputs) {
      size += get_size(input);
    }

    outputs[0] = factory.createScalar(size);

  }

private:
  int get_size(matlab::data::Array input) {
    uint32_t size = 0;
    ArrayType type = input.getType();
    int x = static_cast<int>(type);
    // stream << "Parsing type " << types_names[x] << std::endl;
    // display(stream);

    switch (type) {
    case ArrayType::LOGICAL:
      {
	size_t nElem = input.getNumberOfElements();
	std::vector<size_t> dims = input.getDimensions();
	size_t nDims = dims.size();
	size += TAG_SIZE + NDIMS_SIZE + NELEMS_SIZE*nDims + types_size[x] * nElem;
      }
      break;
    case ArrayType::CHAR:
      {       
	size_t nElem = input.getNumberOfElements();
	std::vector<size_t> dims = input.getDimensions();
	size_t nDims = dims.size();

	if (nElem == 0) { // Null (string?)
	  size += TAG_SIZE;
	}
        else if (nElem == 1) { // Scalar
          size += TAG_SIZE + types_size[x];
        }
        else if (nDims == 2 && dims[1] == 1) { // List
          size += TAG_SIZE + NELEMS_SIZE + types_size[x] * nElem;
        }
        else { // General array
          size += TAG_SIZE + NDIMS_SIZE + NELEMS_SIZE*nDims + types_size[x] * nElem;
        }
      }
      break;

    case ArrayType::DOUBLE:
    case ArrayType::SINGLE:
    case ArrayType::INT8:
    case ArrayType::UINT8:
    case ArrayType::INT16:
    case ArrayType::UINT16:
    case ArrayType::INT32:
    case ArrayType::UINT32:
    case ArrayType::INT64:
    case ArrayType::UINT64:
    case ArrayType::COMPLEX_DOUBLE:
    case ArrayType::COMPLEX_SINGLE:
    case ArrayType::COMPLEX_INT8:
    case ArrayType::COMPLEX_UINT8:
    case ArrayType::COMPLEX_INT16:
    case ArrayType::COMPLEX_UINT16:
    case ArrayType::COMPLEX_INT32:
    case ArrayType::COMPLEX_UINT32:
    case ArrayType::COMPLEX_INT64:
    case ArrayType::COMPLEX_UINT64:
      {       
	size_t nElem = input.getNumberOfElements();
	std::vector<size_t> dims = input.getDimensions();
	size_t nDims = dims.size();

	if (nElem == 0) { // Null (string?)
	  size += TAG_SIZE;
	}
        else if (nElem == 1) { // Scalar
          size += TAG_SIZE + types_size[x];
        }
        else { // General array
          size += TAG_SIZE + NDIMS_SIZE + NELEMS_SIZE*nDims + types_size[x] * nElem;
        }
      }
      break;

    case ArrayType::SPARSE_LOGICAL:
    case ArrayType::SPARSE_DOUBLE:
    case ArrayType::SPARSE_COMPLEX_DOUBLE:
      {
        size_t nElem;
        switch(type) {
        case ArrayType::SPARSE_LOGICAL:
          nElem = SparseArray<bool>(input).getNumberOfNonZeroElements();
          break;
        case ArrayType::SPARSE_DOUBLE:
          nElem = SparseArray<double>(input).getNumberOfNonZeroElements();
          break;
        case ArrayType::SPARSE_COMPLEX_DOUBLE:
          nElem = SparseArray<std::complex<double>>(input).getNumberOfNonZeroElements();
          break;
        }
        size += TAG_SIZE + 2*types_size[UINT64]; // Tag & Dims
	size += 2 * (TAG_SIZE + NDIMS_SIZE + 2*NELEMS_SIZE + types_size[UINT32]*nElem);          // Indices (as Tag, ndim, dim, val)
	size += types_size[UINT8];   // Real/Complex/Logical indicator
	size += TAG_SIZE + NDIMS_SIZE + 2*NELEMS_SIZE + types_size[x] * nElem;  // Data (as Tag, ndim, dim, val)
	  }
      break;

    // case ArrayType::MATLAB_STRING:
    //   size += 1 + 4;  // Tag & NumDims

    //   for (int i = 0; i < input.getNumberOfElements(); i++) {
    //     matlab::data::CharArray in = matlabPtr->getProperty(input[i], u"data");
    //     size += types_size[x] + in.getNumberOfElements();
    //   }
    //   break;

    case ArrayType::STRUCT:
      {
	// Only supports single array object
	size_t nElem = input.getNumberOfElements();
	if (nElem /= 1) {
	  stream << "Struct array serialise only supports 1x1 struct arrays";
	  error(stream);
	}
	// std::vector<size_t> dims = input.getDimensions();
	// size_t nDims = dims.size();
	// size += TAG_SIZE + 4 + 4*nDims;  // Tag & NumDims & Dims

        StructArray obj = static_cast<StructArray>(input);
	
	Range<ForwardIterator, const MATLABFieldIdentifier> fields = obj.getFieldNames();
	size += TAG_SIZE;
	size += NELEMS_SIZE*obj.getNumberOfFields(); // Number of name lens
	  
        for (matlab::data::MATLABFieldIdentifier field: fields) {
          matlab::data::Array elem = obj[0][field];
          size += std::string(field).size() * types_size[CHAR]; // FieldName
          size += get_size(elem); // Data
       }
      }
      break;

    case ArrayType::CELL:
      {
	size_t nElem = input.getNumberOfElements();
	std::vector<size_t> dims = input.getDimensions();
	size_t nDims = dims.size();

	if (nElem == 0) { // Null (string?)
	  size += TAG_SIZE;
	}
        else if (nElem == 1) { // Scalar
          size += TAG_SIZE;
        }
        else if (nDims == 2 && dims[1] == 1) { // List
          size += TAG_SIZE + NELEMS_SIZE;
        }
        else { // General array
          size += TAG_SIZE + NDIMS_SIZE + NELEMS_SIZE*nDims;
        }

	matlab::data::TypedArray<matlab::data::Array> cellArr = input;
	for(matlab::data::Array elem: cellArr) {
	  size += get_size(elem);
	}
      }
      break;
    case ArrayType::VALUE_OBJECT:
    case ArrayType::HANDLE_OBJECT_REF:
      
    default:
      stream << "Unknown data type " << types_names[x] << std::endl;
      error(stream);
      break;
    }
    return size;
  }


  void error(std::ostringstream& message) {
    matlabPtr->feval(u"error", 0,
                     std::vector<matlab::data::Array>({ factory.createScalar(message.str())}));
  }

  void display(std::ostringstream& stream) {
    // Pass stream content to MATLAB fprintf function
    matlabPtr->feval(u"fprintf", 0,
                     std::vector<matlab::data::Array>({ factory.createScalar(stream.str()) }));
    // Clear stream buffer
    stream.str("");
  }
};
