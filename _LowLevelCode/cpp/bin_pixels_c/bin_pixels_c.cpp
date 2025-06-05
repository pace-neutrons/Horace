#include "bin_pixels.h"

//
//static std::unique_ptr<omp_storage> pStorHolder;
//
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    static std::unique_ptr<class_handle<BinningArg> > bin_par_ptr;

    // identify special input requests (e.g. version or clear mex from memory) 
    // and return if special input is found.
    if (find_special_inputs(nlhs, plhs, nrhs, prhs, bin_par_ptr)) {
        return;
    }

    if (nrhs != N_IN_Arguments) {
        std::stringstream buf;
        buf << "bin_pixels_c needs " << (short)N_IN_Arguments << " but got " << (short)nrhs << " input arguments\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    if (nlhs != int(out_arg::N_OUT_Arguments)) {
        std::stringstream buf;
        buf << "bin_pixels_c needs " << (short)N_OUT_Arguments << " but got " << (short)nlhs << " output arguments\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }

    //process input bining parameters and return pointer to the class which contains their values
    bin_par_ptr=  parse_inputs(plhs, prhs);

    if (bin_par_ptr->class_ptr->test_inputs) {
        // return input back if test_inputs == true is encountered
        bin_par_ptr->class_ptr->return_inputs(plhs);
        return;
    }


/*
    bool place_pixels_in_old_array;
    try {
        place_pixels_in_old_array = bin_pixels<double>(pS, pErr, pNpix, pPixData, PixelSorted, pUranges, iGridSizes, num_threads);
    }
    catch (const char* err) {
        mexErrMsgTxt(err);
    }
    //if(!place_pixels_in_old_array){
    //      mxDestroyArray(pPixData);
    //}
    if (place_pixels_in_old_array) {
        mexPrintf("WARNING::bin_pixels_c->not enough memory for working arrays; Pixels sorted in-place");
    }
    mxSetCell(plhs[0], 3, PixelSorted);
*/
}

#undef OMP_VERSION_3
#undef C_MUTEXES



