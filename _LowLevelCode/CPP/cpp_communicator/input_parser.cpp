#include "input_parser.h"
#include "MPI_wrapper.h"



template<typename T>
T retrieve_value(const char*err_id, const mxArray *prhs) {



    size_t m_size = mxGetM(prhs);
    size_t n_size = mxGetN(prhs);
    if (m_size != 1 || n_size != 1) {


        std::stringstream buf;
        buf << " The input for " << err_id << "should be a single value while its size is ["
            << m_size << "x" << n_size << "] Matrix\n";
        mexErrMsgIdAndTxt("MPI_MEX_COMMUNICATOR:invalid_argument", buf.str().c_str());
    }

    auto *pVector = mxGetPr(prhs);

    return static_cast<T>(pVector[0]);
}

size_t   get_byte_length(const char*err_id, const mxArray *prhs) {


    mxClassID category = mxGetClassID(prhs);
    switch (category) {
    case mxINT8_CLASS:   return 1;
    case mxUINT8_CLASS:  return 1;
    case mxINT16_CLASS:  return 2;
    case mxUINT16_CLASS: return 2;
    case mxINT32_CLASS:  return 4;
    case mxUINT32_CLASS: return 4;
    case mxINT64_CLASS:  return 8;
    case mxUINT64_CLASS: return 8;
    case mxSINGLE_CLASS: return 4;
    case mxDOUBLE_CLASS: return 8;
    default: {
        std::stringstream buf;
        buf << " The input for " << err_id << "contains unknown vector type\n";
        mexErrMsgIdAndTxt("MPI_MEX_COMMUNICATOR:invalid_argument", buf.str().c_str());
    };
    }
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
        mexErrMsgIdAndTxt("MPI_MEX_COMMUNICATOR:invalid_argument", buf.str().c_str());
    }

    vec_bytes = get_byte_length(err_id, prhs);
    return pVector;
}

void retrieve_string(const mxArray *param, std::string &result, const char *ErrorPrefix) {

    mxClassID  category = mxGetClassID(param);
    if (category != mxCHAR_CLASS) {
        std::stringstream err;
        err << "The argument should be the a string: " << ErrorPrefix << " when in fact its not a string\n ";
        mexErrMsgIdAndTxt("MPI_MEX_COMMUNICATOR:invalid_argument",
            err.str().c_str());
    }
    auto buflen = mxGetNumberOfElements(param) + 1;
    result.resize(buflen);
    auto pBuf = &(result[0]);

    /* Copy the string data from string_array_ptr and place it into buf. */
    if (mxGetString(param, pBuf, buflen) != 0) {
        std::stringstream err;
        err << " Can not convert string data while processing " << ErrorPrefix << "\n";
        mexErrMsgIdAndTxt("MPI_MEX_COMMUNICATOR:invalid_argument",
            err.str().c_str());
    }
    result.erase(buflen - 1, 1);
}


/** process input values and extract parameters, necessary for the reader to work in the form the program requests
*Inputs:
nlhs  --  number of mex file left hand side parameters
plhs  --  array of pointers to left hand side parameters
nrhs  --  number of mex file right hand side parameters
prhs  --  array of pointers to right hand side parameters
*
*Ouptuts:
work_mode         -- retrieved IO operations mode.
data_address      -- address of the node to communicate with
data_tag          -- MPI messages tag
nbytes_to_transfer-- number of bytes to transfer over mpi. 
data_buffer       -- refernece to pointert to the buffer with data. Defined for send and undef for labReceive/labProbe


returns:
pointer to cpp_communicator class handler to share with Matlab
*/

class_handle<MPI_wrapper> *parse_inputs(int nlhs, int nrhs, const mxArray *prhs[],
    input_types &work_mode,int &data_address,int &data_tag, size_t &nbytes_to_transfer, char *&data_buffer)
{


    // get correct file name and the group name
    std::string mex_mode;
    retrieve_string(prhs[(int)labIndexInputs::mode_name], mex_mode, "MPI mode description");

    if (mex_mode.compare("labReceive") == 0) {
        work_mode = labReceive;
    }
    else if (mex_mode.compare("labSend") == 0) {
        work_mode = labSend;
    }
    else if (mex_mode.compare("labIndex") == 0) {
        work_mode = labIndex;
    }
    else if (mex_mode.compare("labProbe") == 0) {
        work_mode = labProbe;
    }
    else if (mex_mode.compare("init") == 0) {
        if (nrhs != 1 ) {
            std::stringstream err;
            err << " Init mode needs only 1 but got : " << nrhs << " input parameters";
            throw_error("MPI_MEX_COMMUNICATOR:invalid_argument", err.str().c_str());
        }
        class_handle<MPI_wrapper> *pCommunicator = new class_handle<MPI_wrapper>();
        work_mode = init_mpi;
        return pCommunicator;
    }
    else if (mex_mode.compare("finalize") == 0) {
        work_mode = close_mpi;
        /* do not throw on finalize second time if the framework had been already finalized*/
        class_handle<MPI_wrapper> *pCommunicator = get_handler_fromMatlab<MPI_wrapper>(prhs[(int)labIndexInputs::comm_ptr], false);

        return pCommunicator;
    }
    else {
        std::stringstream err;
        err << " Unknow operation mode: " << mex_mode;
        throw_error("MPI_MEX_COMMUNICATOR:invalid_argument", err.str().c_str());
    }
    if (work_mode != close_mpi && nrhs < 1) {
        throw_error("MPI_MEX_COMMUNICATOR:invalid_argument", "MPI communicator needs at least one argument to return the instance of the communicatir");
    }

    // get handlder from 
    class_handle<MPI_wrapper> *pCommunicator = get_handler_fromMatlab<MPI_wrapper>(prhs[(int)labIndexInputs::comm_ptr]);
    return pCommunicator;

}

void throw_error(char const * const MESS_ID, char const * const error_message) {
    mexUnlock();
    mexErrMsgIdAndTxt(MESS_ID, error_message);
};
