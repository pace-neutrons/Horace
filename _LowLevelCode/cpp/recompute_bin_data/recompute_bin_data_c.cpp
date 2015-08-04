#include "recompute_bin_data.h"


enum InputArguments {
    Npix_data,
    Pixel_data,
    Num_threads,
    N_INPUT_Arguments
};
enum OutputArguments { // unique output arguments,
    Signal,
    Error,
    N_OUTPUT_Arguments
};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision::      $ ($Date::                                              $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }

    //* Check for proper number of arguments. */
    {
        if (nrhs != N_INPUT_Arguments&&nrhs != N_INPUT_Arguments - 1) {
            std::stringstream buf;
            buf << "ERROR::recompute_bin_data_c needs " << (short)N_INPUT_Arguments << " but got " << (short)nrhs
                << " input arguments and " << (short)nlhs << " output argument(s)\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        if (nlhs != N_OUTPUT_Arguments) {
            std::stringstream buf;
            buf << "ERROR::recompute_bin_data_c needs " << (short)N_OUTPUT_Arguments << " outputs but requested to return" << (short)nlhs << " arguments\n";
            mexErrMsgTxt(buf.str().c_str());
        }

        for (int i = 0; i < nrhs - 1; i++) {
            if (prhs[i] == NULL) {
                std::stringstream buf;
                buf << "ERROR::recompute_bin_data_c => argument N" << i << " undefined\n";
                mexErrMsgTxt(buf.str().c_str());
            }
        }
    }
    /********************************************************************************/
    /* retrieve input parameters */
    // get npix -- can be 1-D to 4D double array
    double const * const pNpix = (double *)mxGetPr(prhs[Npix_data]);
    if (!pNpix)mexErrMsgTxt("ERROR::recompute_bin_data_c-> undefined or empty npix array");


    mwSize num_of_dims = mxGetNumberOfDimensions(prhs[Npix_data]);
    const mwSize *dims = mxGetDimensions(prhs[Npix_data]);

    // Get pixels array
    // this one can be either float or double one day. But not yet
    //mxClassID category = mxGetClassID(cell_element_ptr);
    // if (category == mxDOUBLE_CLASS or mxSINGLE_CLASS)
    //***********************************
    double const * const pPixelData = (double *)mxGetPr(prhs[Pixel_data]);
    if (!pPixelData)mexErrMsgTxt("ERROR::recompute_bin_data_c-> undefined or empty pixels array");
    size_t  nPixels = mxGetN(prhs[Pixel_data]);
    size_t  nPixDataCols = mxGetM(prhs[Pixel_data]);
    if (nPixDataCols != pix_fields::PIX_WIDTH)mexErrMsgTxt("ERROR::recompute_bin_data_c-> the pixel data have to be a 9*num_of_pixels array");

    double *pThreads  = (double *)mxGetPr(prhs[Num_threads]);
    int n_threads = int(*pThreads);
    // Check wrong n_threads
    if (n_threads>128) n_threads = 8;
    if (n_threads<=0) n_threads = 1;

    /********************************************************************************/
    /* Define output*/
    plhs[Signal] = mxCreateNumericArray(num_of_dims, dims, mxDOUBLE_CLASS, mxREAL);
    if (!plhs[Signal])mexErrMsgTxt("ERROR::recompute_bin_data_c-> can not allocate memory for output signal array");
    plhs[Error] = mxCreateNumericArray(num_of_dims, dims, mxDOUBLE_CLASS, mxREAL);
    if (!plhs[Error])mexErrMsgTxt("ERROR::recompute_bin_data_c-> can not allocate memory for output error array");

    double *pSignal = (double *)mxGetPr(plhs[Signal]);
    double *pError  = (double *)mxGetPr(plhs[Error]);
    size_t distr_size(1);
    for (size_t i = 0; i < num_of_dims; i++) {
        distr_size*=size_t(dims[i]);
    }
    try {
        recompute_pix_sums(pSignal,pError, distr_size, pNpix, pPixelData, nPixels, n_threads);

    }catch(const char *err) {
        mexErrMsgTxt(err);
    }


}