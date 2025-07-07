#include "input_parser.h"
#include "MPI_wrapper.h"



template<typename T>
T retrieve_value(const char* err_id, const mxArray* prhs) {



    size_t m_size = mxGetM(prhs);
    size_t n_size = mxGetN(prhs);
    if (m_size != 1 || n_size != 1) {


        std::stringstream buf;
        buf << " The input for " << err_id << "should be a single value while its size is ["
            << m_size << "x" << n_size << "] Matrix\n";
        mexErrMsgIdAndTxt("MPI_MEX_COMMUNICATOR:invalid_argument", buf.str().c_str());
    }

    auto* pVector = reinterpret_cast<T*> (mxGetData(prhs));

    return static_cast<T>(pVector[0]);
}

size_t   get_byte_length(const char* err_id, const mxArray* prhs) {


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
        return 0;
    };
    }
}

template<class T>
T* retrieve_vector(const char* err_id, const mxArray* prhs, size_t& vec_size, size_t& vec_bytes) {


    T* pVector = reinterpret_cast<T*>(mxGetData(prhs));

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

void retrieve_string(const mxArray* param, std::string& result, const char* ErrorPrefix) {

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

/** Helper method to process initialization mode
Inputs:
ModeName -- pointer to string, indicating mode name if error occurs
is_test_mode -- boolean string, indicating that the init is done in test mode
prhs     -- array of input array of pointers to the right hand parameters, recevied from Matlab
nrgs     -- size of  input array of pointers
Outputs:
AddPar   -- the reference to structure, containing additional information about inputs
Returns:
pointer to handle, containing MPI communicator.
*/
void process_init_mode(const char* ModeName, bool is_test_mode, const mxArray* prhs[], int nrhs,
    class_handle<MPI_wrapper> *& mpi_holder_ptr,InitParamHolder& init_par)
{
    if (nrhs > 5 || nrhs < 1) {
        std::stringstream err;
        err << ModeName << "  mode takes from 1 to 5 inputs but got : "
            << nrhs << " input parameters";
        throw_error("MPI_MEX_COMMUNICATOR:invalid_argument", err.str().c_str());
    }
    if (mpi_holder_ptr == nullptr) {
        mpi_holder_ptr = new  class_handle<MPI_wrapper>(CLASS_HANDLE_SIGNATURE);
    } else {
    }
    init_par.is_tested = is_test_mode;

    if (nrhs >= 2) {
        init_par.async_queue_length = (int)retrieve_value<double>(ModeName, prhs[(int)InitInputs::async_queue_len]);
    }
    if (nrhs >= 3) {
        init_par.data_message_tag = (int)retrieve_value<double>(ModeName, prhs[(int)InitInputs::data_mess_tag]);
    }
    if (nrhs >= 4) {
        init_par.interrupt_tag = (int)retrieve_value<double>(ModeName, prhs[(int)InitInputs::interrupt_tag]);
    }
    if (is_test_mode && nrhs == 5) {
        size_t data_size(0), vec_size_vytes;
        int32_t *labInfo = retrieve_vector<int32_t>(ModeName, prhs[(int)InitInputs::lab_info], data_size, vec_size_vytes);
        init_par.debug_frmwk_param[0] = labInfo[0] - 1; // Matlab labIndex is 1 higher then C++
        init_par.debug_frmwk_param[1] = labInfo[1];  // numLabs
    }

    return;
}

/** process input values and extract parameters, necessary for the reader to work in the form the program requests
*Inputs:
nlhs  --  number of mex file left hand side parameters
plhs  --  array of pointers to left hand side parameters
nrhs  --  number of mex file right hand side parameters
prhs  --  array of pointers to right hand side parameters
*
*Ouptuts:
&mpi_holder_ptr   -- reference to unique pointer holding cpp_communicator class handler to share with Matlab*
work_mode         -- retrieved IO operations mode.
data_address      -- address of the node to communicate with
data_tag          -- MPI messages tag
is_synchronous    -- for send/receive operations, if the communication mode is synchroneous
data_buffer       -- refernece to pointert to the buffer with data. Defined for send and undef for labReceive/labProbe
nbytes_to_transfer-- number of bytes to transfer over mpi.

AddParr    -- The structure, containing additional parameters, different operation calls may need to process and
              transfer to the calling routine.

returns:
work_mode         -- retrieved IO operations mode.


*/
input_types parse_inputs(int nlhs, int nrhs, const mxArray* prhs[],
    class_handle<MPI_wrapper> *& mpi_holder_ptr, std::vector<int>& data_addresses, std::vector<int>& data_tag, bool& is_synchronous,
    uint8_t*& data_buffer, size_t& nbytes_to_transfer,
    InitParamHolder& AddPar)
{

    // get correct file name and the group name
    std::string mex_mode;
    input_types work_mode(input_types::undefined_state);
    retrieve_string(prhs[0], mex_mode, "MPI mode description");

    // this will throw if retrieve from MATLAB is unsuccessful
    mpi_holder_ptr = get_handler_fromMatlab<MPI_wrapper>(prhs[(int)CloseOrInfoInputs::comm_ptr], true);

    if (mex_mode.compare("labReceive") == 0) {
        if (nrhs < (int)ReceiveInputs::N_INPUT_Arguments) {
            std::stringstream err;
            err << " labReceive needs " << (int)ReceiveInputs::N_INPUT_Arguments <<
                " inputs but got " << nrhs << " input parameters\n";
            throw_error("MPI_MEX_COMMUNICATOR:invalid_argument", err.str().c_str());
        }
        data_addresses.resize(1);
        data_tag.resize(1);

        // the source address
        data_addresses[0] = (int32_t)retrieve_value<mxInt32>("labReceive: source address", prhs[(int)ReceiveInputs::source_id]) - 1;
        // the source data tag
        data_tag[0] = (int32_t)retrieve_value<mxInt32>("labReceive: source tag", prhs[(int)ReceiveInputs::tag]);
        // if the transfer is synchroneous or not
        is_synchronous = (bool)retrieve_value<mxUint8>("labReceive: is synchronous", prhs[(int)ReceiveInputs::is_synchronous]);

        work_mode = input_types::labReceive;
    }
    else if (mex_mode.compare("labSend") == 0) {
        if (nrhs < (int)SendInputs::N_INPUT_Arguments - 1) {
            std::stringstream err;
            err << " labSend needs " << (int)SendInputs::N_INPUT_Arguments - 1 << " or " << (int)SendInputs::N_INPUT_Arguments <<
                " inputs but got " << nrhs << " input parameters\n";
            throw_error("MPI_MEX_COMMUNICATOR:invalid_argument", err.str().c_str());
        }
        data_addresses.resize(1);
        data_tag.resize(1);

        // the target destination address
        data_addresses[0] = (int32_t)retrieve_value<mxInt32>("labSend: destination address", prhs[(int)SendInputs::dest_id]) - 1;
        // the sending data tag
        data_tag[0] = (int32_t)retrieve_value<mxInt32>("labSend: destination tag", prhs[(int)SendInputs::tag]);
        // if the transfer is synchroneous or not
        is_synchronous = (bool)retrieve_value<mxUint8>("labSend: is synchronous", prhs[(int)SendInputs::is_synchronous]);
        // retrieve pointer to serialized data to transfer
        size_t vector_size, bytesize;

        data_buffer = retrieve_vector<uint8_t >("labSend: data", prhs[(int)SendInputs::head_data_buffer], vector_size, bytesize);
        nbytes_to_transfer = size_t(vector_size) * bytesize;

        work_mode = input_types::labSend;
    }
    else if (mex_mode.compare("labIndex") == 0) {
        work_mode = input_types::labIndex;
    }
    else if (mex_mode.compare("labProbe") == 0) {
        size_t n_addresses, n_tags, block_size;
        // the queried  address
        auto pData_addresses = retrieve_vector<mxInt32>("labProbe: source address", prhs[(int)ProbeInputs::source_id], n_addresses, block_size);
        data_addresses.resize(n_addresses);
        for (size_t i = 0; i < n_addresses; i++) {
            data_addresses[i] = pData_addresses[i] - 1; // Matlab lab_index = MPI_index + 1
        }
        // the queried tag
        auto pData_tag = retrieve_vector<mxInt32>("labProbe: requested tag", prhs[(int)ProbeInputs::tag], n_tags, block_size);
        data_tag.resize(n_tags);
        for (size_t i = 0; i < n_tags; i++) {
            data_tag[i] = pData_tag[i];
        }
        work_mode = input_types::labProbe;
    }
    else if (mex_mode.compare("barrier") == 0) {
        work_mode = input_types::labBarrier;
    }
    else if (mex_mode.compare("init") == 0) {
        process_init_mode("Init", false, prhs, nrhs,mpi_holder_ptr ,AddPar);
        return input_types::init_mpi;
    }
    else if (mex_mode.compare("init_test_mode") == 0) {
        process_init_mode("Init_test_mode", true, prhs, nrhs, mpi_holder_ptr, AddPar);
        return input_types::init_test_mode;
    }
    else if (mex_mode.compare("finalize") == 0) {
        return input_types::close_mpi;
    }
    else if (mex_mode.compare("clearAll") == 0) {
        work_mode = input_types::clearAll;
    } else {
        std::stringstream err;
        err << " Unknow operation mode: " << mex_mode;
        throw_error("MPI_MEX_COMMUNICATOR:invalid_argument", err.str().c_str());
    }
    if (work_mode != input_types::close_mpi && nrhs < 1) {
        throw_error("MPI_MEX_COMMUNICATOR:invalid_argument",
            "MPI communicator needs at least one argument to return the instance of the communicatir");
    }

    return work_mode;

}
