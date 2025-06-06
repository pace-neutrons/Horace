#include "BinningArg.h"
#include <cstdlib>
#include <limits>
#include <random>

// something not 0 as input from MATLAB may be easy initilized to 0
static ::uint32_t CODE_SIGNATURE(0x7D58CDE3);

void BinningArg::set_coord_in(mxArray const* const pField)
{
    auto nDims = mxGetNumberOfDimensions(pField);
    if (nDims != 2) { // get value for computational mode the alogrithm should run
        std::stringstream buf;
        buf << "input pixel data have to be represented by 2 - dimensional matrix\n";
        buf << "Provided input " << (short)nDims << "dimensional array";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    this->coord_ptr = pField;
    this->in_pix_width = mxGetM(pField);
    this->n_data_points = mxGetN(pField);
};
// initalize one of available binning modes
void BinningArg::set_binning_mode(mxArray const* const pField)
{
    if (!mxIsScalar(pField)) { // get value for computational mode the alogrithm should run
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "Binning mode can be defined only by scalar values");
    }
    auto mode = (opModes)(mxGetScalar(pField) - 1); // C-modes are smaller then MATLAB modes by 1
    if (mode < opModes::npix_only || mode >= opModes::N_OP_Modes) {
        std::stringstream buf;
        buf << "Operational modes should be in range from 1 to 7\n";
        buf << "Unknown binning mode: " << (short)mode << "\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    if (mode == opModes::invalid_mode) {
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "Operation mode N1 is not supported");
    }
    this->binMode = mode;
};
// how many computational threads to deploy for calculations
void BinningArg::set_num_threads(mxArray const* const pField)
{
    if (!mxIsScalar(pField)) {
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "number of computational threads can be defined only by scalar values");
    }
    auto nthreads = mxGetScalar(pField);
    if (nthreads < 1) {
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "number of computational threads can not be smaller then 1");
    }
    if (nthreads > 64) {
        mexWarnMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "Using more then 64 computational threads is not expected.\n"
            "Reverted requested number of threads to 64");
        nthreads = 64;
    }
    this->num_threads = nthreads;
};
// set the range of data to bin pixels in
void BinningArg::set_data_range(mxArray const* const pField)
{
    auto nDims = mxGetNumberOfDimensions(pField); // get size of the range matrix
    if (nDims != 2) {
        std::stringstream buf;
        buf << "input data range have to be represented by 2 - dimensional matrix\n";
        buf << "Provided input is: " << (short)nDims << "-dimensional array";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto minmax_width = mxGetM(pField);
    auto minmax_length = mxGetN(pField);
    if (minmax_width != 2 || minmax_length != 4) {
        std::stringstream buf;
        buf << "input data range have to be represented by 2x4 - matrix\n";
        buf << "Provided input has: " << (short)minmax_width << "x" << (short)minmax_length << " components";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto pData = mxGetPr(pField);
    this->data_range.assign(pData, pData + 8);
};
// number of dimensions the binning should be performed on
void BinningArg::set_dimensions(mxArray const* const pField)
{
    if (!mxIsScalar(pField)) {
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "dimensions should be defined by scalar value");
    }
    auto n_dimensions = mxGetScalar(pField);
    if (n_dimensions < 0 || n_dimensions > 4) {
        std::stringstream buf;
        buf << "Horace currently supports from 0 to 4 dimensional binning\n";
        buf << "provided: " << (short)n_dimensions << "-dimensions\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    this->n_dims = n_dimensions;
}
// set number of bins in all 4 directions. 1 in all dimensions may be
// treated both as 0 and 4 dimensons.
void BinningArg::set_bins_all_dims(mxArray const* const pField)
{
    auto valid_type = mxIsUint32(pField);
    if (!valid_type) {
        auto class_id = mxGetClassID(pField);
        std::stringstream buf;
        buf << "input binning values have to be represented by uint32-type\n";
        buf << " (mxUINT32_CLASS numbered by:" << (short)mxUINT32_CLASS << ")\n";
        buf << "Provided input class number is: " << (short)class_id;
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto nDims = mxGetNumberOfDimensions(pField); // get size of the range matrix
    if (nDims != 2) {
        std::stringstream buf;
        buf << "input binning values have to be represented by 2 - dimensional matrix\n";
        buf << "Provided input is: " << (short)nDims << "-dimensional array";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto bins_width = mxGetM(pField);
    auto bins_length = mxGetN(pField);
    if (bins_width != 1 || bins_length != 4) {
        std::stringstream buf;
        buf << "input binning array have to be represented by 1x4 - matrix\n";
        buf << "Provided input has: " << (short)bins_width << "x" << (short)bins_length << " components";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto pData = (uint32_t*)mxGetPr(pField);
    this->nbins_all_dims.assign(pData, pData + 4);
};
// holder for the information about unique run_id-s present in the data. Set procedure is non-standard
void BinningArg::set_unique_runid(mxArray const* const pField)
{
}
// boolean parameters which would request output transformed pixels always been double regardless of input pixels
void BinningArg::set_force_double(mxArray const* const pField)
{
    if (!mxIsScalar(pField)) {
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "fore_double parameters should be defined by scalar value");
    }
    auto do_testing = mxGetScalar(pField);
    this->test_inputs = bool(do_testing);
};
// intialize testing input mode (or not)
void BinningArg::set_test_input_mode(mxArray const* const pField)
{
    if (!mxIsScalar(pField)) {
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "test_input_parsing parameters should be defined by scalar value");
    }
    auto do_testing = mxGetScalar(pField);
    this->test_inputs = bool(do_testing);
};

/* define functions which would check and set BinninPar values from the input assigned
   to MATLAB structure.
*/
void BinningArg::register_input_methods()
{
    this->BinParInfo["coord_in"] = [this](mxArray const* const pField) { this->set_coord_in(pField); };
    this->BinParInfo["binning_mode"] = [this](mxArray const* const pField) { this->set_binning_mode(pField); };
    this->BinParInfo["num_threads"] = [this](mxArray const* const pField) { this->set_num_threads(pField); };
    this->BinParInfo["data_range"] = [this](mxArray const* const pField) { this->set_data_range(pField); };
    this->BinParInfo["dimensions"] = [this](mxArray const* const pField) { this->set_dimensions(pField); };
    this->BinParInfo["bins_all_dims"] = [this](mxArray const* const pField) { this->set_bins_all_dims(pField); };
    this->BinParInfo["force_double"] = [this](mxArray const* const pField) { this->set_force_double(pField); };
    this->BinParInfo["test_input_parsing"] = [this](mxArray const* const pField) { this->set_test_input_mode(pField); };
};
/**  Parse input binning arguments and set new BinningArg from MATLAB input arguments
 *    structure.
 **/
void BinningArg::parse_bin_inputs(mxArray const* pAllParStruct)
{
    auto argType = mxGetClassID(pAllParStruct);
    if (argType != mxSTRUCT_CLASS) {
        std::stringstream buf;
        buf << in_arg::param_struct << "'s parameter of input class should be a structure with binning parameters\n";
        buf << "It is something else with MATLAB mex classID: " << argType << "\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }

    /* ********************************************************************************
     * retrieve and analyse binning parameters collated into binning structure. *
     ** ********************************************************************************/
    //**************************************************************************
    // Transform inputs from MATLAB structure values to values pf BinningArg
    auto total_num_of_elements = mxGetNumberOfElements(pAllParStruct);
    if (total_num_of_elements != 1) {
        std::stringstream buf;
        buf << "Structure with binning parameters have to have 1 element. \n";
        buf << "It has: " << (short)total_num_of_elements << "elements\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto number_of_fields = mxGetNumberOfFields(pAllParStruct);
    /* For the given index, walk through each field. */
    for (int fld_idx = 0; fld_idx < number_of_fields; fld_idx++) {
        auto field_name = std::string(mxGetFieldNameByNumber(pAllParStruct, fld_idx));
        auto fld_ptr = mxGetFieldByNumber(pAllParStruct, 0, fld_idx);
        // call appropriate fiel-processing function and set up appropriate MATLAB
        // parameters into current binning class instance.
        auto it = this->BinParInfo.find(field_name);
        if (it != this->BinParInfo.end()) {
            it->second(fld_ptr); // key exists
        } else { // key not found
            std::stringstream buf;
            buf << "Mex code does not know about input field: " << field_name;
            mexWarnMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
    }
    return;
}

/** Copy input arguments into appropriate places of output arguments for debugging purposes
 **/
void BinningArg::return_inputs(mxArray* plhs[])
{
    // define functions which would convert binning parameters into MATLAB data
    this->OutParList["coord_in"] = [this](mxArray* pFieldName, mxArray* pFieldValue,
                                       int fld_idx, const std::string& field_name) {
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxDuplicateArray(pFieldValue));
    };

    this->OutParList["binning_mode"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto mode = double(this->binMode + 1); // C-modes are smaller then MATLAB modes by 1
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(mode));
    };
    //
    this->OutParList["num_threads"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto n_threads = double(this->num_threads);
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(n_threads));
    };
    this->OutParList["data_range"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto range = this->data_range;
        auto pRange = mxCreateDoubleMatrix(2, 4, mxREAL);
        double* const pData = (double*)mxGetPr(pRange);
        for (auto i = 0; i < range.size(); i++) {
            *(pData + i) = range[i];
        }
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, pRange);
    };
    this->OutParList["dimensions"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto n_dims = double(this->n_dims);
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(n_dims));
    };
    this->OutParList["bins_all_dims"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto pNBins = mxCreateNumericMatrix(1, 4, mxUINT32_CLASS, mxREAL);
        auto pData = (uint32_t*)mxGetPr(pNBins);
        for (auto i = 0; i < this->nbins_all_dims.size(); i++) {
            *(pData + i) = (uint32_t)this->nbins_all_dims[i];
        }
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, pNBins);
    };
    this->OutParList["unique_runid"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        // incomplete!!!
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(0));
    };
    this->OutParList["test_input_parsing"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto test_inputs = this->test_inputs;
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxCreateLogicalScalar(test_inputs));
    };
    /* ********************************************************************************
     * retrieve binning parameters form BinningArg class and copy them into output array
     ** ********************************************************************************/
    auto number_of_fields = this->OutParList.size();
    plhs[out_arg::out_par_names] = mxCreateCellMatrix(1, mwSize(number_of_fields));
    plhs[out_arg::out_par_values] = mxCreateCellMatrix(1, mwSize(number_of_fields));

    // Copy BinningArg values to output cellarrays
    auto pFieldNames = plhs[out_arg::out_par_names];
    auto pFieldValues = plhs[out_arg::out_par_values];
    int fld_idx(0);
    for (auto iter = this->OutParList.begin(); iter != this->OutParList.end(); iter++) {
        // call appropriate field-processing function and set up appropriate MATLAB values
        // from the values of the BinningArg fields
        iter->second(pFieldNames, pFieldValues, fld_idx, iter->first);
        fld_idx++;
    }
};

