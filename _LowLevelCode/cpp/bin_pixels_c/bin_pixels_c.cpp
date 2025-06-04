#include "bin_pixels.h"
#include "../utility/version.h"


//
//static std::unique_ptr<omp_storage> pStorHolder;
//
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    mwSize  iGridSizes[4],     // array of grid sizes
        nGridDimensions,    // number of dimensions in the whole grid (usually 4 according to the pixel data but can be modified in a future
        i;
    //
    if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
#ifdef _OPENMP
        plhs[0] = mxCreateString(Horace::VERSION);
#else
        plhs[0] = mxCreateString(Horace::VER_NOOMP);
#endif
        return;
    }

    if (nrhs != N_IN_Arguments) {
        std::stringstream buf;
        buf << "bin_pixels_c needs" << (short)N_IN_Arguments << "  but got " << (short)nrhs << " input arguments\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    if (nlhs != int(out_arg::N_OUT_Arguments)) {
        std::stringstream buf;
        buf << "bin_pixels_c needs" << (short)N_OUT_Arguments << "  but got " << (short)nlhs << " input arguments\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }

    double* pS, * pErr, * pNpix;   // arrays for the signal, error and number of pixels in a cell (density);
    mxArray* PixelSorted;
    //process input bining parameters and return pointer to the class which contains them
    auto bin_par_ptr=  parse_inputs(plhs, prhs);

    if (bin_par_ptr->class_ptr->test_inputs) {
        if (nlhs != int(out_arg::N_OUT_Arguments)) {
            std::stringstream buf;
            buf << "bin_pixels_c in test mode needs" << (short)N_OUT_Arguments << "  but got " << (short)nlhs << " input arguments\n";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
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

#undef CLASS_HANDLE_SIGNATURE
#undef OMP_VERSION_3
#undef C_MUTEXES
#undef SINGLE_PATH


