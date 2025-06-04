#include "BinningArg.h"
#include <cstdlib>
#include <limits>
#include <random>

// something not 0 as input from MATLAB may be easy initilized to 0
static::uint32_t CODE_SIGNATURE(0x7D58CDE3);

/** Parse input arguments of the binning routine and retrieve all necessary parameters 
*   for start or continue binning calculations
* */
std::unique_ptr<class_handle<BinningArg> > parse_inputs(mxArray* plhs[], mxArray const* prhs[]) {
    // if binning routine is invoked with empty npix array, it is new binning calculations
    auto new_call = mxIsEmpty(prhs[in_arg::npixIn]);
    // retrieve auto-ptr to old binning calculations
    auto bin_arg_holder = std::unique_ptr<class_handle<BinningArg> >(get_handler_fromMatlab<BinningArg>(prhs[in_arg::mex_code_hldrIn], CODE_SIGNATURE, false));

    if (bin_arg_holder == nullptr) {
        // create new bin_arguments holder with random signature
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<uint32_t> dist(1, std::numeric_limits<uint32_t>::max());

        CODE_SIGNATURE = dist(gen);
        bin_arg_holder = std::make_unique<class_handle<BinningArg> >(CODE_SIGNATURE);
        plhs[out_arg::mex_code_hldrOut] = bin_arg_holder->export_hanlder_toMatlab();
    }
    else {
        if (!new_call) {
            return bin_arg_holder;
        }

    }
    auto bin_arg_ptr = bin_arg_holder->class_ptr;
    bin_arg_ptr->parse_bin_inputs(prhs[in_arg::param_struct]);
};


