#pragma once
#include <string>
#include <map>
#include <functional>
#include <include/CommonCode.h>
#include <include/MatlabCppClassHolder.hpp>

// enumerate input arguments of the mex function
enum in_arg {
    mex_code_hldrIn, // pointer to the class shared with Matlab and containing persistent input arguments and binning arrays
                     // storage of the mex-function.
    npixIn,          // image array containing number of pixels contributing into each bin. Actually used as indicator of first call to binning code
    param_struct,    // other possible input parameters and data for the binning algorithm, combined into structure processed separately
    N_IN_Arguments
};
// enumerate output arguments of the mex function
enum out_arg {
    mex_code_hldrOut, // pointer to the class shared with Matlab and containing persistent 
    npix,   // pointer to modified npix array
    Signal, // pointer to modified signal array 
    Error,  // pointer to modified error array
    out_par_names,  // pointer to cellarray with the names  of other possible output parameters
    out_par_values, // pointer to cellarray with the values of other possible output parameters
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

    //information about pixels coordinates to bin.
    mxArray* coord_ptr; 
    // vector of unique run-id(s) calculated from pixels data
    std::vector<double> unique_runIDIn;
    // logical variable with enables test mode returning input to outputs if 
    bool test_inputs;
    // pointers to double accumulators used to calculate image averages (npix signal and error)
    mxArray* npix_ptr;
    mxArray* signal_ptr;
    mxArray* error_ptr;
public:
    BinningArg():
        binMode(opModes::npix_only), n_dims(0),num_threads(8),
        coord_ptr(nullptr), test_inputs(false),
        npix_ptr(nullptr),signal_ptr(nullptr),error_ptr(nullptr)
    {
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
    // process binning arguments input values
    void parse_bin_inputs(mxArray const* prhs[]);
    // generate test output which would echo input values
    void return_inputs(mxArray* plhs[], int nlhs);
private:
    // map to keep list of function to process input values from MATLAB structure
    std::unordered_map<std::string, std::function<void(mxArray const* const)> > BinParInfo;
    // map to keep list of functions to process output values in case of testing parameters parsing
    std::unordered_map<std::string, std::function<void(mxArray * p1, mxArray * p2)> > OutParList;
};

// Declare procedure which will initialize binning inputs from MATLAB call
std::unique_ptr<class_handle<BinningArg> > parse_inputs(mxArray const* prhs[], mxArray* plhs[]);

