#include "input_parser.h"
#include <vector>
#include <hdf5.h>


int get_byte_length(const char*error_id, const mxArray *param) {

    mxClassID category = mxGetClassID(param);

    switch (category) {
    case mxINT64_CLASS:    return 8;
    case mxUINT64_CLASS:   return 8;
    case mxDOUBLE_CLASS:   return 8;
    default: {
        std::stringstream buf;
        buf << " The input data for " << error_id << "should be of 8 bytes length digital type";
        mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument", buf.str().c_str());
        return -1;
    }
    }
}

template<typename T>
T retrieve_value(const char*err_id, const mxArray *prhs) {



    size_t m_size = mxGetM(prhs);
    size_t n_size = mxGetN(prhs);
    if (m_size != 1 || n_size != 1) {


        std::stringstream buf;
        buf << " The input for " << err_id << "should be a single value while its size is ["
            << m_size << "x" << n_size << "] Matrix\n";
        mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument", buf.str().c_str());
    }

    auto *pVector = mxGetPr(prhs);

    return static_cast<T>(pVector[0]);
}

template<class T>
T* retrieve_vector(const char*err_id, const mxArray *prhs, size_t &vec_size, int &vec_bytes) {

    double *pPtr = mxGetPr(prhs);

    T *pVector = reinterpret_cast<T *>(pPtr);

    size_t m_size_a = mxGetM(prhs);
    size_t n_size_a = mxGetN(prhs);
    size_t m_size, n_size;
    if (n_size_a > m_size_a) {
        m_size = n_size_a;
        n_size = m_size_a;
    }
    else {
        m_size = m_size_a;
        n_size = n_size_a;
    }
    if (n_size == 1)
        vec_size = m_size;
    else {
        std::stringstream buf;
        buf << " The input for " << err_id << "should be a 1D vector while its size is ["
            << m_size_a << "x" << n_size_a << "] Matrix\n";
        mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument", buf.str().c_str());
    }

    vec_bytes = get_byte_length(err_id, prhs);
    return pVector;
}

void retrieve_string(const mxArray *param, std::string &result, const char *ErrorPrefix) {

    mxClassID  category = mxGetClassID(param);
    if (category != mxCHAR_CLASS) {
        std::stringstream err;
        err << "first argument should be hdf " << ErrorPrefix << "word \'close\' when in fact its not a string\n ";
        mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument",
            err.str().c_str());
    }
    auto buflen = mxGetNumberOfElements(param) + 1;
    result.resize(buflen);
    auto pBuf = &(result[0]);

    /* Copy the string data from string_array_ptr and place it into buf. */
    if (mxGetString(param, pBuf, buflen) != 0) {
        std::stringstream err;
        err << " Can not convert string data while processing " << ErrorPrefix << "\n";
        mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument",
            err.str().c_str());
    }
    result.erase(buflen - 1, 1);
}

/** The variable keeping information about the recent input file to identify status of subsequent access requests to this file*/
input_file current_input_file;

