#pragma once

#include <mex.h>
#include <cstring>
#include <sstream>
#include <typeinfo>


enum input_types {
    init_mpi,
    init_test_mode,
    close_mpi,
    labSend,
    labReceive,
    labProbe,
    labIndex,
    labBarrier
};

// Enum various versions of input/output parameters, different for different kinds of input options
// --------------   Inputs:
enum class initIndexInputs : int {
    mode_name,
    assynch_queue_len,
    N_INPUT_Arguments
};

enum class labIndexInputs : int {
    mode_name,
    comm_ptr,
    N_INPUT_Arguments
};

enum class ProbeInputs : int { // all input arguments for read procedure
    mode_name,
    comm_ptr,
    source_id,
    tag,
    N_INPUT_Arguments
};

enum class SendReceiveInputs : int { // all input arguments for read procedure
    mode_name,
    comm_ptr,
    source_dest_id,
    tag,
    n_bytes,
    pDataBuf,

    N_INPUT_Arguments
};

enum class closeOrGetInfoInputs : int { // all input arguments for close IO procedure
    mode_name,
    comm_ptr,

    N_INPUT_Arguments
};

//--------------   Outputs;


enum class read_Out :int { // output arguments for read procedure
    comm_ptr,   // the pointer to class responsible for MPI communications
    pix_array,
    is_io_completed,
    mex_reader_handle,

    N_OUTPUT_Arguments
};

enum class labIndex_Out :int { // output arguments for labIndex procedure
    comm_ptr,   // the pointer to class responsible for MPI communications
    numLab,     // number current worker
    n_workers,  // number of workers in the pull/

    N_OUTPUT_Arguments
};

void throw_error(char const * const MESS_ID, char const * const error_message);

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
    while(this->num_locks>0){
        this->num_locks--;
        mexUnlock();
    }
}

template<class T> inline class_handle<T> *get_handler_fromMatlab(const mxArray *in,bool throw_on_invalid = true)
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





class_handle<MPI_wrapper>* parse_inputs(int nlhs, int nrhs, const mxArray *prhs[],
    input_types &work_mode, int &data_address, int &data_tag, size_t &nbytes_to_transfer, 
    char *&data_buffer, int& assynch_queue_length);
