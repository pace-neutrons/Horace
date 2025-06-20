#include "BinningArg.h"
#include <cstdlib>
#include <limits>
#include <random>

// check binning arguments and return true if new binning arguments are present
bool BinningArg::new_binning_arguments_present(mxArray const* prhs[])
{
    if (mxIsEmpty(prhs[in_arg::npixIn])) {
        return true;
    }
    auto inpar_structure_ptr = prhs[in_arg::param_struct];

    // check if data range have changed. Even epsilon changes can not occur here
    std::vector<double> oldDataRange(this->data_range.begin(), this->data_range.end());
    this->set_data_range(mxGetField(inpar_structure_ptr, 0, "data_range"));
    if (oldDataRange != this->data_range)
        return true;

    // check if binning have changed
    std::vector<uint32_t> old_nbins_all_dims(this->nbins_all_dims.begin(), this->nbins_all_dims.end());
    this->set_nbins_all_dims(mxGetField(inpar_structure_ptr, 0, "nbins_all_dims"));

    return (old_nbins_all_dims != this->nbins_all_dims);

}; //

void BinningArg::set_coord_in(mxArray const* const pField)
{
    auto nDims = mxGetNumberOfDimensions(pField);
    if (nDims != 2) { // get value for computational mode the alogrithm should run
        std::stringstream buf;
        buf << "input pixel coordinates to bin have to be represented by 2 - dimensional matrix\n";
        buf << "Provided input " << (short)nDims << " dimensional array";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    this->coord_ptr = pField;
    this->in_coord_width = mxGetM(pField);
    this->n_data_points = mxGetN(pField);
    if (this->in_coord_width < 3 || this->in_coord_width > 4) {
        std::stringstream buf;
        buf << "input pixel coordinates to bin have to be represented by a matrix with at least 3 and not more then 4 rows\n";
        buf << "Provided input have: " << (short)this->in_coord_width << " rows";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
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
    if (minmax_width != 2 || !(minmax_length == 4 || minmax_length == 3)) {
        std::stringstream buf;
        buf << "input data range have to be represented by 2x4 or 2x3 - matrix\n";
        buf << "Provided input has: " << (short)minmax_width << "x" << (short)minmax_length << " components";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto pData = mxGetPr(pField);
    this->data_range.assign(pData, pData + 2 * minmax_length);
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
void BinningArg::set_nbins_all_dims(mxArray const* const pField)
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
    if (bins_width != 1 || !(bins_length == 4 || bins_length == 3)) {
        std::stringstream buf;
        buf << "input binning array have to be represented by 1x4 or 1x3 - matrix\n";
        buf << "Provided input has: " << (short)bins_width << "x" << (short)bins_length << " components";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto pData = (uint32_t*)mxGetPr(pField);
    this->nbins_all_dims.assign(pData, pData + bins_length);
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
    auto force_double = mxGetScalar(pField);
    this->force_double = bool(force_double);
};

// check property which would verify if "selected" array is returned
void BinningArg::set_return_selected(mxArray const* const pField)
{
    if (!mxIsScalar(pField)) {
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "return_selected parameters should be defined by scalar value");
    }
    auto return_selected = mxGetScalar(pField);
    this->return_selected = bool(return_selected);
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

// set pixels array used as source of signal and many other input parameters
void BinningArg::set_all_pix(mxArray const* const pField)
{
    if (mxIsEmpty(pField)) {
        this->all_pix_ptr = nullptr;
        this->in_pix_width = 0;
        return;
    }
    auto nDims = mxGetNumberOfDimensions(pField);
    if (nDims != 2) { // get value for computational mode the alogrithm should run
        std::stringstream buf;
        buf << "input pixel data have to be represented by 2 - dimensional matrix or cellarray of data vectors\n";
        buf << "Provided input " << (short)nDims << " dimensional array";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    this->all_pix_ptr = pField;
    auto type = mxGetClassID(pField);
    if (type == mxCELL_CLASS) {
        // check cell input and identify number of points stored in cell class
        this->binMode = opModes::sigerr_cell;
        auto nCells = mxGetNumberOfElements(pField);
        if (nCells > 2) {
            std::stringstream buf;
            buf << "Binning for more than 2 arrays of values is not supported \n";
            buf << "Provided " << (short)nCells << " cells to bin";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:not_implemented",
                buf.str().c_str());
        }
        size_t n_data_points(0);
        for (auto i = 0; i < nCells; i++) {
            auto a_cell_ptr = mxGetCell(pField, i);
            auto data_type = mxGetClassID(a_cell_ptr);
            if (data_type != mxDOUBLE_CLASS) {
                std::stringstream buf;
                buf << "Binning the dataype N " << data_type << " have not been implemented yet";
                mexErrMsgIdAndTxt("HORACE:bin_pixels_c:not_implemented",
                    buf.str().c_str());
            }
            auto Mi = mxGetM(a_cell_ptr);
            auto Ni = mxGetN(a_cell_ptr);
            if (i == 0) {
                n_data_points = std::max(Mi, Ni);
            } else {
                auto n_dp = std::max(Mi, Ni);
                if (n_dp != n_data_points) {
                    std::stringstream buf;
                    buf << "Each cell in data to bin must contain the same number of elements\n";
                    buf << "Cell N " << (short)i << " contains " << (short)n_dp << " elements which differs fron "
                        << (short)n_data_points << " in the firdst cell element";
                    mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                        buf.str().c_str());
                }
            }
            auto n_rows = std::min(Mi, Ni);
            if (n_rows != 1) {
                std::stringstream buf;
                buf << "Each cell in data to bin must contain 1D array of data\n";
                buf << "Cell N " << (short)i << " contains " << (short)n_rows << " rows";
                mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                    buf.str().c_str());
            }
        }
        this->n_data_points = n_data_points;
        this->in_pix_width = 1;
        this->n_Cells_to_bin = nCells;
    } else { // single or double precision array of full pixel coordinates
        this->in_pix_width = mxGetM(pField);
        this->n_data_points = mxGetN(pField); // should be dedined in set_coord too and values must be equal
        // no check, as Matlab will call it from routine which does this check
        if (this->in_pix_width != size_t(pix_flds::PIX_WIDTH)) {
            std::stringstream buf;
            buf << "Full input pixel coordinates to bin have to be represented by a matrix with 8 rows\n";
            buf << "Support for provided input with " << (short)this->in_pix_width << " rows is not implemented";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:not_implemented",
                buf.str().c_str());
        }
    }
}
//
void BinningArg::set_alignment_matrix(mxArray const* const pField)
{
    if (mxIsEmpty(pField)) {
        this->alignment_matrix.clear();
        return;
    }
    auto nDims = mxGetNumberOfDimensions(pField);
    if (nDims != 2) { // get value for computational mode the alogrithm should run
        std::stringstream buf;
        buf << "Alignment matrix should be defined by 2 - dimensional, 9 elements array\n";
        buf << "Provided input " << (short)nDims << " dimensional array";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    auto n_elements = mxGetNumberOfElements(pField);
    if (n_elements != 9) {
        std::stringstream buf;
        buf << "Alignment matrix should be defined by9 elements array\n";
        buf << "Provided input contains " << (short)n_elements << " elements";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    double* pData = mxGetPr(pField);
    this->alignment_matrix.assign(pData, pData + 9);
}
//
void BinningArg::set_check_pix_selection(mxArray const* const pField)
{
    if (!mxIsScalar(pField)) {
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            "check_pix_selection should be defined by scalar value");
    }
    auto check_selection = mxGetScalar(pField);
    this->check_pix_selection = bool(check_selection);
}
//===================================================================================
// return number of pixels retained in binning
void BinningArg::set_npix_retained(mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name)
{
    mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
    mxSetCell(pFieldValue, fld_idx, mxCreateDoubleScalar(this->n_pix_retained));
};

// return pixel data which belong to binning range if such data were calculated in appropriate mode requested
void BinningArg::set_pix_range(mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name)
{
    mxArray* pix_range;
    mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
    if (this->pix_data_range_ptr == nullptr) {
        pix_range = mxCreateDoubleMatrix(2, 0, mxREAL);
    } else {
        pix_range = this->pix_data_range_ptr;
    }
    mxSetCell(pFieldValue, fld_idx, pix_range);
};
// return pixel obtained after binning and may be sorting.Sets up empty matrix if algorithm have not been using pixels
void BinningArg::set_pix_ok_data(mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name)
{
    mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
    mxArray* pix_ok(nullptr);
    if (this->pix_ok_ptr) {
        pix_ok = this->pix_ok_ptr;
    } else {
        pix_ok = mxCreateDoubleMatrix(0, 0, mxREAL);
    }
    mxSetCell(pFieldValue, fld_idx, pix_ok);
};
//===================================================================================
// calculate steps used in binning over non-unit directions and numbers of these dimensions
void BinningArg::calc_step_sizes_pax_and_strides()
{
    // just in case. Binning parameters shoul not be reinitialized
    this->pax.clear();
    this->stride.clear();
    this->bin_step.clear();
    this->bin_cell_idx_range.clear();
    //
    size_t stride(1);
    size_t n_pix_dim = this->in_coord_width;

    for (size_t i = 0; i < n_pix_dim; i++) {
        if (this->nbins_all_dims[i] > 1) {
            auto n_bins = size_t(this->nbins_all_dims[i]);
            auto step = double(n_bins) / (this->data_range[2 * i + 1] - this->data_range[2 * i]);
            this->pax.push_back(i);
            this->bin_step.push_back(step);
            this->bin_cell_idx_range.push_back(n_bins-1);

            this->stride.push_back(stride);
            stride *= n_bins;
        }
    }
};

/* define functions which would check and set BinninPar values from the input assigned
   to MATLAB structure. */
void BinningArg::register_input_methods()
{
    this->BinParInfo["coord_in"] = [this](mxArray const* const pField) { this->set_coord_in(pField); };
    this->BinParInfo["binning_mode"] = [this](mxArray const* const pField) { this->set_binning_mode(pField); };
    this->BinParInfo["num_threads"] = [this](mxArray const* const pField) { this->set_num_threads(pField); };
    this->BinParInfo["data_range"] = [this](mxArray const* const pField) { this->set_data_range(pField); };
    this->BinParInfo["dimensions"] = [this](mxArray const* const pField) { this->set_dimensions(pField); };
    this->BinParInfo["nbins_all_dims"] = [this](mxArray const* const pField) { this->set_nbins_all_dims(pField); };
    this->BinParInfo["force_double"] = [this](mxArray const* const pField) { this->set_force_double(pField); };
    this->BinParInfo["return_selected"] = [this](mxArray const* const pField) { this->set_return_selected(pField); };
    this->BinParInfo["pix_candidates"] = [this](mxArray const* const pField) { this->set_all_pix(pField); };
    this->BinParInfo["check_pix_selection"] = [this](mxArray const* const pField) { this->set_check_pix_selection(pField); };
    this->BinParInfo["alignment_matr"] = [this](mxArray const* const pField) { this->set_alignment_matrix(pField); };
    this->BinParInfo["test_input_parsing"] = [this](mxArray const* const pField) { this->set_test_input_mode(pField); };
};
// register functions used to set output parameters of the binning code
void BinningArg::register_output_methods()
{
    this->Mode0ParList["npix_retained"] = [this](mxArray* p1, mxArray* p2, int idx, const std::string& name) { this->set_npix_retained(p1, p2, idx, name); };

    this->Mode3ParList["npix_retained"] = [this](mxArray* p1, mxArray* p2, int idx, const std::string& name) { this->set_npix_retained(p1, p2, idx, name); };
    this->Mode3ParList["pix_ok_data_range"] = [this](mxArray* p1, mxArray* p2, int idx, const std::string& name) { this->set_pix_range(p1, p2, idx, name); };
    this->Mode3ParList["pix_ok_data"] = [this](mxArray* p1, mxArray* p2, int idx, const std::string& name) { this->set_pix_ok_data(p1, p2, idx, name); };

    this->out_handlers[opModes::npix_only] = &Mode0ParList;
    this->out_handlers[opModes::sig_err] = &Mode3ParList;
    this->out_handlers[opModes::sigerr_cell] = &Mode3ParList;
    this->out_handlers[opModes::sort_pix] = &Mode3ParList;
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
        buf << "It has: " << (short)total_num_of_elements << " elements\n";
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
    // check if binning parameters corresponds to pixels coordinates width and adjust
    // binning if pixel_coordinates are smaller.
    if (this->nbins_all_dims.size() > this->in_coord_width) {
        this->nbins_all_dims.resize(this->in_coord_width);
    }
    // check consistency between cell input and binning mode
    if (this->n_Cells_to_bin > 0 && this->binMode != opModes::sigerr_cell) {
        std::stringstream buf;
        buf << "Binning mode " << this->binMode << " is inconsistent with input binning data provided as a cell";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    //
    // calculate binning steps and projection axis in all binning directions
    this->calc_step_sizes_pax_and_strides();
    if (this->in_pix_width == 0) {
        this->in_pix_width = this->in_coord_width;
    }

    // Identify what types of input-output transformation should be deployed
    // while binning pixels
    auto coord_type = mxGetClassID(this->coord_ptr);

    // check if coord_type corresponts to pix type
    mxClassID pix_type;
    if (this->all_pix_ptr) {
        pix_type = mxGetClassID(this->all_pix_ptr);
    } else {
        pix_type = mxUNKNOWN_CLASS;
    }
    if (pix_type == mxCELL_CLASS) { // cell class contains double value for binning. This verified on pix input
        if (coord_type != mxDOUBLE_CLASS) {
            std::stringstream buf;
            buf << "Coordinates array in the binning mode " << this->binMode << " have to be defined by double precision array";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
    } else if (pix_type != mxUNKNOWN_CLASS) {
        // This will be different in mode when coordinates are calculated from pixels
        // but this mode is not implemented yet
        if (coord_type != pix_type) {
            std::stringstream buf;
            buf << "Coordinates array type: " << coord_type << " must be equal to pixels array type: " << pix_type << "\n";
            buf << "Actually they are different";
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                buf.str().c_str());
        }
    }

    switch (coord_type) {
    case (mxSINGLE_CLASS): {
        if (this->force_double) {
            this->InOutTypeTransf = InOutTransf::InCrd4OutPix8;
        } else {
            this->InOutTypeTransf = InOutTransf::InCrd4OutPix4;
        }
        break;
    case (mxDOUBLE_CLASS): {
        this->InOutTypeTransf = InOutTransf::InCrd8OutPix8;
        break;
    }
    default: {
        std::stringstream buf;
        buf << "Input coordinate type N " << short(coord_type) << " does not currently supported";
        mexWarnMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    }
        return;
    }
};

// set up binning inputs changed at subsequent calls to bin pixels routine
void BinningArg::parse_changed_bin_inputs(mxArray const* pAllParStruct)
{
    // not checking validity of input pointer type as this is subsequent call, so
    // should already be valid
    /* ********************************************************************************
     * retrieve and analyse binning parameters collated into binning structure and changed
     * at the subsequent call to bin_pixels_c
     ** ********************************************************************************/
    switch (this->binMode) {
    case (opModes::npix_only): {
        this->set_coord_in(mxGetField(pAllParStruct, 0, "coord_in"));
        break;
    }
    default:
        this->set_coord_in(mxGetField(pAllParStruct, 0, "coord_in"));
        this->set_all_pix(mxGetField(pAllParStruct, 0, "pix_candidates"));
        // unique_runid, if provided, will be initilized in accumulators
        break;
    }
    return;
}

/** Copy input arguments into appropriate places of output arguments for debugging purposes
 **/
void BinningArg::return_test_inputs(mxArray* plhs[], int nlhs)
{
    // define functions which would convert binning parameters into MATLAB data
    this->OutParList["coord_in"] = [this](mxArray* pFieldName, mxArray* pFieldValue,
                                       int fld_idx, const std::string& field_name) {
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxDuplicateArray(this->coord_ptr));
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
            pData[i] = range[i];
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
            pData[i] = (uint32_t)this->nbins_all_dims[i];
        }
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, pNBins);
    };
    this->OutParList["unique_runid"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        // incomplete!!!
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        if (this->unique_runID.size() == 0) {
            mxSetCell(pFieldValue, fld_idx, mxCreateDoubleMatrix(0, 0, mxREAL));
        } else {
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                "unique run_id retrieval have not been implemented yet");
        }
    };
    this->OutParList["test_input_parsing"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto test_inputs = this->test_inputs;
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxCreateLogicalScalar(test_inputs));
    };
    this->OutParList["force_double"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto force_double = this->force_double;
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxCreateLogicalScalar(force_double));
    };
    this->OutParList["return_selected"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto return_selected = this->return_selected;
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxCreateLogicalScalar(return_selected));
    };
    this->OutParList["pix_candidates"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto all_pix_ptr = this->all_pix_ptr;
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxDuplicateArray(all_pix_ptr));
    };
    this->OutParList["check_pix_selection"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        auto check_selection = this->check_pix_selection;
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxSetCell(pFieldValue, fld_idx, mxCreateLogicalScalar(check_selection));
    };
    this->OutParList["alignment_matr"] = [this](mxArray* pFieldName, mxArray* pFieldValue, int fld_idx, const std::string& field_name) {
        mxSetCell(pFieldName, fld_idx, mxCreateString(field_name.c_str()));
        mxArray* al_matr(nullptr);
        if (this->alignment_matrix.size() == 0) {
            al_matr = mxCreateDoubleMatrix(0, 0, mxREAL);
        } else {
            al_matr = mxCreateDoubleMatrix(3, 3, mxREAL);
            auto dataPtr = mxGetPr(al_matr);
            for (size_t i = 0; i < 9; i++) {
                dataPtr[i] = this->alignment_matrix[i];
            }
        }
        mxSetCell(pFieldValue, fld_idx, al_matr);
    };
    this->OutParList["npix_retained"] = [this](mxArray* p1, mxArray* p2, int idx, const std::string& name) { this->set_npix_retained(p1, p2, idx, name); };
    this->OutParList["pix_ok_data_range"] = [this](mxArray* p1, mxArray* p2, int idx, const std::string& name) { this->set_pix_range(p1, p2, idx, name); };

    this->pix_ok_ptr = mxDuplicateArray(this->all_pix_ptr);
    this->OutParList["pix_ok_data"] = [this](mxArray* p1, mxArray* p2, int idx, const std::string& name) { this->set_pix_ok_data(p1, p2, idx, name); };

    /* ********************************************************************************
     * retrieve binning parameters form BinningArg class and copy them into output array
     ** ********************************************************************************/
    mxArray* pFieldNames(nullptr);
    mxArray* pFieldValues(nullptr);

    auto number_of_fields = this->OutParList.size();
    if (this->binMode == opModes::npix_only) {
        if (nlhs == 4) {
            plhs[out_arg_mode0::out_par_names0] = mxCreateCellMatrix(1, mwSize(number_of_fields));
            plhs[out_arg_mode0::out_par_values0] = mxCreateCellMatrix(1, mwSize(number_of_fields));
            pFieldNames = plhs[out_arg_mode0::out_par_names0];
            pFieldValues = plhs[out_arg_mode0::out_par_values0];
        } else {
            return;
        }
    } else {
        plhs[out_arg::out_par_names] = mxCreateCellMatrix(1, mwSize(number_of_fields));
        plhs[out_arg::out_par_values] = mxCreateCellMatrix(1, mwSize(number_of_fields));
        pFieldNames = plhs[out_arg::out_par_names];
        pFieldValues = plhs[out_arg::out_par_values];
    }
    //
    int fld_idx(0);
    for (auto iter = this->OutParList.begin(); iter != this->OutParList.end(); iter++) {
        // call appropriate field-processing function and set up appropriate MATLAB values
        // from the values of the BinningArg fields
        iter->second(pFieldNames, pFieldValues, fld_idx, iter->first);
        fld_idx++;
    }
};

