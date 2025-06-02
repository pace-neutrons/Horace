#include "BinningArg.h"

#define UNSAFE_CASTING
/**  Parse input arguments and set BinningArg from MATLAB input arguments
*
**/
void BinningArg::parse_inputs(mxArray const* prhs[], int nRhs, mxArray* plhs[], int nlhs,
    double*& pNpix, double*& pSignal, double*& pErr) {


    // retrieve information about coordinates of pixels to bin
    auto* pcoord = prhs[in_arg::coord];
    if (mxGetNumberOfDimensions(pcoord) != 2) {
        std::stringstream buf;
        buf << "Coordinate array must have only 2 dimensions\n";
        buf << "Provided array has: " << (int)mxGetNumberOfDimensions(pcoord) << " dimensions\n";

        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    this->coord_type = mxGetClassID(pcoord);
    this->coord_size.reserve(2);
    auto dims = mxGetDimensions(pcoord);
    this->coord_size[0] = int(dims[0]);
    this->coord_size[1] = int(dims[1]);
    if (this->coord_size[0] < 3 || this->coord_size[0]>9) {
        std::stringstream buf;
        buf << "First dimension of coordinate array must lie between 3 and 9\n";
        buf << "Provided array's dimension 0 equal to : " << this->coord_size[0] << "\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    this->pCoord = mxGetPr(pcoord);

    // Retrieve information about npix, S and Err arrays
    auto* tpNpix = prhs[in_arg::npixIn];
    auto* tpSig  = prhs[in_arg::SignalIn];
    auto* tpErr  = prhs[in_arg::ErrorIn];
    // 
#ifdef UNSAFE_CASTING
    plhs[out_arg::npix] = const_cast<mxArray*>(tpNpix);
    plhs[out_arg::Signal] = const_cast<mxArray*>(tpSig);
    plhs[out_arg::Error] = const_cast<mxArray*>(tpErr);
#else
    plhs[out_arg::npix] = mxDuplicateArray(tpNpix);
    plhs[out_arg::Signal] = mxDuplicateArray(tpSig);
    plhs[out_arg::Error] = mxDuplicateArray(tpErr);
#endif
    // assume all size checks were done by calling function. It is easier
    // to do it from MATLAB
    pNpix = (double*)mxGetPr(plhs[out_arg::npix]);
    pSignal = (double*)mxGetPr(plhs[out_arg::Signal]);
    pErr = (double*)mxGetPr(plhs[out_arg::Error]);

    /* ********************************************************************************
     * retrieve and analyse other binning parameters collated into binning structure. *
    ** ********************************************************************************/
    // define functions which would check and set BinninPar values from the input assigned
    // to MATLAB structure.

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
    this->BinParInfo["test_input_parsing"] = [this](mxArray const* const pField) {
        if (!mxIsScalar(pField)) {
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                "test_input_parsing parameters should be defined by scalar values");
        }
        auto do_testing = mxGetScalar(pField);
        this->test_inputs = bool(do_testing);
        };
    //************************************************************************** 
    // Transform inputs from MATLAB structure values to binning values
    auto pAllPar = plhs[in_arg::param_struct];
    auto argType = mxGetClassID(pAllPar);
    if (argType != mxSTRUCT_CLASS) {
        std::stringstream buf;
        buf << in_arg::param_struct << "'s parameter of input class should be a structure with binning parameters\n";
        buf << "It is something else with MATLAB mex classID: " << argType << "\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto total_num_of_elements = mxGetNumberOfElements(pAllPar);
    if (total_num_of_elements != 1) {
        std::stringstream buf;
        buf << "Structure with binning parameters have to have 1 element. \n";
        buf << "It has: " << (short)total_num_of_elements << "elements\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto number_of_fields = mxGetNumberOfFields(pAllPar);
    /* For the given index, walk through each field. */
    for (int fld_idx = 0; fld_idx < number_of_fields; fld_idx++) {
        auto field_name = std::string(mxGetFieldNameByNumber(pAllPar, fld_idx));
        auto fld_ptr = mxGetFieldByNumber(pAllPar, 0, fld_idx);
        // call appropriate fiel-processing function and set up appropriate MATLAB
        // parameters into current binning class instance.
        this->BinParInfo[field_name](fld_ptr);
    }

    return;
}


/** Copy input arguments into appropriate places of output arguments for debugging purposes
**/
void BinningArg::return_inputs(mxArray* plhs[], int nlhs) {

    auto number_of_fields = this->OutParList.size();
    plhs[out_arg::cell_out] = mxCreateCellMatrix(1, mwSize(number_of_fields));
    plhs[out_arg::cell_out_debug] = mxCreateCellMatrix(1, mwSize(number_of_fields));

    /* ********************************************************************************
     * retrieve binning parameters form BinningArg class and copy them into output array
    ** ********************************************************************************/
    // define functions which would convert binning parameters into MATLAB data
    int fld_idx(0);
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
        auto pNBins = mxCreateDoubleMatrix(2, 4, mxREAL);
        double* const pData = (double*)mxGetPr(pNBins);
        for (auto i = 0; i < num_bins.size(); i++) {
            *(pData + i) = num_bins[i];
        }
        mxSetCell(pFieldName, fld_idx, mxCreateString("bins_all_dims"));
        mxSetCell(pFieldValue, fld_idx, pNBins);
        };
    this->OutParList["unique_runid"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
        auto n_threads = double(this->num_threads);
        mxSetCell(pFieldName, fld_idx, mxCreateString("unique_runid"));
        mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(n_threads));
        };
    this->OutParList["test_input_parsing"] = [this, fld_idx](mxArray* pFieldName, mxArray* pFieldValue) {
        auto test_inputs = this->test_inputs;
        mxSetCell(pFieldName, fld_idx, mxCreateString("test_input_parsing"));
        mxSetCell(pFieldValue, fld_idx, mxCreateLogicalScalar(test_inputs));
        };
    // Copy BinningArg values to output cellarrays
    auto pFieldNames = plhs[out_arg::cell_out];
    auto pFieldValues = plhs[out_arg::cell_out_debug];
    for (auto iter = this->OutParList.begin(); iter != this->OutParList.end(); iter++) {
        // call appropriate field-processing function and set up appropriate MATLAB values
        // from the values of the BinningArg fields
        iter->second(pFieldNames, pFieldValues);
        fld_idx++;
    }
}
