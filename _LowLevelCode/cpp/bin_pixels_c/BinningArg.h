#pragma once
#include <functional>

#include <include/CommonCode.h>
#include <include/MatlabCppClassHolder.hpp>
#include <map>
#include <unordered_set>
#include <numeric>
#include <string>
#include <utility/version.h>

// enumerate possible types of input/output pixel && coord arguments
enum InOutTransf {
    InCrd4OutPix4,
    InCrd4OutPix8,
    InCrd8OutPix8
};

// enumerate input arguments of the mex function
enum in_arg {
    mex_code_hldrIn, // pointer to the class shared with Matlab and containing persistent input arguments and binning arrays
    // storage of the mex-function.
    npixIn, // image array containing number of pixels contributing into each bin. Actually used as indicator of first call to binning code
    signalIn, // image array containing signals
    errorIn, //  image array containing errors
    param_struct, // other possible input parameters and data for the binning algorithm, combined into structure processed separately
    N_IN_Arguments
};
// enumerate output arguments of the mex function
enum out_arg {
    mex_code_hldrOut, // pointer to the class shared with Matlab and containing persistent input arguments and binning arrays
    npix, // pointer to modified npix array
    Signal, // pointer to modified signal array
    Error, // pointer to modified error array
    out_par_names, // pointer to cellarray with the names  of other possible output parameters
    out_par_values, // pointer to cellarray with the values of other possible output parameters
    N_OUT_Arguments
};
enum out_arg_mode0 {
    mex_code_hldrOut0, // pointer to the class shared with Matlab and containing persistent
    npix0, // pointer to modified npix array
    out_par_names0, // pointer to cellarray with the names  of other possible output parameters
    out_par_values0, // pointer to cellarray with the values of other possible output parameters
    N_OUT_Arguments0
};

// enumerate operational modes bin pixels operates in
enum opModes {
    npix_only = 0, // calculate npix array only binning coordinates over
    invalid_mode = 1, // this mode is not supported by binning routine
    sig_err = 2, // calculate npix, signal and error
    sigerr_cell = 3, // signal and error for binning are presented in cellarrays of data rather then pixel data array
    sort_pix = 4, // in additional to binning, return pixels sorted by bins
    sort_and_uid = 5, // in additional to binning and sorting, return unique pixels id
    nosort = 6, // do binning but do not sort pixels but return array which defines pixels position
    //              within the image grid
    nosort_sel = 7, // like 6, but return logical array which specifies what pixels have been selected
    //                   and what were rejected by binning operations
    siger_selected = 8, // the same as sig_err but return logical array of selected piels instead of pix_ok array
    test_inputs = 9, // do not do calculations but just return parsed inputs for
    //                  unit testing
    N_OP_Modes = 10 // total number of modes code operates in. Provided for checks
};

// define the map type to keep functions which set up output parameters in a structure, specific for given binning mode;
using OutHandlerMap = std::unordered_map<std::string, std::function<void(mxArray* p1, mxArray* p2, int idx, const std::string& name)>>;

/* class describes all parameters used by binning procedure
 * use Matlab pointers for all transient array, which may change from call to call to mex function
 * and update these pointers on each call or vectors to all parameters which expect to be retained
 * between calls
 */
class BinningArg {
public:
    opModes binMode; // the operation mode, binning routine would operate
    InOutTransf InOutTypeTransf; // what input pixel types provided and ouptout pixel types requested
    size_t n_dims; // number of DnD object dimensions. changes from 0 to 4 and differs from Matlab arrays dimensions (from 2 to 4)
    std::vector<double> data_range; // range of the data to bin within
    std::vector<uint32_t> nbins_all_dims; // number of bins in each non-unit dimension
    int num_threads; // number of computational threads to use in binning loop

    // information about pixels coordinates to bin.
    mxArray const* coord_ptr;
    size_t in_coord_width; // how many pixel rows have to be binned (3 or 4)
    size_t n_data_points; // number of pixel elements to bin into image
    mxArray const* all_pix_ptr; // pointer to array or cellarray of all pixels containing signal and error
    // info for binning and sorting if necessary
    size_t in_pix_width; // how many non-modified pixel data rows are provided in app_pix_ptr (9)
                         // other information may be requested to process e.g. sorted pixels, pix_idx etc...
    size_t n_Cells_to_bin; // number of cells to bin in opModes::sigerr_cell mode
    std::vector<double> alignment_matrix; // if defined, contains 3x3 matrix to use for aligning the pixels
    // vector of unique run-id(s) calculated from pixels data
    bool check_pix_selection; // if true, verify if pixels have been previously selected by a symmetry operation