/**  Parse input binning arguments and set new BinningArg from MATLAB input arguments
*    structure.
**/
void BinningArg::parse_bin_inputs(mxArray const* pAllParStruct) {
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
    // define functions which would check and set BinninPar values from the input assigned
    // to MATLAB structure.
    this->BinParInfo["coord_in"] = [this](mxArray const* const pField) {
        auto nDims = mxGetNumberOfDimensions(pField);
        if (nDims != 2) {  // get value for computational mode the alogrithm should run
            std::stringstream buf;
            buf << "input pixel data have to be represented by 2 - dimensional matrix\n";
            buf << "Provided input "<<(short)nDims << "dimensional array";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
        this->coord_ptr = pField;
        this->in_pix_width = mxGetM(pField);
        this->n_data_points = mxGetN(pField);
        };
    this->BinParInfo["binning_mode"] = [this](mxArray const* const pField) {
        if (!mxIsScalar(pField)) {  // get value for computational mode the alogrithm should run
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
    //
    this->BinParInfo["num_threads"] = [this](mxArray const* const pField) {
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
    this->BinParInfo["data_range"] = [this](mxArray const* const pField) {
        auto nDims = mxGetNumberOfDimensions(pField);// get size of the range matrix
        if (nDims != 2) {  
            std::stringstream buf;
            buf << "input data range have to be represented by 2 - dimensional matrix\n";
            buf << "Provided input is: " << (short)nDims << "dimensional array";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
        auto minmax_width = mxGetM(pField);
        auto minmax_length= mxGetN(pField);
        if (minmax_width != 2 || minmax_length != 4) {
            std::stringstream buf;
            buf << "input data range have to be represented by 2x4 - matrix\n";
            buf << "Provided input has: " << (short)minmax_width <<"x" << (short)minmax_length <<"components";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
        auto pData = mxGetPr(pField);
        this->data_range.assign(pData,pData+8);
        };
    this->BinParInfo["bins_all_dims"] = [this](mxArray const* const pField) {
        auto nDims = mxGetNumberOfDimensions(pField);// get size of the range matrix
        if (nDims != 2) {
            std::stringstream buf;
            buf << "input binning range have to be represented by 2 - dimensional matrix\n";
            buf << "Provided input is: " << (short)nDims << "dimensional array";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
        auto bins_width = mxGetM(pField);
        auto bins_length = mxGetN(pField);
        if (bins_width != 2 || bins_length != 4) {
            std::stringstream buf;
            buf << "input binning array have to be represented by 2x4 - matrix\n";
            buf << "Provided input has: " << (short)bins_width << "x" << (short)bins_length << "components";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
        auto pData = mxGetPr(pField);
        this->num_bins.assign(pData, pData + 8);
        };
    this->BinParInfo["force_double"] = [this](mxArray const* const pField) {
        if (!mxIsScalar(pField)) {
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                "fore_double parameters should be defined by scalar value");
        }
        auto do_testing = mxGetScalar(pField);
        this->test_inputs = bool(do_testing);
        };

    this->BinParInfo["test_input_parsing"] = [this](mxArray const* const pField) {
        if (!mxIsScalar(pField)) {
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                "test_input_parsing parameters should be defined by scalar value");
        }
        auto do_testing = mxGetScalar(pField);
        this->test_inputs = bool(do_testing);
        };
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
        this->BinParInfo[field_name](fld_ptr);
    }
    //// retrieve information about coordinates of pixels to bin
    //auto* pcoord = prhs[in_arg::coord];
    //if (mxGetNumberOfDimensions(pcoord) != 2) {
    //    std::stringstream buf;
    //    buf << "Coordinate array must have only 2 dimensions\n";
    //    buf << "Provided array has: " << (int)mxGetNumberOfDimensions(pcoord) << " dimensions\n";

    //    mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
    //        buf.str().c_str());
    //}
    //this->coord_type = mxGetClassID(pcoord);
    //this->coord_size.reserve(2);
    //auto dims = mxGetDimensions(pcoord);
    //this->coord_size[0] = int(dims[0]);
    //this->coord_size[1] = int(dims[1]);
    //if (this->coord_size[0] < 3 || this->coord_size[0]>9) {
    //    std::stringstream buf;
    //    buf << "First dimension of coordinate array must lie between 3 and 9\n";
    //    buf << "Provided array's dimension 0 equal to : " << this->coord_size[0] << "\n";
    //    mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
    //        buf.str().c_str());
    //}
    //this->pCoord = mxGetPr(pcoord);

    //// Retrieve information about npix, S and Err arrays
    //auto* tpNpix = prhs[in_arg::npixIn];
    // 

    //plhs[out_arg::npix] = mxDuplicateArray(tpNpix);
    //plhs[out_arg::Signal] = mxDuplicateArray(tpSig);
    //plhs[out_arg::Error] = mxDuplicateArray(tpErr);

    //// assume all size checks were done by calling function. It is easier
    //// to do it from MATLAB
    //pNpix = (double*)mxGetPr(plhs[out_arg::npix]);
    //pSignal = (double*)mxGetPr(plhs[out_arg::Signal]);
    //pErr = (double*)mxGetPr(plhs[out_arg::Error]);
    return;
}


/** Copy input arguments into appropriate places of output arguments for debugging purposes
**/
void BinningArg::return_inputs(mxArray* plhs[]) {

    auto number_of_fields = this->OutParList.size();
    plhs[out_arg::out_par_names] = mxCreateCellMatrix(1, mwSize(number_of_fields));
    plhs[out_arg::out_par_values] = mxCreateCellMatrix(1, mwSize(number_of_fields));

    /* ********************************************************************************
     * retrieve binning parameters form BinningArg class and copy them into output array
    ** ********************************************************************************/
    // define functions which would convert binning parameters into MATLAB data
    int fld_idx(0);
    this->OutParList["coord_in"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
        mxSetCell(pFieldName, fld_idx, mxCreateString("coord_in"));
        mxSetCell(pFieldValue, fld_idx, pFieldValue);
        };

    this->OutParList["binning_mode"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
        auto mode = double(this->binMode + 1);// C-modes are smaller then MATLAB modes by 1
        mxSetCell(pFieldName, fld_idx, mxCreateString("binning_mode"));
        mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(mode));
        };
    //
    this->OutParList["num_threads"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
        auto n_threads = double(this->num_threads);
        mxSetCell(pFieldName, fld_idx, mxCreateString("num_threads"));
        mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(n_threads));
        };
    this->OutParList["data_range"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
        auto range = this->data_range;
        auto pRange = mxCreateDoubleMatrix(2, 4, mxREAL);
        double* const pData = (double*)mxGetPr(pRange);
        for (auto i = 0; i < range.size(); i++) {
            *(pData + i) = range[i];
        }
        mxSetCell(pFieldName, fld_idx, mxCreateString("data_range"));
        mxSetCell(pFieldValue, fld_idx, pRange);
        };
    this->OutParList["dimensions"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
        auto n_dims = double(this->n_dims);
        mxSetCell(pFieldName, fld_idx, mxCreateString("dimensions"));
        mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(n_dims));
        };
    this->OutParList["bins_all_dims"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
        auto num_bins = this->num_bins;
        auto pNBins = mxCreateNumericMatrix(2, 4, mxUINT32_CLASS, mxREAL);
        auto pData  = (uint32_t*)mxGetPr(pNBins);
        for (auto i = 0; i < num_bins.size(); i++) {
            *(pData + i) = (uint32_t)num_bins[i];
        }
        mxSetCell(pFieldName, fld_idx, mxCreateString("bins_all_dims"));
        mxSetCell(pFieldValue, fld_idx, pNBins);
        };
    this->OutParList["unique_runid"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
         // incomplete!!!
        mxSetCell(pFieldName, fld_idx, mxCreateString("unique_runid"));
        mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(0));
        };
    this->OutParList["test_input_parsing"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
        auto test_inputs = this->test_inputs;
        mxSetCell(pFieldName, fld_idx, mxCreateString("test_input_parsing"));
        mxSetCell(pFieldValue, fld_idx, mxCreateLogicalScalar(test_inputs));
        };
    // Copy BinningArg values to output cellarrays
    auto pFieldNames = plhs[out_arg::out_par_names];
    auto pFieldValues = plhs[out_arg::out_par_values];
    for (auto iter = this->OutParList.begin(); iter != this->OutParList.end(); iter++) {
        // call appropriate field-processing function and set up appropriate MATLAB values
        // from the values of the BinningArg fields
        iter->second(pFieldNames, pFieldValues);
        fld_idx++;
    }
}
