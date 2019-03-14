// hdf_mex_accessor.cpp : Defines the exported functions for the DLL application.
//

#include "hdf_mex_reader.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	const char REVISION[] = "$Revision::      $ ($Date::                                              $)";
	if (nrhs == 0 && nlhs == 1) {
		plhs[0] = mxCreateString(REVISION);
		return;
	}

	//* Check and parce input  arguments. */
	double *pBlock_pos(nullptr);
	double *pBlock_sizes(nullptr);
	size_t n_blocks, n_threads;

	size_t npix_to_read;
	input_types work_type;
	int n_bytes(0);

	std::vector<pix_block_processor> block_split_info;

	class_handle<hdf_pix_accessor>* pReaderHolder = parse_inputs(nlhs, plhs, nrhs, prhs,
		work_type,
		pBlock_pos, pBlock_sizes, n_blocks, n_bytes,
		block_split_info, npix_to_read);

	n_threads = block_split_info.size() - 1;

	if (work_type == init_access) {
		if (nrhs > 0) {
			plhs[(int)Init_Outputs::mex_reader_handle] = pReaderHolder->export_hanlder_toMatlab();
		}
		return;
	}
	if (work_type == get_filename) {
		if (nrhs > 0)
			plhs[(int)get_filename_out::filename] = mxCreateString(pReaderHolder->filename.c_str());
		if (nrhs > 1)
			plhs[(int)get_filename_out::groupname] = mxCreateString(pReaderHolder->groupname.c_str());
		if (nrhs > 2)
			plhs[(int)get_filename_out::mex_reader_handle] = pReaderHolder->export_hanlder_toMatlab();
		return;
	}
	if (work_type == close_access) {
		delete pReaderHolder;
		mexUnlock();

		for (int i = 0; i < nlhs; ++i) {
			plhs[i] = mxCreateNumericMatrix(0, 0, mxUINT64_CLASS, mxREAL);
		}
		return;
	}
	// only read mode now;

	float *pixArray(nullptr);

	if (nlhs > 0) {
		plhs[(int)read_Outputs::pix_array] = mxCreateNumericMatrix(9, npix_to_read, mxSINGLE_CLASS, mxREAL);
		pixArray = (float*)mxGetPr(plhs[int(read_Outputs::pix_array)]);
	}
	pReaderHolder->class_ptr->read_pixels(block_split_info[0], pixArray, npix_to_read);


	if (nlhs > 1) {
		plhs[(int)read_Outputs::is_io_completed] = mxCreateNumericMatrix(1, 1, mxLOGICAL_CLASS, mxREAL);
		auto pIO_completed = (bool*)mxGetPr(plhs[int(read_Outputs::is_io_completed)]);

		size_t n_blocks_processed = block_split_info[n_threads].n_blocks;
		size_t pos_in_first_block = block_split_info[n_threads].pos_in_first_block;
		if (n_blocks_processed >= n_blocks && pos_in_first_block == 0)
			*pIO_completed = true;
		else
			*pIO_completed = false;
	}
	if (nlhs > 2) {
		pReaderHolder->n_first_block = block_split_info[n_threads].n_blocks;
		pReaderHolder->pos_in_first_block = block_split_info[n_threads].pos_in_first_block;
		plhs[(int)read_Outputs::mex_reader_handle] = pReaderHolder->export_hanlder_toMatlab();
	}

}