    // logical variable which request to return transformed pixel data as double precision regardless
    // of their input accuracy.
    bool force_double;
    // logical variable with enables test mode returning input to outputs if
    bool test_inputs;
    //********************************************************************************
    // Properties which contain results, obtained in various binning modes
    //********************************************************************************
    size_t distr_size; // number of elements in the arrays below
    // pointers to double accumulators used to calculate image averages (npix signal and error)
    mxArray* npix_ptr;
    mxArray* signal_ptr;
    mxArray* error_ptr;
    // number of pixels retained after binning
    size_t n_pix_retained;
    // resulting range of pixels
    mxArray* pix_data_range_ptr;
    mxArray* pix_ok_ptr; // pointer to array of all pixels retained after binning
    std::unordered_set<uint32_t> unique_runID; // set containing unique run_id-s of the
    mxArray* pix_img_idx_ptr; // pointer to array of pixel indices within the image cell 
    mxArray* is_pix_selected_ptr; // pointer to logical array containing true where pixel 
    //                               was selected for binning and false otherwise
    // processed pixels
    //********************************************************************************
    // helper values
    std::vector<double> bin_step; // vector of binning sizes in all non-unit directions
    std::vector<size_t> pax; // vector of projection axes to bin pixels over
    std::vector<size_t> stride; // vector, which describes binning steps reflecting multidimensional array strides
    std::vector<size_t> bin_cell_idx_range; // vector containing allowed maximal indixes of the binning (with nbins_all_dims>1) cells in binning directions
    // auxiliary array containing pixel indices over bins
    std::vector<long> pix_ok_bin_idx;
    // auxiliary array defining ranges of the bins to sort pixels over
    std::vector<size_t> npix_bin_start;
    std::vector<size_t> npix1; // pixel distribution over bins calculated in single call to bin_pixels routine;


    // calculate size of the binning grid
    size_t n_grid_points()
    {
        size_t product = std::accumulate(
            nbins_all_dims.begin(), nbins_all_dims.end(),
            size_t(1), // promote to size_t
            [](size_t a, size_t b) {
                return a * b;
            });
        return product;
    }

protected:
    // register with parameters map all methods which accept input parameters from MATLAB
    void register_input_methods();
    // setters for all binning properties retrieved from MATLAB
    void set_coord_in(mxArray const* const pField); //   // Input pixels coordinates to bin. May be empty in modes where they are produced from pixels coordinates
    void set_binning_mode(mxArray const* const pField); // what parameters calculate during the binning
    void set_num_threads(mxArray const* const pField); // how many computational threads to deploy for calculations
    void set_data_range(mxArray const* const pField); // the range of data to bin in
    void set_dimensions(mxArray const* const pField); // number of dimensions the binning should be performed on
    void set_nbins_all_dims(mxArray const* const pField); //
    void set_unique_runid(mxArray const* const pField); // holder for the information about unique run_id-s present in the data. Set procedure is non-standard
    void set_force_double(mxArray const* const pField); // boolean parameters which would request output transformed pixels always been double regardless of input pixels
    void set_test_input_mode(mxArray const* const pField); // intialize testing mode (or not)
    void set_all_pix(mxArray const* const pField); //  pointer to all pixels to sort or use as binning arguments
    void set_alignment_matrix(mxArray const* const pField); // matrix which have to be applied to raw pixels to bring them into Crystal Cartesian coordinate system
    void set_check_pix_selection(mxArray const* const pField); // if true, check if detector_id are negative which may suggest that pixels have been alreary used in previous binning operation

    // register with parameters map all methods which
    void register_output_methods();
    // setters for binning results returned to MATLAB in output structure
    void return_npix_retained(mxArray* p1, mxArray* p2, int idx, const std::string& name);
    // setter for result of calculating pixels data range
    void return_pix_range(mxArray* p1, mxArray* p2, int idx, const std::string& name);
    // setter for possible pixels
    void return_pix_ok_data(mxArray* p1, mxArray* p2, int idx, const std::string& name);
    // setter to return unique run_id,.calculated in the call
    void return_unique_runid(mxArray* p1, mxArray* p2, int idx, const std::string& name);
    // setter to return pixels indices within the image cell
    void return_pix_img_idx(mxArray* p1, mxArray* p2, int fld_idx, const std::string& name);
    // setter to return array containing true for selected pixels and false if they have not been selected
    void return_is_pix_selected(mxArray* p1, mxArray* p2, int fld_idx, const std::string& name);
    //
public:
    BinningArg(); // construction
    // process binning arguments input values for new binning arguments cycle
    void parse_bin_inputs(mxArray const* pAllParStruct);
    // process binning arguments which have changed during followitng call to binning procedure
    void parse_changed_bin_inputs(mxArray const* pAllParStruct);
    // generate test output which would echo input values
    void return_test_inputs(mxArray* plhs[], int nlhs);
    // return various inputs
    void return_results(mxArray* plhs[], mwSize nlhs);
    // check if input binning parameters are new or have been changed
    bool new_binning_arguments_present(mxArray const* prhs[]);
    // check if input accumulators have not been changed and initalize them appropriately
    void check_and_init_accumulators(mxArray* plhs[], mxArray const* prhs[], bool force_update = false);
    // get number of dimensions for accumulator array to allocate using MATLAB methods
    mwSize get_Matlab_n_dimensions();
    // get dimensions of accumulator array to allocate using MATLAB methods
    mwSize* get_Matlab_acc_dimensions(size_t &distr_size);

private:
    // map to keep list of function to process input values from MATLAB structure
    std::unordered_map<std::string, std::function<void(mxArray const* const)>> BinParInfo;
    // map to keep list of functions to process output values in case of testing parameters parsing
    std::unordered_map<std::string, std::function<void(mxArray* p1, mxArray* p2, int idx, const std::string& name)>> OutParList;
    // holder for actual array dimensions to allocate
    std::vector<mwSize> accumulator_dims_holder;
    // helper function to calculate binning sizes in all non-unit directions
    void calc_step_sizes_pax_and_strides();

    OutHandlerMap Mode0ParList;
    OutHandlerMap Mode4ParList;
    OutHandlerMap Mode5ParList;
    OutHandlerMap Mode6ParList;
    OutHandlerMap Mode7ParList;
    OutHandlerMap Mode8ParList;

    std::unordered_map<opModes, OutHandlerMap*> out_handlers;
};