// Copy various result depending on processing mode into output data structure
void BinningArg::return_results(mxArray* plhs[], mwSize nlhs)
{
    mwSize number_of_fields(0);
    auto out_func_map = this->out_handlers[opModes::npix_only];

    mxArray* pFieldNames(nullptr);
    mxArray* pFieldValues(nullptr);

    if (this->binMode == opModes::npix_only) {
        if (nlhs < out_arg_mode0::N_OUT_Arguments0 - 2) {
            return;
        }
        number_of_fields = out_func_map->size();
        plhs[out_arg_mode0::out_par_names0] = mxCreateCellMatrix(1, number_of_fields);
        plhs[out_arg_mode0::out_par_values0] = mxCreateCellMatrix(1, number_of_fields);
        pFieldNames = plhs[out_arg_mode0::out_par_names0];
        pFieldValues = plhs[out_arg_mode0::out_par_values0];
    } else {
        if (nlhs < out_arg::N_OUT_Arguments - 2) {
            return;
        }
        // retrieve map to set-up output parameters of the resulting structure
        out_func_map = this->out_handlers[this->binMode];

        number_of_fields = out_func_map->size();
        plhs[out_arg::out_par_names] = mxCreateCellMatrix(1, number_of_fields);
        plhs[out_arg::out_par_values] = mxCreateCellMatrix(1, number_of_fields);
        pFieldNames = plhs[out_arg::out_par_names];
        pFieldValues = plhs[out_arg::out_par_values];
    }

    int fld_idx(0);
    for (auto iter = out_func_map->begin(); iter != out_func_map->end(); iter++) {
        // call appropriate field-processing function and set up appropriate MATLAB values
        // from the values of the BinningArg fields
        iter->second(pFieldNames, pFieldValues, fld_idx, iter->first);
        fld_idx++;
    }
};