// check if input accumulators have not been changed and initalize them appropriately
void BinningArg::check_and_init_accumulators(mxArray* plhs[], mxArray const* prhs[], bool force_update)
{
    auto in_npix_ptr = mxGetPr(prhs[in_arg::npixIn]);
    if (mxGetPr(this->npix_ptr) == nullptr || mxGetPr(this->npix_ptr) != in_npix_ptr) {
        if (mxIsEmpty(prhs[in_arg::npixIn]) || force_update) {
            this->npix_ptr = mxCreateNumericArray(this->get_Matlab_n_dimensions(), this->get_Matlab_acc_dimensions(),
                mxDOUBLE_CLASS, mxREAL);
        } else {
            this->npix_ptr = mxDuplicateArray(prhs[in_arg::npixIn]);
        }
    }

    if (this->binMode == opModes::npix_only) {
        this->signal_ptr = mxDuplicateArray(prhs[in_arg::signalIn]);
        this->error_ptr = mxDuplicateArray(prhs[in_arg::errorIn]);
    } else {
        if (mxGetPr(this->signal_ptr) != const_cast<double*>(mxGetPr(prhs[in_arg::signalIn]))) {
            if (mxIsEmpty(prhs[in_arg::signalIn]) || force_update) {
                this->npix_ptr = mxCreateNumericArray(this->get_Matlab_n_dimensions(), this->get_Matlab_acc_dimensions(),
                    mxDOUBLE_CLASS, mxREAL);
            } else {
                this->npix_ptr = mxDuplicateArray(prhs[in_arg::signalIn]);
            }
        }
        if (mxGetPr(this->error_ptr) != const_cast<double*>(mxGetPr(prhs[in_arg::errorIn]))) {
            if (mxIsEmpty(prhs[in_arg::errorIn]) || force_update) {
                this->npix_ptr = mxCreateNumericArray(this->get_Matlab_n_dimensions(), this->get_Matlab_acc_dimensions(),
                    mxDOUBLE_CLASS, mxREAL);
            } else {
                this->npix_ptr = mxDuplicateArray(prhs[in_arg::errorIn]);
            }
        }
    }
    plhs[out_arg::npix] = this->npix_ptr;
    plhs[out_arg::Signal] = this->signal_ptr;
    plhs[out_arg::Error] = this->error_ptr;
}
/* get array of dimensions to allocate in the form appropriate for using with Matlab *mxCreateNumericArray
** function.
**/
mwSize* BinningArg::get_Matlab_acc_dimensions()
{

    if (this->n_dims == 0) {
        this->accumulator_dims_holder.push_back(1);
    } else {
        for (auto& element : this->nbins_all_dims) {
            if (element > 1) {
                this->accumulator_dims_holder.push_back(mwSize(element));
            }
        }
        if (this->accumulator_dims_holder.size() != this->n_dims) {
            std::stringstream buf;
            buf << "Number of dimensions defined by nbins_all_dims array are not consistent with defined by n_dims value\n";
            buf << "nbins_all_dimes gives: " << (short)this->accumulator_dims_holder.size() << " value and n_dims=" << (short)this->n_dims;
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
    }
    if (this->accumulator_dims_holder.size() == 0) {
        this->accumulator_dims_holder.push_back(1);
    }
    if (this->accumulator_dims_holder.size() == 1) {
        this->accumulator_dims_holder.push_back(1);
    }
    return this->accumulator_dims_holder.data();
}
mwSize BinningArg::get_Matlab_n_dimensions()
{
    mwSize n_dims = (mwSize)(this->n_dims);
    if (n_dims == 0 || n_dims == 1)
        n_dims = 2;
    return n_dims;
}
    // binning arguments constructor
BinningArg::BinningArg()
    : binMode(opModes::npix_only)
    , n_dims(0)
    , num_threads(8)
    , coord_ptr(nullptr)
    , in_pix_width(4)
    , n_data_points(0)
    , force_double(false)
    , test_inputs(false)
    , npix_ptr(nullptr)
    , signal_ptr(nullptr)
    , error_ptr(nullptr)
{
    /* initialize input Matlab parameters map with methods which would associate
     * Matlab field names with the methods, which set appropriate property value  */
    this->register_input_methods();
};
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
    if (pBinHolder == nullptr) {
        // create new bin_arguments holder with random signature
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<uint32_t> dist(1, std::numeric_limits<uint32_t>::max());

        CODE_SIGNATURE = dist(gen);
        bin_arg_holder = std::make_unique<class_handle<BinningArg>>(CODE_SIGNATURE);
        plhs[out_arg::mex_code_hldrOut] = bin_arg_holder->export_hanlder_toMatlab();
    }
    auto bin_arg_ptr = bin_arg_holder->class_ptr;
    bin_arg_ptr->parse_bin_inputs(prhs[in_arg::param_struct]);
    bin_arg_ptr->check_and_init_accumulators(plhs, prhs);
    return;
};
