#pragma once
#include <string>
#include <map>
#include <functional>
#include "../CommonCode.h"

// enumerate input arguments of the mex function
enum in_arg {
    coord,  // 3xnpix or 4xnpix dimensional array of pixels coordinates to bin
    npixIn,   // image array containing number of pixels contributing into each bin
    SignalIn, // image array containing signal. May be empty pointer
    ErrorIn,  // image array containing errors. May be empty pointer
    param_struct,  // other possible input parameters and data for the binning algorithm, combined into structure processed separately
    N_IN_Arguments
};
// enumerate output arguments of the mex function
enum out_arg {
    npix,   // pointer to modified npix array
    Signal, // pointer to modified signal array 
    Error,  // pointer to modified error array
    cell_out, // pointer to cellarray with other possible outputs
    cell_out_debug, // pointer to cellarray used during during input parameters debugging
    N_OUT_Arguments
};

// enumerate operational modes bin pixels operates in
enum opModes {
    npix_only    = 0, // calculate npix array only binning coordinates over
    invalid_mode = 1, // this mode is not supported by binning routine
    sig_err      = 2, // calculate npix, signal and error
    sort_pix     = 3, // in additional to binning, return pixels sorted by bins
    sort_and_id  = 4, // in additional to binning and sorting, return unique pixels id
    nosort       = 5, // do binning but do not sort pixels but return array which defines pixels position
    //                   within the image grid
    nosort_sel   = 6, // like 6, but return ?logical? array which specifies what pixels have been selected
    //                   and what were rejected by binning operations
    test_inputs  = 7, // do not do calculations but just return parsed inputs for 
    //                   unit testing
    N_OP_Modes   = 8   // total number of modes code operates in. Provided for checks
};


// structure describes all parameters used by binning procedure
class BinningArg{
public:
    opModes binMode;
    size_t n_dims; // number of dimensions
    std::vector<double> data_range; // range of the data to bin within
    std::vector<size_t> num_bins;   // number of bins in each non-unit dimension
    int num_threads;                // number of computational threads to use in binning loop
    // information about pixels coordinates to bin.
    mxClassID coord_type;           // type of input coordinate array (mxDouble or mxSingle)
    std::vector<int> coord_size;    // 2-element array describing sizes of coordinate array
    void const* pCoord;             // pointer to the start of the coordinate array
    // vector of unique run-id(s) calculated from pixels data
    std::vector<double> unique_runIDIn;
    //
    bool test_inputs;
public:
    BinningArg():
        binMode(opModes::npix_only), n_dims(0),num_threads(8),
        coord_type(mxClassID::mxDOUBLE_CLASS),pCoord(nullptr), test_inputs(false){
        /* initialize input Matlab parameters map with empty lambda functions
        * Actual property specific lambda function will be initialized later
        */
        for (const auto& key : {
            "binning_mode",     // what parameters calculate during the binning 
            "num_threads",      // how many computational threads to deploy for calculations
            "data_range",       // the range of data to bin in
            "dimensions",       // number of dimensions the binning should be performed on
            "bins_all_dims",    // 
            "unique_runid",
            "test_input_parsing"
            }) {
            this->BinParInfo.emplace(key, [](mxArray const* const){});  // Default initialize value of empty lambda
        }
        // copy input MATLAB structure keys list into output Matlab keys list
        for (auto iter = this->BinParInfo.begin();iter != this->BinParInfo.end(); iter++) {
            auto key = iter->first;
            this->OutParList.emplace(key, [this](mxArray* p1, mxArray* p2) {
                });
        }
    };

    void parse_inputs(mxArray const* prhs[], int nRhs, mxArray* plhs[], int nlhs,
        double*& pNpix, double*& pSignal, double*& pErr);
    void return_inputs(mxArray* plhs[], int nlhs);
private:
    // map to keep list of function to process input values from MATLAB structure
    std::unordered_map<std::string, std::function<void(mxArray const* const)> > BinParInfo;
    // map to keep list of functions to process output values in case of testing parameters parsing
    std::unordered_map<std::string, std::function<void(mxArray * p1, mxArray * p2)> > OutParList;
};

