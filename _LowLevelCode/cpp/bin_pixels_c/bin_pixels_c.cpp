#include "bin_pixels.h"
#include "../utility/version.h"
// combile code using c-mutexes
#define C_MUTEXES
//
//
//static std::unique_ptr<omp_storage> pStorHolder;
//
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
//*************************************************************************************************
// the function (bin_pixels_c) distributes pixels according to the 4D-grid specified and
// calculates signal and error within grid cells
// usage:
// >>> bin_pixels_c(sqw_data,urange,grid_size);
// where sqw_data -- sqw structure with defined array of correct pixels data
// urange         -- allowed range of the pixels; the pixels which are out of the range are rejected
// grid_size      -- integer array of the grid dimensions in every 4 directions
//*************************************************************************************************
// Matlab code:
//    % Reorder the pixels according to increasing bin index in a Cartesian grid->
//    [ix,npix,p,grid_size,ibin]=sort_pixels(sqw_data.pix(1:4,:),urange,grid_size_in);
//    % transform pixels;
//    sqw_data.pix=sqw_data.pix(:,ix);
//    sqw_data.s=reshape(accumarray(ibin,sqw_data.pix(8,:),[prod(grid_size),1]),grid_size);
//    sqw_data.e=reshape(accumarray(ibin,sqw_data.pix(9,:),[prod(grid_size),1]),grid_size);
//    sqw_data.npix=reshape(npix,grid_size);      % All we do is write to file, but reshape for consistency with definition of sqw data structure
//    sqw_data.s=sqw_data.s./sqw_data.npix;       % normalize data
//
//    sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalize variance
//    clear ix ibin   % biggish arrays no longer needed
//    nopix=(sqw_data.npix==0);
//    sqw_data.s(nopix)=0;
//    sqw_data.e(nopix)=0;
// based on original % Original matlab code of : T.G.Perring
//
{
    mwSize  iGridSizes[4],     // array of grid sizes
        nGridDimensions,    // number of dimensions in the whole grid (usually 4 according to the pixel data but can be modified in a future
        i;
    double* pS, * pErr, * pNpix;   // arrays for the signal, error and number of pixels in a cell (density);
    mxArray* PixelSorted;
    //
    if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
#ifdef _OPENMP
        plhs[0] = mxCreateString(Horace::VERSION);
#else
        plhs[0] = mxCreateString(Horace::VER_NOOMP);
#endif
        return;
    }


    if (nrhs != N_INPUT_Arguments) {
        std::stringstream buf;
        buf << "ERROR::bin_pixels_c needs" << (short)N_INPUT_Arguments << "  but got " << (short)nrhs << " input arguments\n";
        mexErrMsgTxt(buf.str().c_str());
    }
    //  if(nlhs>N_OUTPUT_Arguments) {
    //    std::stringstream buf;
    //	buf<<"ERROR::bin_pixels accepts only "<<(short)N_OUTPUT_Arguments<<" but requested to return"<<(short)nlhs<<" arguments\n";
    //    mexErrMsgTxt(buf.str().c_str());
    //  }
    if (!mxIsCell(prhs[Sqw_parameters])) {
        mexErrMsgTxt("ERROR::bin_pixels_c function needs to receive its parameters as a cell array\n");
    }
    size_t nPars = mxGetN(prhs[Sqw_parameters]);

    if (nPars != N_ARGUMENT_CELLS) {
        std::stringstream buf;
        buf << "ERROR::bin_pixels_c expects array of " << (short)N_ARGUMENT_CELLS;
        buf << "cells \n but got " << (short)nPars << " cells\n";
        mexErrMsgTxt(buf.str().c_str());
    }


    int num_threads;
    mxArray* pThreads = mxGetCell(prhs[Sqw_parameters], Threads);
    if (pThreads) {
        num_threads = (int)*mxGetPr(pThreads);
    }
    else {
        num_threads = 1;
        mexPrintf("WARNING::bin_pixels_c->can not retrieve the number of computational threads from calling workspace, 1 assumed");
    }
    if (num_threads < 1)num_threads = 1;
    if (num_threads > 64)num_threads = 64;

    double const* const pGrid_sizes = (double*)mxGetPr(mxGetCell(prhs[Sqw_parameters], Grid_size));
    double const* const pUranges = (double*)mxGetPr(mxGetCell(prhs[Sqw_parameters], Urange));
    nGridDimensions = mxGetN(mxGetCell(prhs[Sqw_parameters], Grid_size));
    if (nGridDimensions > 4)mexErrMsgTxt(" we do not currently work with the grids which have more then 4 dimensions");

    mwSize    totalGridSize(1);  // number of cells in the whole grid;
    for (i = 0; i < nGridDimensions; i++) {
        iGridSizes[i] = (mwSize)(pGrid_sizes[i]);
        if (iGridSizes[i] < 1)iGridSizes[i] = 1;
        totalGridSize *= iGridSizes[i];
    }
    //**************************************************************
    // get pixels information
    mxArray* const pPixData = mxGetCell(prhs[Sqw_parameters], Pix);
    if (!pPixData)mexErrMsgTxt("ERROR::bin_pixels_C-> pixels information (last field of input data) can not be void");
    // this field has to had the format specified;
    mwSize  nPixels = mxGetN(pPixData);
    mwSize  nDataRange = mxGetM(pPixData);
    if (nDataRange != PIX_WIDTH)mexErrMsgTxt("ERROR::bin_pixels-> the pixel data have to be a 9*num_of_pixels array");

    //
    plhs[0] = mxCreateCellMatrix(1, N_ARGUMENTS_OUT);
    if (!plhs[0]) {
        mexErrMsgTxt("ERROR::bin_pixels_c-> can not allocate cell array for output parameters");
    }

    mxArray* tt;
    for (i = 0; i < N_ARGUMENTS_OUT - 1; i++) {
        tt = mxCreateNumericArray(nGridDimensions, iGridSizes, mxDOUBLE_CLASS, mxREAL);
        if (!tt)mexErrMsgTxt("ERROR::bin_pixels->can not allocate memory for output signals errors and npixels");
        mxSetCell(plhs[0], i, tt);
    }

    pS = (double*)mxGetPr(mxGetCell(plhs[0], Signal));
    pErr = (double*)mxGetPr(mxGetCell(plhs[0], Error));
    pNpix = (double*)mxGetPr(mxGetCell(plhs[0], N_pix));
    // Clear accumulation cells.
    for (i = 0; i < totalGridSize; i++) {
        *(pS + i) = 0;
        *(pErr + i) = 0;
        *(pNpix + i) = 0;
    }

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


