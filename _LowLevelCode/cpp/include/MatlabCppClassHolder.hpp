#pragma once
#include <memory> // to wrap all this in unique pointer
#include <cstring>
//
/* throws Matlab error.  There are two tested modes: one calling the framework from Matlab in single process without
 deploying MPI, and the second one -- unit tests for the framework.
 If the routine is g-tested, matlab mexUnlock should not be deployed*/
void inline throw_error(char const* const MESS_ID, char const* const error_message, bool is_g_tested = false) {
    if (!is_g_tested) mexUnlock();
    mexErrMsgIdAndTxt(MESS_ID, error_message);
};


/*The class holding a selected C++ class and providing the exchange mechanism between this class and Matlab
* to maintain consistency of the C++ code state between multiple call to this mex code from MATLAB.
* */
template<class T> class class_handle
{
public:
    class_handle(T* ptr,uint32_t CLASS_SIGNATURE) : _signature(CLASS_SIGNATURE), _name(typeid(T).name()), class_ptr(ptr),
        num_locks(0) {
    }
    class_handle(uint32_t CLASS_SIGNATURE) : _signature(CLASS_SIGNATURE), _name(typeid(T).name()), class_ptr(new T()),
        num_locks(0) {
    }

    ~class_handle() {
        clear_mex_locks();
        _signature = 0;
        delete class_ptr;
    }
    bool isValid(uint32_t CLASS_SIGNATURE) { return ((_signature == CLASS_SIGNATURE) && std::strcmp(_name.c_str(), typeid(T).name()) == 0); }



    T* const class_ptr;
    int num_locks;
    //-----------------------------------------------------------
    mxArray* export_handler_toMatlab();
    void clear_mex_locks();
private:
    uint32_t _signature;
    const std::string _name;

};

template<class T>
mxArray* class_handle<T>::export_handler_toMatlab()
{
    if (this->num_locks == 0) {
        this->num_locks++;
        mexLock();
    }
    // create MATLAB variable and store pointer to the instance
    // of the target class in this variable 
    // to ensure that class remains valid and loaded in memory
    // during multiple transitions between C++ and MATLAB codes.
    //==================================================================================
    //Step-by-step parsing and meaning of the code for C++ learners produced by ChatGPT:
    mxArray* out = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    /* Function: mxCreateNumericMatrix is a MATLAB API call that allocates a new MATLAB numeric matrix.
        Arguments:
        1, 1  creates a 1×1 matrix.
        mxUINT64_CLASS  the matrix stores 64-bit unsigned integers (uint64_t).
        mxREAL   not complex (no imaginary part).

    Result:
    out now points to a MATLAB array (an mxArray) that can hold one uint64_t value.
    So after this line, you have an mxArray ready to contain one 64-bit integer.*/
    uint64_t* pData = (uint64_t*)mxGetData(out);
    /*mxGetData(out) returns a pointer to the raw data buffer inside the MATLAB array.
      The data type of that pointer is void*, so we cast it to uint64_t* (because we know this array stores 64-bit unsigned integers).
      Now pData points to the memory where the single numeric value resides.
    */
    *pData = reinterpret_cast<uint64_t>(this);
    /*"this" is a pointer to the current C++ object (because this code is inside a class method).
       reinterpret_cast<uint64_t>(this) converts that object pointer into a 64-bit integer value.
        The dereference *pData = ... writes that integer into the MATLAB array's memory.

    Essentially, you store the pointer value of the current C++ object as an integer inside a MATLAB variable.
    MATLAB doesn't understand C++ objects directly, but you can pass the numeric representation of the pointer back 
    to MATLAB and later recover it (with another MEX call that converts the integer back into a pointer).
    */
    return out;
}


template<class T>
void class_handle<T>::clear_mex_locks()
{
    while (this->num_locks > 0) {
        this->num_locks--;
        mexUnlock();
    }
};

template<class T> inline class_handle<T> *get_handler_fromMatlab(const mxArray* in,uint32_t CLASS_SIGNATURE, bool throw_on_invalid = true)
{
    class_handle<T>* ptr;
    if (!in)
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error", "cpp_communicator received from Matlab evaluated to null pointer");

    if (mxGetNumberOfElements(in) != 1 || mxGetClassID(in) != mxUINT64_CLASS || mxIsComplex(in)){
        if (throw_on_invalid)
            throw_error("MPI_MEX_COMMUNICATOR:runtime_error", "Handle input must be a real uint64 scalar.");
        else {
            ptr = nullptr;
            return ptr;
        }
    }
    ptr = reinterpret_cast<class_handle<T>*>(*((uint64_t*)mxGetData(in)));
    if (!ptr->isValid(CLASS_SIGNATURE))
        if (throw_on_invalid)
            throw_error("MPI_MEX_COMMUNICATOR:runtime_error", "Retrieved handle does not point to correct class");
        else
            ptr = nullptr;
    return ptr;
};
