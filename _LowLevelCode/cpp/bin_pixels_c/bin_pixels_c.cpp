#include "bin_pixels.h"
#include "../utility/version.h"

#define UNSAFE_CASTING

BinningArg parse_inputs(mxArray const* prhs[], int nRhs, mxArray* plhs[], int nlhs,
    double*& pNpix, double*& pSignal, double*& pErr) {

    BinningArg bin_par;

    // retrieve information about coordinates of pixels to bin
    auto* pcoord = prhs[in_arg::coord];
    if (mxGetNumberOfDimensions(pcoord) != 2) {
        std::stringstream buf;
        buf << "Coordinate array must have only 2 dimensions\n";
        buf << "Provided array has: " << (int)mxGetNumberOfDimensions(pcoord) << " dimensions\n";

        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    bin_par.coord_type = mxGetClassID(pcoord);
    bin_par.coord_size.reserve(2);
    auto dims = mxGetDimensions(pcoord);
    bin_par.coord_size[0] = int(dims[0]);
    bin_par.coord_size[1] = int(dims[1]);
    if (bin_par.coord_size[0] < 3 || bin_par.coord_size[0]>9) {
        std::stringstream buf;
        buf << "First dimension of coordinate array must lie between 3 and 9\n";
        buf << "Provided array's dimension 0 equal to : " << bin_par.coord_size[0] << "\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    bin_par.pCoord = mxGetPr(pcoord);

    // Retrieve information about npix, S and Err arrays
    auto* tpNpix = prhs[in_arg::npix];
    auto* tpSig = prhs[in_arg::Signal];
    auto* tpErr = prhs[in_arg::Error];
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
    // define map which relates field names of the input MATLAB structure with functions
    // which processes this input and 
    std::map < std::string, std::function<void(mxArray const* const)>> BinParInfo;
    /*
    'binning_mode', num_outputs, ...         % binning mode, what binning values to calculate and return
        'num_threads', num_threads, ...         % how many threads to use in computation
        'data_range', data_range, ...             % binning ranges
        'bins_all_dims', obj.nbins_all_dims, ... % size of binning lattice
        'dimensions', ndims, ...                 % number of image dimensions(sum(nbins_all_dims~= 1)))
        'test_input_parsing', test_mex_inputs ...% Run mex code in test mode validating the way input have been parsed by mex code and doing no caclculations.
    */
    BinParInfo["binning_mode"] = [&bin_par](mxArray const* const pField) {
        if (!mxIsScalar(pField)) {  // get value for computational mode the alogrithm should run
            mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
                "Binning mode can be defined only by scalar values");
        }
        auto mode = mxGetScalar(pField);
        bin_par.binMode = opModes(mode);
        };
    BinParInfo["num_threads"] = [&bin_par](mxArray const* const pField) {
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
        bin_par.num_threads = nthreads;
        };
    //***********************************************************************
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


        //display_subscript(structure_array_ptr, index);
        //field_name = mxGetFieldNameByNumber(structure_array_ptr,
        //    field_index);
        //mexPrintf(".%s\n", field_name);
        //field_array_ptr = mxGetFieldByNumber(structure_array_ptr,
        //    index,
        //    field_index);
        //if (field_array_ptr == NULL) {
        //    mexPrintf("\tEmpty Field\n");
        //}
        //else {
        //    /* Display a top banner. */
        //    mexPrintf("------------------------------------------------\n");
        //    get_characteristics(field_array_ptr);
        //    analyze_class(field_array_ptr);
        //    mexPrintf("\n");
        //}
    }

    return bin_par;
}
//
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
        buf << "ERROR::bin_pixels_c needs" << (short)N_IN_Arguments << "  but got " << (short)nrhs << " input arguments\n";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:invalid_argument",
            buf.str().c_str());
    }
    //  if(nlhs>N_OUTPUT_Arguments) {
    //    std::stringstream buf;
    //	buf<<"ERROR::bin_pixels accepts only "<<(short)N_OUTPUT_Arguments<<" but requested to return"<<(short)nlhs<<" arguments\n";
    //    mexErrMsgTxt(buf.str().c_str());
    //  }
    double* pS, * pErr, * pNpix;   // arrays for the signal, error and number of pixels in a cell (density);
    mxArray* PixelSorted;

    auto binning_par = parse_inputs(prhs, nrhs, plhs, nlhs, pNpix, pS, pErr);


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
}


#undef OMP_VERSION_3
#undef C_MUTEXES
#undef SINGLE_PATH


