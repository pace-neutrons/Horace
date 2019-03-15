#pragma once

#include <mex.h>
#include <string>
#include <sstream>
#include <typeinfo>
#include "pix_block_processor.h"

class hdf_pix_accessor;

enum input_types {
	init_access,
	close_access,
	read_data,
	get_info,
};
enum class initInputs : int { // all input for init procedure
	mode_name,
	filename,
	pixel_group_name,

	num_threads,  // not currently supported but left for the future
	N_INPUT_Arguments
};
enum class readInputs : int { // all input arguments for read procedure
	mode_name,
	io_class_ptr,

	block_positions,
	block_sizes,

	pix_buf_size,

	N_INPUT_Arguments
};
enum class closeOrGetInfInputs : int { // all input arguments for close IO procedure
	mode_name,
	io_class_ptr,

	N_INPUT_Arguments
};



enum class Init_Outputs : int { // output arguments for init procedure
	mex_reader_handle,
	N_OUTPUT_Arguments
};
enum class read_Outputs :int { // output arguments for read procedure
	pix_array,
	is_io_completed,
	mex_reader_handle,

	N_OUTPUT_Arguments
};
enum class get_info_out :int { // output arguments for read procedure
	filename,
	groupname,
	n_pixels,
	chunk_size,
	cache_nslots,
	cache_size,
	N_OUTPUT_Arguments
};

void throw_error(char const * const MESS_ID, char const * const error_message);

/*The class holding a selected C++ class and providing the exchange mechanism between this class and Matlab*/
#define CLASS_HANDLE_SIGNATURE 0x7D58FAB9
template<class T> class class_handle
{
public:
	class_handle(T *ptr) : _signature(CLASS_HANDLE_SIGNATURE), _name(typeid(T).name()), class_ptr(ptr),
		n_first_block(0), pos_in_first_block(0), n_threads(1) {}
	class_handle() : _signature(CLASS_HANDLE_SIGNATURE), _name(typeid(T).name()), class_ptr(new T()),
		n_first_block(0), pos_in_first_block(0), n_threads(1) {}

	~class_handle() {
		_signature = 0;
		delete class_ptr;
	}
	bool isValid() { return ((_signature == CLASS_HANDLE_SIGNATURE) && strcmp(_name.c_str(), typeid(T).name()) == 0); }

	size_t n_first_block;
	size_t pos_in_first_block;
	size_t n_threads;
	//
	std::string filename;
	std::string groupname;


	T* const class_ptr;
	mxArray * export_hanlder_toMatlab();
private:
	uint32_t _signature;
	const std::string _name;

};
template<class T>
mxArray * class_handle<T>::export_hanlder_toMatlab()
{
	mexLock();
	mxArray *out = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
	uint64_t *pData = (uint64_t *)mxGetData(out);
	*pData = reinterpret_cast<uint64_t>(this);
	return out;
}

template<class T> inline class_handle<T> *get_handler_fromMatlab(const mxArray *in)
{
	if (!in)
		throw_error("HDF_MEX_ACCESS:runtime_error", "hdf_reader received from Matlab evaluated to null pointer");

	if (mxGetNumberOfElements(in) != 1 || mxGetClassID(in) != mxUINT64_CLASS || mxIsComplex(in))
		throw_error("HDF_MEX_ACCESS:invalid_argument", "Handle input must be a real uint64 scalar.");

	class_handle<T> *ptr = reinterpret_cast<class_handle<T> *>(*((uint64_t *)mxGetData(in)));
	if (!ptr->isValid())
		throw_error("HDF_MEX_ACCESS:invalid_argument", "Retrieved handle does not point to correct class");
	return ptr;
}





class_handle<hdf_pix_accessor>* parse_inputs(int nlhs, int nrhs, const mxArray *prhs[],
	input_types &type_provided,
	double *&block_pos, double *&block_size, size_t &n_blocks, int &n_bytes,
	std::vector<pix_block_processor> &block_split_info, size_t &npix_to_read);
