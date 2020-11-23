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

const int types_size[] = {
  0,  //   UNKNOWN
  1,  //   LOGICAL
  1,  //   CHAR
  8,  //   DOUBLE
  4,  //   SINGLE
  2,  //   INT8
  2,  //   UINT8
  4,  //   INT16
  4,  //   UINT16
  8,  //   INT32
  8,  //   UINT32
  16, //   INT64
  16, //   UINT64
  16, //   COMPLEX_DOUBLE
  8,  //   COMPLEX_SINGLE
  4,  //   COMPLEX_INT8
  4,  //   COMPLEX_UINT8
  8,  //   COMPLEX_INT16
  8,  //   COMPLEX_UINT16
  16, //   COMPLEX_INT32
  16, //   COMPLEX_UINT32
  32, //   COMPLEX_INT64
  32  //   COMPLEX_UINT64
}; // Sizes


  // UNKNOWN,
  // LOGICAL,
  // CHAR,
  // DOUBLE,
  // SINGLE,
  // INT8,
  // UINT8,
  // INT16,
  // UINT16,
  // INT32,
  // UINT32,
  // INT64,
  // UINT64,
  // COMPLEX_DOUBLE,
  // COMPLEX_SINGLE,
  // COMPLEX_INT8,
  // COMPLEX_UINT8,
  // COMPLEX_INT16,
  // COMPLEX_UINT16,
  // COMPLEX_INT32,
  // COMPLEX_UINT32,
  // COMPLEX_INT64,
  // COMPLEX_UINT64,
  // CELL,
  // STRUCT,
  // VALUE_OBJECT,
  // HANDLE_OBJECT_REF,
  // ENUM,
  // SPARSE_LOGICAL,
  // SPARSE_DOUBLE,
  // SPARSE_COMPLEX_DOUBLE,
  // MATLAB_STRING








using matlab::mex::ArgumentList;
using namespace matlab::data;

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
      ArrayType type = input.getType();
      int x = static_cast<int>(type);
      switch (type) {
      case ArrayType::LOGICAL:
      case ArrayType::CHAR:
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
	size += 2 +  // Tag & Numdims
	  types_size[x] * input.getNumberOfElements();
	break;

      case ArrayType::STRUCT: {

	StructArray obj = static_cast<StructArray>(input);

	auto fields = obj.getFieldNames();

	for (matlab::data::MATLABFieldIdentifier field: fields) {
	  auto elem = obj[field];

	  std::string outField = static_cast<std::string>(field);
	  stream << "Data field: " << outField << std::endl;
	  display(stream);
	}}
	break;

      default:
	error("Unknown data type");
	break;
      }
    }

    outputs[0] = factory.createScalar(size);
  }
private:
  void error(std::string message) {
    matlabPtr->feval(u"error", 0,
		     std::vector<matlab::data::Array>({ factory.createScalar(message)}));
  }

  void display(std::ostringstream& stream) {
    // Pass stream content to MATLAB fprintf function
    matlabPtr->feval(u"fprintf", 0,
		     std::vector<Array>({ factory.createScalar(stream.str()) }));
    // Clear stream buffer
    stream.str("");
  }
};