// check if input accumulators have not been changed and initalize them appropriately
void BinningArg::check_and_init_accumulators(mxArray* plhs[], mxArray const* prhs[], bool force_update)
{
    mwSize nDims(0);
    mwSize* dim_ptr(nullptr);
    bool init_new_accumulators(false);
    if (mxIsEmpty(prhs[in_arg::npixIn])) {
        init_new_accumulators = true;
        nDims = this->get_Matlab_n_dimensions();
        dim_ptr = this->get_Matlab_acc_dimensions(this->distr_size);
        this->npix_ptr = mxCreateNumericArray(nDims, dim_ptr, mxDOUBLE_CLASS, mxREAL);
        nullify_array(this->npix_ptr);
    } else {
        this->npix_ptr = mxDuplicateArray(prhs[in_arg::npixIn]);
    }
    plhs[out_arg::npix] = this->npix_ptr;

    if (this->binMode != opModes::npix_only) {
        if (init_new_accumulators) {
            this->signal_ptr = mxCreateNumericArray(nDims, dim_ptr, mxDOUBLE_CLASS, mxREAL);
            nullify_array(this->signal_ptr);
            if (this->binMode != opModes::sigerr_cell) {
                this->error_ptr = mxCreateNumericArray(nDims, dim_ptr, mxDOUBLE_CLASS, mxREAL);
                nullify_array(this->error_ptr);
            } else {
                if (this->n_Cells_to_bin == 2) {
                    this->error_ptr = mxCreateNumericArray(nDims, dim_ptr, mxDOUBLE_CLASS, mxREAL);
                    nullify_array(this->error_ptr);
                } else {
                    this->error_ptr = mxCreateDoubleMatrix(0, 0, mxREAL);
                }
            }
        } else {
            this->signal_ptr = mxDuplicateArray(prhs[in_arg::signalIn]);
            this->error_ptr = mxDuplicateArray(prhs[in_arg::errorIn]);
        }
        plhs[out_arg::Signal] = this->signal_ptr;
        plhs[out_arg::Error] = this->error_ptr;
    }
    if (this->binMode >= opModes::sort_pix) {
        if (this->n_data_points > this->pix_ok_bin_idx.size()) {
            this->pix_ok_bin_idx.resize(this->n_data_points);
        }
        // fill all positions of the pix_ok vector with certainly invalid value. Index can not be negative
        // this will indicate invalid elements
        std::fill(this->pix_ok_bin_idx.begin(), this->pix_ok_bin_idx.end(), -1);
        if (this->npix_bin_start.size() != this->distr_size) {
            this->npix_bin_start.resize(this->distr_size);
            this->npix1.resize(this->distr_size);
        }
        std::fill(this->npix1.begin(), this->npix1.end(), 0); //nullify accumulators for npix1
        // ranges calculated per each pixels block, i.e. calculations per call to bin_pixels_c
        this->pix_data_range_ptr = mxCreateDoubleMatrix(2, pix_flds::PIX_WIDTH, mxREAL);
    }
}