/** process input values and extract parameters, necessary for the reader to work in the form the program requests
*Inputs:
*
*Ouptuts:
new_file          -- the structure, containing filename and datafolder to process.
block_positions   -- pointer to the array of the posisions of the blocks to read
block_sizes       -- pointer to the array of the posisions of the blocks to read
n_blocks_provided -- the size of the block positions and block sizes array
n_bytes           -- the size of the pointer of block_positions and block_size array
n_blocks_2_read   -- number of blocks to read until buffer is full

num_threads       -- number of OMP threads to use in i/o operation
*/
input_types parse_inputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[],
    input_file &new_file,
    double *&block_pos, double *&block_size, size_t &n_blocks_provided, int &n_bytes,
    std::vector<pix_block_processor> &block_split_info, size_t &npix_to_read) {

    input_types input_kind;

    //* Check for proper number of arguments. */
    {
        if (nrhs != N_INPUT_Arguments && nrhs != N_INPUT_Arguments - 1 && nrhs != 2) {
            std::stringstream buf;
            buf << " mex needs 2 or " << (short)N_INPUT_Arguments << "or" << short(N_INPUT_Arguments - 1)
                << " inputs but got " << (short)nrhs
                << " input(s) and " << (short)nlhs << " output(s)\n";
            mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument",
                buf.str().c_str());
        }
        if (nlhs != N_OUTPUT_Arguments && nrhs > 2) {
            std::stringstream buf;
            buf << " mex needs " << (short)N_OUTPUT_Arguments << " outputs but requested to return" << (short)nlhs << " arguments\n";
            mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument",
                buf.str().c_str());
        }

        for (int i = 0; i < nrhs - 1; i++) {
            if (prhs[i] == NULL) {
                std::stringstream buf;
                buf << "argument N" << i << " is not defined\n";
                mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument",
                    buf.str().c_str());
            }
        }
    }
    // get correct file name and the group name
    retrieve_string(prhs[filename], new_file.filename, "filename");
    retrieve_string(prhs[pixel_group_name], new_file.groupname, "pixel_group_name");

    if (new_file.do_destructor()) {
        block_pos = nullptr;
        block_size = nullptr;
        npix_to_read = 0;
        n_blocks_provided = 0;
        n_bytes = 0;
        //n_blocks_2_read = 0;
        block_split_info.resize(1);
        return close_file;
    }
    else if (nrhs == 2) {
        mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument",
            "If only two input arguments are provided, these arguments can be only 'close','close' used to finalize access to a file");


    }
    size_t n_threads;

    if (new_file.equal(current_input_file))
        input_kind = read_initiated_data;
    else {
        input_kind = open_and_read_data;
        current_input_file = new_file;
    }

    if (nrhs != N_INPUT_Arguments) {
        if (nrhs == N_INPUT_Arguments - 1) {
            n_threads = 1;
        }
        else {
            std::stringstream err;
            err << " if mex used to access the data it needs " << (short)N_INPUT_Arguments
                << " input arguments but got " << (short)nrhs
                << " input arguments\n";
            mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument",
                err.str().c_str());
        }
    }
    else {
        n_threads = retrieve_value<size_t>("number_of_threads", prhs[num_threads]);
    }
    size_t n_blocks;
    block_pos = retrieve_vector<double>("block_positions", prhs[block_positions], n_blocks, n_bytes);
    block_size = retrieve_vector<double>("block_sizes", prhs[block_sizes], n_blocks_provided, n_bytes);
    if (n_blocks != n_blocks_provided) {
        mexErrMsgIdAndTxt("HDF_MEX_ACCESS:invalid_argument",
            " sizes of pix positions array and block sizes array should be equal but they are not");
    }
    size_t num_first_block = retrieve_value<size_t>("num_first_block_left", prhs[n_first_block]);
    size_t pos_in_the_first_block = retrieve_value<size_t>("pos_in_first_block", prhs[pos_in_first_block]);

    size_t buf_size = retrieve_value<size_t>("pixel_buffer_size", prhs[pix_buf_size]);


    if (n_blocks_provided == 0 || buf_size == 0 || num_first_block>= n_blocks) { // nothing to do. 
        input_kind = close_file;
        return input_kind;

    }
    // calculate number of pixels defined to read and compare it with the size of the buffer dedicated to read data
    npix_to_read = static_cast<uint64_t>(block_size[num_first_block])- pos_in_the_first_block;
    if (npix_to_read > buf_size) {
        npix_to_read = buf_size;
    }
    else {
        for (size_t i = num_first_block + 1; i < n_blocks; ++i) {
            if (n_bytes == 8)
                npix_to_read += static_cast<uint64_t>(block_size[i]);
            else
                npix_to_read += static_cast<uint32_t>(block_size[i]);
            if (npix_to_read >= buf_size) {
                npix_to_read = buf_size;
                break;
            }
        }

        if (npix_to_read < buf_size)
            buf_size = npix_to_read;
        else if (npix_to_read > buf_size)
            npix_to_read = buf_size;
    }

    block_split_info = pix_block_processor::split_pix_block(block_pos, block_size, n_blocks, num_first_block, pos_in_the_first_block,buf_size, n_threads);
    return input_kind;
}