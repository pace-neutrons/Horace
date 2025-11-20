#include "bin_pixels.h"
#include <random>


// Declare procedure which will initialize binning inputs from MATLAB call
void parse_inputs(mxArray* plhs[], mxArray const* prhs[], std::unique_ptr<class_handle<BinningArg>>& bin_arg_holder);

/* function parses special input values and return true if special value have been encountered Otherwise returns false */
bool find_special_inputs(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[], std::unique_ptr<class_handle<BinningArg>>& bin_par_ptr);


// A constant which identifies particular instance of instantiated mex code.
// Something not 0 as input from MATLAB may be easy initialized to 0
static ::uint32_t CODE_SIGNATURE(0x7D58CDE3);
// holder of the pointer to the instance of the binning arguments used in the previous call to the mex function.
static std::unique_ptr<class_handle<BinningArg>> bin_par_ptr;

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    // identify special input requests (e.g. version or clear mex from memory) 
    // and return if special input is found. Two special inputs, namely get code version 
    // and "clear" -- remove existing code from memory allowing mex to be freed from memory 
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

        int max_nlhs(4);
        if (bin_par_ptr->class_ptr->binMode == opModes::npix_only) {
            max_nlhs =(int)out_arg_mode0::N_OUT_Arguments0;
        } else {
            max_nlhs = (int)out_arg::N_OUT_Arguments;
        }
        if (nlhs != max_nlhs) {
            std::stringstream buf;
            buf << "Test mode requests 4 output arguments.\n";
            buf << "Provided : " << (short)nlhs << " output arguments\n";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
        bin_par_ptr->class_ptr->return_test_inputs(plhs, nlhs);
        return;
    }
    try {
        auto distr_size = bin_par_ptr->class_ptr->distr_size;
        std::span<double> npix(mxGetPr(bin_par_ptr->class_ptr->npix_ptr), distr_size);
        std::span<double> signal(mxGetPr(bin_par_ptr->class_ptr->signal_ptr),distr_size);
        std::span<double> error(mxGetPr(bin_par_ptr->class_ptr->error_ptr),distr_size);
        auto transfType = bin_par_ptr->class_ptr->InOutTypeTransf;

        size_t num_pixels_retained(0);
        switch (transfType) {
        case (InOutTransf::InCrd8OutPix8): {
            num_pixels_retained = bin_pixels<double, double>(npix, signal, error, bin_par_ptr->class_ptr);
            break;
        }
        case (InOutTransf::InCrd4OutPix8): {
            num_pixels_retained = bin_pixels<float,double>(npix, signal, error, bin_par_ptr->class_ptr);
            break;
        }
        case (InOutTransf::InCrd4OutPix4): {
            num_pixels_retained = bin_pixels<float,float>(npix, signal, error, bin_par_ptr->class_ptr);
            break;
        }
        }
        bin_par_ptr->class_ptr->n_pix_retained = num_pixels_retained;
        bin_par_ptr->class_ptr->return_results(plhs,nlhs);
    }
    catch (const char* err) {
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:runtime_error", err);
    }

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
    // special cases of calling class with mex-unlock request to enable to upload it from memory
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
        if (key.compare("clear") == 0 || key.compare("reset")) { //clear mex lock and nullify binning information
            if (bin_par_ptr) {
                bin_par_ptr->clear_mex_locks();
                bin_par_ptr.reset();
            }
            return true;
        } else if (key.compare("release") == 0) { // allow to clear mex code from memory
            if (bin_par_ptr) {
                bin_par_ptr->clear_mex_locks();
            }
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
    bool force_update(false);
    if (pBinHolder == nullptr || bin_arg_holder == nullptr) {
        // create new bin_arguments holder with random signature
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<uint32_t> dist(1, std::numeric_limits<uint32_t>::max());

        CODE_SIGNATURE = dist(gen);
        bin_arg_holder = std::make_unique<class_handle<BinningArg>>(CODE_SIGNATURE);
        force_update = true;

    }
    plhs[out_arg::mex_code_hldrOut] = bin_arg_holder->export_handler_toMatlab();

    auto bin_arg_ptr = bin_arg_holder->class_ptr;
    if (bin_arg_ptr->new_binning_arguments_present(prhs)) {
        force_update = true;
    }
    bin_arg_ptr->parse_bin_inputs(prhs[in_arg::param_struct]);
    bin_arg_ptr->check_and_init_accumulators(plhs, prhs,force_update);
    return;
};


//#undef OMP_VERSION_3
//#undef C_MUTEXES