/* get array of dimensions to allocate in the form appropriate for using with Matlab *mxCreateNumericArray
** function.
* Returns:
* pointer to MATLAB array which defines dimensions for mxCreateNumericArray function
* distr_size -- total number of elements in this numerical array (product of all its dimensions)
**/
mwSize* BinningArg::get_Matlab_acc_dimensions(size_t& distr_size)
{
    distr_size = 1;
    this->accumulator_dims_holder.clear();
    if (this->n_dims == 0) {
        this->accumulator_dims_holder.push_back(1);
    } else {
        for (auto& element : this->nbins_all_dims) {
            if (element > 1) {
                distr_size *= element;
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
    , InOutTypeTransf(InOutTransf::InCrd4OutPix4)
    , n_dims(0)
    , num_threads(8)
    , coord_ptr(nullptr)
    , in_coord_width(4)
    , n_data_points(0)
    , all_pix_ptr(nullptr)
    , in_pix_width(9)
    , n_Cells_to_bin(0)
    , check_pix_selection(false)
    , force_double(false)
    , test_inputs(false)
    // accumulators
    , distr_size(0)  // number of elements in accumulators array
    , npix_ptr(nullptr)
    , signal_ptr(nullptr)
    , error_ptr(nullptr)
    // other possible results
    , n_pix_retained(0)
    , pix_data_range_ptr(nullptr)
    , pix_ok_ptr(nullptr)
{
    /* initialize input Matlab parameters map with methods which  associate
     * Matlab field names with the methods, which set appropriate property value  */
    this->register_input_methods();
    /* initialize output parameters map with methods which associate
     * output MATLAB field names with appropriate results to move to the structure */
    this->register_output_methods();
};
