// hdf_mex_reader : Defines the exported functions for the DLL application.
//

#include "hdf_mex_reader.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	const char REVISION[] = "$Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)";
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

	class_handle<hdf_pix_accessor>* pReaderHolder = parse_inputs(nlhs, nrhs, prhs,
		work_type,
		pBlock_pos, pBlock_sizes, n_blocks, n_bytes,
		block_split_info, npix_to_read);

	n_threads = pReaderHolder->n_threads;
	switch (work_type)
	{
	case(init_access):{
		pReaderHolder->class_ptr->init(pReaderHolder->filename, pReaderHolder->groupname);
		plhs[(int)Init_Outputs::mex_reader_handle] = pReaderHolder->export_hanlder_toMatlab();
		return;
	}
	case(get_file_info): {
		if (nlhs > 0)
			plhs[(int)file_info_out::filename] = mxCreateString(pReaderHolder->filename.c_str());
		if (nlhs > 1)
			plhs[(int)file_info_out::groupname] = mxCreateString(pReaderHolder->groupname.c_str());
		if (nlhs > 2) {
			size_t  n_pixels, max_num_pixels, chunk_size, cache_nslots, cache_size;
			pReaderHolder->class_ptr->get_info(n_pixels, max_num_pixels, chunk_size, cache_nslots, cache_size);
			plhs[(int)file_info_out::n_pixels] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
			uint64_t * pData = (uint64_t *)mxGetData(plhs[(int)file_info_out::n_pixels]);
			*pData = n_pixels;
			if (nlhs > 3) {
				plhs[(int)file_info_out::chunk_size] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
				uint64_t * pData = (uint64_t *)mxGetData(plhs[(int)file_info_out::chunk_size]);
				*pData = chunk_size;
			}
			if (nlhs > 4) {
				plhs[(int)file_info_out::cache_nslots] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
				uint64_t * pData = (uint64_t *)mxGetData(plhs[(int)file_info_out::cache_nslots]);
				*pData = cache_nslots;
			}
			if (nlhs > 5) {
				plhs[(int)file_info_out::cache_size] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
				uint64_t * pData = (uint64_t *)mxGetData(plhs[(int)file_info_out::cache_size]);
				*pData = cache_size;
			}
		}
		return;
	}
	case(get_read_info): {
		if (nlhs > 0){
			plhs[(int)read_info_out::n_blocks_read] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
			uint64_t * pData = (uint64_t *)mxGetData(plhs[(int)read_info_out::n_blocks_read]);
			*pData = pReaderHolder->n_first_block;
		}
		if (nlhs > 1) {
			plhs[(int)read_info_out::pos_in_first_block] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
			uint64_t * pData = (uint64_t *)mxGetData(plhs[(int)read_info_out::pos_in_first_block]);
			*pData = pReaderHolder->pos_in_first_block;
		}

		return;
	}
	case(close_access):{
		pReaderHolder->clear_mex_locks();
		delete pReaderHolder;


		for (int i = 0; i < nlhs; ++i) {
			plhs[i] = mxCreateNumericMatrix(0, 0, mxUINT64_CLASS, mxREAL);
		}
		return;
	}
	}
	// only read mode now;

	float *pixArray(nullptr);

	if (nlhs > 0) {
		plhs[(int)read_Outputs::pix_array] = mxCreateNumericMatrix(9, npix_to_read, mxSINGLE_CLASS, mxREAL);
		pixArray = (float*)mxGetData(plhs[int(read_Outputs::pix_array)]);
	}
	pReaderHolder->class_ptr->read_pixels(block_split_info[0], pixArray, npix_to_read);
	//
	pReaderHolder->n_first_block = block_split_info[n_threads].n_blocks;
	pReaderHolder->pos_in_first_block = block_split_info[n_threads].pos_in_first_block;



	if (nlhs > 1) {
		plhs[(int)read_Outputs::is_io_completed] = mxCreateNumericMatrix(1, 1, mxLOGICAL_CLASS, mxREAL);
		auto pIO_completed = (bool*)mxGetData(plhs[int(read_Outputs::is_io_completed)]);

		size_t n_blocks_processed = block_split_info[n_threads].n_blocks;
		size_t pos_in_first_block = block_split_info[n_threads].pos_in_first_block;
		if (n_blocks_processed >= n_blocks && pos_in_first_block == 0)
			*pIO_completed = true;
		else
			*pIO_completed = false;

	}
	if (nlhs > 2)
		plhs[(int)read_Outputs::mex_reader_handle] = pReaderHolder->export_hanlder_toMatlab();


}

