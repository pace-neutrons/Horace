// hdf_mex_accessor.cpp : Defines the exported functions for the DLL application.
//

#include "hdf_mex_accessor.h"

std::vector<std::unique_ptr<hdf_pix_accessor> > file_readers;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision::      $ ($Date::                                              $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }

    //* Check and parce input  arguments. */
    input_file new_input_file;
    double *pBlock_pos(nullptr);
    double *pBlock_sizes(nullptr);
    size_t n_blocks, n_threads;
    hsize_t first_block_non_read(1);
    size_t npix_to_read;
    int n_bytes(0);
    float *pixArray(nullptr);
    std::vector<pix_block_processor> block_split_info;

    auto work_type = parse_inputs(nlhs, plhs, nrhs, prhs,
        new_input_file,
        pBlock_pos, pBlock_sizes, n_blocks, n_bytes,
        block_split_info, npix_to_read);

    n_threads = block_split_info.size() - 1;
    if (work_type != close_file) {
        if (file_readers.size() != n_threads) {
            file_readers.resize(n_threads);
            for (size_t i = 0; i < n_threads; i++) {
                file_readers[i].reset(nullptr);
            }
        }
        for (size_t i = 0; i < n_threads; i++) {
            if (file_readers[i].get() == nullptr) {
                work_type = open_and_read_data;
                break;
            }
        }
    }
    if (nlhs > 0) {
        plhs[pix_array] = mxCreateNumericMatrix(9, npix_to_read, mxSINGLE_CLASS, mxREAL);
        pixArray = (float*)mxGetPr(plhs[pix_array]);
    }

    hdf_pix_accessor::process_data(new_input_file, work_type,
        file_readers, block_split_info, pixArray, npix_to_read);


    if (nlhs > 1) {
        plhs[n_first_block_left] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
        plhs[pos_in_first_block_left] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
        auto pNblock = mxGetPr(plhs[n_first_block_left]);
        auto pPos = mxGetPr(plhs[pos_in_first_block_left]);

        *pNblock = (double)block_split_info[n_threads].n_blocks;
        *pPos = (double)block_split_info[n_threads].pos_in_first_block;

    }


}
