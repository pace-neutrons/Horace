#pragma once

#include <mex.h>
#include <cstdint>
#include <cstring>
#include <sstream>
#include <typeinfo>
#include <vector>

enum input_types {
    init_mpi,
    init_test_mode,
    close_mpi,
    labSend,
    labReceive,
    labProbe,
    labIndex,
    labBarrier,
    clearAll  // run labReceive until all existing messages received and discarded
};

// Enum various versions of input/output parameters, different for different kinds of input options
// --------------   Inputs:
enum class InitInputs : int {
    mode_name,
    async_queue_len,
    data_mess_tag,
    interrupt_tag,
    lab_info,  // in test mode this parameter contains vector defining labIndex and numLabs for "pseudo-cluster" to test
    // ignored in production mode
    N_INPUT_Arguments
};


enum class ProbeInputs : int { // all input arguments for labProbe procedure
    mode_name,
    comm_ptr,
    source_id,
    tag,
    N_INPUT_Arguments
};

enum class SendInputs : int { // all input arguments for send procedure
    mode_name,
    comm_ptr,
    dest_id,
    tag,
    is_synchronous,
    head_data_buffer,
    large_data_buffer, // optional (for synchronous messages)
    N_INPUT_Arguments
};
enum class ReceiveInputs : int { // all input arguments for receive procedure
    mode_name,
    comm_ptr,
    source_id,
    tag,
    is_synchronous,
    N_INPUT_Arguments
};


enum class CloseOrInfoInputs : int { // all input arguments for close IO procedure
    mode_name,
    comm_ptr,

    N_INPUT_Arguments
};

//--------------   Outputs:
enum class labReceive_Out :int { // output arguments for labReceive procedure
    comm_ptr,   // the pointer to class responsible for MPI communications
    mess_contents, //the pointer to the array of serialized message contents
    data_celarray, // the pointer to the cellarray with the large data.
    real_source_address, // optional pointer to the array with real source address and source tag received

    MAX_N_Outputs
};

enum class labIndex_Out :int { // output arguments for labIndex or MPI_init procedures
    comm_ptr,   // the pointer to class responsible for MPI communications
    numLab,     // number current worker
    n_workers,  // number of workers in the pull/
    pool_names, // the names of the pool nodes

    MAX_N_Outputs
};

enum class labProbe_Out :int { // output arguments of labProbe procedure
    comm_ptr,   // the pointer to class responsible for MPI communications
    addr_tag_array,     // 2-element array with the results of lab-probe operation

    MAX_N_Outputs

};
/** The structure contains additional parameters, different init calls may need to transfer to MPI_Wrapper*/
struct InitParamHolder {
    bool is_tested;
    int async_queue_length; // how many asynchronous messages could be placed into asynchronous queue
    int data_message_tag;    // the tag of a data message, to process synchronously.
    int interrupt_tag;    // the tag of an interrupt message, to process intermittently with any other type of messages.
    int32_t debug_frmwk_param[2] = { 0,1 }; // in debug mode, this array contains fake labIndex and numLabs,
                              // used for testing framework in serial mode.
    InitParamHolder() :
        is_tested(false), async_queue_length(10), data_message_tag(8), interrupt_tag(100)
    {}
};

void throw_error(char const * const MESS_ID, char const * const error_message, bool is_tested = false);

class MPI_wrapper;
//
/*The class holding a selected C++ class and providing the exchange mechanism between this class and Matlab*/
#define CLASS_HANDLE_SIGNATURE 0x7D58CDE2
template<class T> class class_handle
{
public:
    class_handle(T *ptr) : _signature(CLASS_HANDLE_SIGNATURE), _name(typeid(T).name()), class_ptr(ptr),
        num_locks(0) {}
    class_handle() : _signature(CLASS_HANDLE_SIGNATURE), _name(typeid(T).name()), class_ptr(new T()),
        num_locks(0) {}

    ~class_handle() {
        _signature = 0;
        delete class_ptr;
    }
    bool isValid() { return ((_signature == CLASS_HANDLE_SIGNATURE) && std::strcmp(_name.c_str(), typeid(T).name()) == 0); }



    T* const class_ptr;
    int num_locks;
    //-----------------------------------------------------------
    mxArray * export_hanlder_toMatlab();
    void clear_mex_locks();
private:
    uint32_t _signature;
    const std::string _name;

};

template<class T>
mxArray * class_handle<T>::export_hanlder_toMatlab()
{
    if (this->num_locks == 0) {
        this->num_locks++;
        mexLock();
    }
    mxArray *out = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    uint64_t *pData = (uint64_t *)mxGetData(out);
    *pData = reinterpret_cast<uint64_t>(this);
    return out;
}


template<class T>
void class_handle<T>::clear_mex_locks()
{
    while (this->num_locks > 0) {
        this->num_locks--;
        mexUnlock();
    }
}

template<class T> inline class_handle<T> *get_handler_fromMatlab(const mxArray *in, bool throw_on_invalid = true)
{
    if (!in)
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error", "cpp_communicator received from Matlab evaluated to null pointer");

    if (mxGetNumberOfElements(in) != 1 || mxGetClassID(in) != mxUINT64_CLASS || mxIsComplex(in))
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error", "Handle input must be a real uint64 scalar.");

    class_handle<T> *ptr = reinterpret_cast<class_handle<T> *>(*((uint64_t *)mxGetData(in)));
    if (!ptr->isValid())
        if (throw_on_invalid)
            throw_error("MPI_MEX_COMMUNICATOR:runtime_error", "Retrieved handle does not point to correct class");
        else
            ptr = nullptr;
    return ptr;
}




class_handle<MPI_wrapper>* parse_inputs(int nlhs, int nrhs, const mxArray* prhs[],
    input_types& work_mode, std::vector<int32_t> &data_addresses, std::vector<int32_t> &data_tag, bool& is_synchroneous,
    uint8_t*& data_buffer, size_t &nbytes_to_transfer,
    InitParamHolder & addPar);
