#pragma once
#include <memory> // to wrap all this in unique pointer
//

/*The class holding a selected C++ class and providing the exchange mechanism between this class and Matlab
* to maintain consistency 
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
        _signature = 0;
        delete class_ptr;
    }
    bool isValid(uint32_t CLASS_SIGNATURE) { return ((_signature == CLASS_SIGNATURE) && std::strcmp(_name.c_str(), typeid(T).name()) == 0); }



    T* const class_ptr;
    int num_locks;
    //-----------------------------------------------------------
    mxArray* export_hanlder_toMatlab();
    void clear_mex_locks();
private:
    uint32_t _signature;
    const std::string _name;

};

template<class T>
mxArray* class_handle<T>::export_hanlder_toMatlab()
{
    if (this->num_locks == 0) {
        this->num_locks++;
        mexLock();
    }
    mxArray* out = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    uint64_t* pData = (uint64_t*)mxGetData(out);
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
};

template<class T> inline class_handle<T> *get_handler_fromMatlab(const mxArray* in,uint32_t CLASS_SIGNATURE, bool throw_on_invalid = true)
{
    if (!in)
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error", "cpp_communicator received from Matlab evaluated to null pointer");

    if (mxGetNumberOfElements(in) != 1 || mxGetClassID(in) != mxUINT64_CLASS || mxIsComplex(in))
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error", "Handle input must be a real uint64 scalar.");

    class_handle<T>* ptr = reinterpret_cast<class_handle<T> *>(*((uint64_t*)mxGetData(in)));
    if (!ptr->isValid(CLASS_SIGNATURE))
        if (throw_on_invalid)
            throw_error("MPI_MEX_COMMUNICATOR:runtime_error", "Retrieved handle does not point to correct class");
        else
            ptr = nullptr;
    return ptr;
};
