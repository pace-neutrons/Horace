#include "bin_pixels.h"
#include <random>


// Declare procedure which will initialize binning inputs from MATLAB call
void parse_inputs(mxArray* plhs[], mxArray const* prhs[], std::unique_ptr<class_handle<BinningArg>>& bin_arg_holder);

/* function parses special input values and return true if special value have been encountered Otherwise returns false */
bool find_special_inputs(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[], std::unique_ptr<class_handle<BinningArg>>& bin_par_ptr);


// A constant which identifies particular instance of instantiated mex code.
// Something not 0 as input from MATLAB may be easy initilized to 0
static ::uint32_t CODE_SIGNATURE(0x7D58CDE3);
// holder of the pointer to the instance of the binning arguments used in the previous call to the mex function.
static std::unique_ptr<class_handle<BinningArg>> bin_par_ptr;

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    // identify special input requests (e.g. version or clear mex from memory) 
    // and return if special input is found. Two special inputs, namely get code version 
    // and "clear" -- remove existing code from memory alloweing mex to be freed from memory 
    // are recognized here.
    if (find_special_inputs(nlhs, plhs, nrhs, prhs, bin_par_ptr)) {
        return;
    }

    if (nrhs != N_IN_Arguments) {
        std::stringstream buf;
        buf << "bin_pixels_c needs " << (short)N_IN_Arguments << " but got " << (short)nrhs << " input arguments\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    if (nlhs > int(out_arg::N_OUT_Arguments)) {
        std::stringstream buf;
        buf << "bin_pixels_c allows no more than " << (short)N_OUT_Arguments << " but got " << (short)nlhs << " output arguments\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }

    //process input bining parameters and return pointer to the class which contains their values
    //if this is the call to the same binning parameters
    parse_inputs(plhs, prhs, bin_par_ptr);

    if (bin_par_ptr->class_ptr->test_inputs) {
        // return input back if test_inputs == true is encountered
        if (nlhs != 4) {
            std::stringstream buf;
            buf << "Test mode requests 4 output arguments.\n";
            buf << "Provided : " << (short)nlhs << " output arguments\n";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
        bin_par_ptr->class_ptr->return_inputs(plhs,nlhs);
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
/* function parses special input values and return true if special value have been encountered
 * special values processed by this function may be version request or request to reset memory holder
 * and set permission to unload memory holder mex file from memory
 */
bool find_special_inputs(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[], std::unique_ptr<class_handle<BinningArg>>& bin_par_ptr)
{
    if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
#ifdef _OPENMP
        plhs[0] = mxCreateString(Horace::VERSION);
#else
        plhs[0] = mxCreateString(Horace::VER_NOOMP);
#endif
        return true;
    }
    // special case of calling class with mex-unlock request to enable to upload it from memory
    if (nrhs == 1 && nlhs == 0) {
        auto inType = mxGetClassID(prhs[0]);
        if (inType != mxCHAR_CLASS) {
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                "if bin_pixels_c is called with one argument, this argument have to be string 'clear' or 'reset'\n"
                "(single dash ') Obtained non-character array as input");
        }
        auto buflen = mxGetNumberOfElements(prhs[0]) + 1;
        std::vector<char> buf(buflen);
        if (mxGetString(prhs[0], buf.data(), buflen) != 0) {
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                "Could not convert string data first input argument of bin_pixels_c into string array");
        }
        auto key = std::string(buf.begin(), buf.end());
        if (key.compare("clear") == 0 || key.compare("reset")) {
            if (bin_par_ptr) {
                bin_par_ptr->clear_mex_locks();
                bin_par_ptr.reset();
            }
            return true;
        } else {
            std::stringstream buf;
            buf << "signle char input for bin_pixels_c function may be 'clear' or 'reset' (in single dashes ') Got: " << key;
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
    }
    return false;
};

/** Parse input arguments of the binning routine and retrieve all necessary parameters
 *   for start or continue binning calculations
 * */
void parse_inputs(mxArray* plhs[], mxArray const* prhs[], std::unique_ptr<class_handle<BinningArg>>& bin_arg_holder)
{
    // retrieve auto-ptr to old binning calculations
    auto pBinHolder = get_handler_fromMatlab<BinningArg>(prhs[in_arg::mex_code_hldrIn], CODE_SIGNATURE, false);
    if (pBinHolder == nullptr || bin_arg_holder == nullptr) {
        // create new bin_arguments holder with random signature
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<uint32_t> dist(1, std::numeric_limits<uint32_t>::max());

        CODE_SIGNATURE = dist(gen);
        bin_arg_holder = std::make_unique<class_handle<BinningArg>>(CODE_SIGNATURE);

    }
    plhs[out_arg::mex_code_hldrOut] = bin_arg_holder->export_hanlder_toMatlab();

    auto bin_arg_ptr = bin_arg_holder->class_ptr;
    if (bin_arg_ptr->new_binning_arguments_present(prhs)) {
        bin_arg_ptr->parse_bin_inputs(prhs[in_arg::param_struct]);
    } else {
        bin_arg_ptr->parse_changed_bin_inputs(prhs[in_arg::param_struct]);
    }
    bin_arg_ptr->check_and_init_accumulators(plhs, prhs);
    return;
};


#undef OMP_VERSION_3
#undef C_MUTEXES



