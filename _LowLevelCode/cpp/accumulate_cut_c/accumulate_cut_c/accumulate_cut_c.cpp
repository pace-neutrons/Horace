// accumulate_cut.cpp : Defines the exported functions for the DLL application.
#include "accumulate_cut_c.h"

enum InputArguments {
    Pixel_data,
    Signal,
    Error,
    Npixels,
    CoordRotation_matrix,
    CoordShif_matrix,
    Scale_energy,
    Shift_energy,
    DataCut_range,
    Plot_axis,
    Program_settings,
    N_INPUT_Arguments
};
enum OutputArguments { // unique output arguments,
    Actual_Pix_Range,
    Pixels_Ok,
    Pixels_Ind,
    Signal_modified,
    Error_Modified,
    Npixels_out,
    Npix_Retained,
    N_OUTPUT_Arguments
};


const int PIXEL_DATA_WIDTH = 9;
const int OUT_PIXEL_DATA_WIDTH = 4;
/*
% Syntax:
[cut_range_pix, ok, ix, {s,e,npix -- modified on place} ] = accumulate_cut (s,e,npix,pixel_data,cut_range_pix,...
cut_range, rot_ustep, trans_bott_left, ebin, trans_elo, pax,...
parameters)
% Accumulate signal into output arrays
%
%
% Input: (* denotes output argument with same name exists - exploits in-place working of Matlab R2007a)
% * s                Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
% * e                Array of accumulated variance
% * npix             Array of number of contributing pixels
% * actual_pix_range Actual range of contributing pixels
%   cut_range     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
%                  integration axes (or plot axes with one bin), and (ii) step range (0 to no. bins)
%                  for plotaxes (with more than one bin)
%   rot_ustep       Matrix [3x3]     --|  that relate a vector expressed in the
%   trans_bott_left Translation [3x1]--|  frame of the pixel data to no. steps from lower data limit
%                                             r_step(i) = A(i,j)(r(j) - trans(j))
%   ebin            Energy bin width (plays role of rot_ustep for energy axis)
%   trans_elo       Bottom of energy scale (plays role of trans_bott_left for energy axis)
and parameters is the array of program parameters namely:
parameters[0]->Ignore_Nan -- ignore pixels with NaN data
parameters[1]->Ignore_Inf -- ignore pixels with Inf data
parameters[2]->Keep_pixels -- Set to 1 if wish to retain the information about individual pixels; set to 0 if not
parameters[3]->N_Parallel_Processes Number of threads to execute OMP code
parameters[4]->If pixel array is provided, is it double or single precision array.
if there are no parameters specified, then defaults are parameters[]={1,1,0,1,8}
%
% Output:
%   npix            Array of numbers of contributing pixels
%   actual_pix_range Actual range of contributing pixels
%   nPixel_retained Number of pixels that contribute to the cut
%   ok              If keep_pix==true: v(:,ok) are the pixels that are retained; otherwise =[]
%   ix              If keep_pix==true: column vector full bin index of each retained pixel; otherwise =[]
%
%
% Note:
based on Matlab code of T.G.Perring   19 July 2007; C-version Alex Buts 02 July 2009
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }

    //* Check for proper number of arguments. */
    {
        if (nrhs != N_INPUT_Arguments&&nrhs != N_INPUT_Arguments - 1) {
            std::stringstream buf;
            buf << "ERROR::Accomulate_cut needs " << (short)N_INPUT_Arguments << " or one less, but got " << (short)nrhs
                << " input arguments and " << (short)nlhs << " output argument(s)\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        if (nlhs != N_OUTPUT_Arguments) {
            std::stringstream buf;
            buf << "ERROR::Accomulate_cut needs " << (short)N_OUTPUT_Arguments << " outputs but requested to return" << (short)nlhs << " arguments\n";
            mexErrMsgTxt(buf.str().c_str());
        }

        for (int i = 0; i < nrhs - 1; i++) {
            if (prhs[i] == NULL) {
                std::stringstream buf;
                buf << "ERROR::Accomulate_cut=> argument N" << i << " undefined\n";
                mexErrMsgTxt(buf.str().c_str());
            }
        }
    }
    // program parameters; get from the data or use defaults
    mxArray *ppS(NULL);
    // inputs:
    std::vector<double> projSettings(4);
    if (nrhs == N_INPUT_Arguments) {
        double  *pProg_settings;
        pProg_settings = (double *)mxGetPr(prhs[Program_settings]);
        for (size_t i = 0; i < 4; i++) {
            projSettings[i]=pProg_settings[i];
        }
    }
    else {
        // supply defaults
        projSettings[Ignore_Nan] = 1; projSettings[Ignore_Inf] = 1; projSettings[Keep_pixels] = 0; projSettings[N_Parallel_Processes] = 1;
    }
    // associate and extract all inputs
    //----------------------------------------------------------------------------------------------------------
    //  pixel_data(9,:)              u1,u2,u3,u4,irun,idet,ien,s,e for each pixel,
    //                               where ui are coords in projection axes of the pixel data in the file
    size_t  nPixDataRows = mxGetM(prhs[Pixel_data]);
    size_t  nPixDataCols = mxGetN(prhs[Pixel_data]);
    mxClassID  category = mxGetClassID(prhs[Pixel_data]);
    bool pixDataAreDouble;
    switch(category) {
        case(mxDOUBLE_CLASS):
            pixDataAreDouble = true;
            break;
        case(mxSINGLE_CLASS):
            pixDataAreDouble = false;
            break;
        default:
            mexErrMsgTxt("pixels type can be either single or double. Got unsupported type");
    }
    // Make it double to cast to necessary type later
    double const *pPixelData = (double *)mxGetPr(prhs[Pixel_data]);

    // * s                           Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
    int    nDimensions = (int)mxGetNumberOfDimensions(prhs[Signal]);
    mwSize const*pmDims = mxGetDimensions(prhs[Signal]);
    mwSize signalSize(1);
    for (int i = 0; i < nDimensions; i++) {
        signalSize *= pmDims[i];
    }

    double const* rot_matrix = (double *)mxGetPr(prhs[CoordRotation_matrix]);
    double const* shift_matrix = (double *)mxGetPr(prhs[CoordShif_matrix]);
    double const  e_shift = *mxGetPr(prhs[Shift_energy]);
    double const  ebin = *mxGetPr(prhs[Scale_energy]);

    double const *data_limits = (double *)mxGetPr(prhs[DataCut_range]);
    // plot axis
    double const *pPAX = mxGetPr(prhs[Plot_axis]);
    int    const nAxis = (int)mxGetN(prhs[Plot_axis]);

    // check the consistency of the input data
    {
        if (nPixDataRows != PIXEL_DATA_WIDTH) {
            mexErrMsgTxt("Pixel data has to be a 9xN matrix where 9 is the number of pixels' data and N -- number of pixels");
        }
        if (nDimensions < 1 || nDimensions>4) {
            std::stringstream buf;
            buf << " Dimensions of the accumulated data can vary from 1 to 4 but currently it set to " << nDimensions << std::endl;
            mexErrMsgTxt(buf.str().c_str());
        }
        if (nDimensions != (int)mxGetNumberOfDimensions(prhs[Error])) {
            mexErrMsgTxt(" Dimensions of the signal and error arrays has to be the same");
        }
        if (nDimensions != (int)mxGetNumberOfDimensions(prhs[Npixels])) {
            mexErrMsgTxt(" Dimensions of the n-pixel array has to be equal to the dimensions of the signal array");
        }
        mwSize const* pmErr = mxGetDimensions(prhs[Error]);
        mwSize const* pmNpix = mxGetDimensions(prhs[Npixels]);
        for (int i = 0; i < nDimensions; i++) {
            if (pmDims[i] != pmErr[i] || pmDims[i] != pmNpix[i]) {
                std::stringstream buf;
                buf << " Shapes of signal, error and npix arrays has to coincide\n";
                buf << " but the direction and shapes are:" << (short)i << " " << (short)pmDims[i] << " " << pmErr[i] << " " << pmNpix[i] << std::endl;
                mexErrMsgTxt(buf.str().c_str());
            }
        }

        //*****
        if (mxGetM(prhs[CoordRotation_matrix]) != 3 || mxGetN(prhs[CoordRotation_matrix]) != 3) {
            mexErrMsgTxt(" Coordinates Rotation has to be a 3x3 matrix");
        }
        if (mxGetM(prhs[CoordShif_matrix]) != 3 || mxGetN(prhs[CoordShif_matrix]) != 1) {
            mexErrMsgTxt(" Coordinates shift has to be a 1x3 matrix");
        }
        if (mxGetM(prhs[Scale_energy]) != 1 || mxGetN(prhs[Scale_energy]) != 1) {
            mexErrMsgTxt(" Energy scale has to be a scalar");
        }
        if (mxGetM(prhs[Shift_energy]) != 1 || mxGetN(prhs[Shift_energy]) != 1) {
            mexErrMsgTxt(" Energy shift has to be a scalar");
        }
        //*****
        if (mxGetM(prhs[DataCut_range]) != 2 || mxGetN(prhs[DataCut_range]) != OUT_PIXEL_DATA_WIDTH) {
            mexErrMsgTxt(" Data range has to be a 2x4 matrix");
        }
        //
        if (signalSize > 1)
        {
            if (mxGetM(prhs[Plot_axis]) != 1 || nAxis > 4) {
                mexErrMsgTxt(" Plot axis has to be a vector of 0 to 4 numbers");
            }
            for (unsigned int i = 0; i < mxGetN(prhs[Plot_axis]); i++) {
                if (pPAX[i] < 1 || pPAX[i]>4) {
                    std::stringstream buf;
                    buf << " Plot axis can vary from 1 to 4, while we get the number" << (short)pPAX[i] << " for the dimension" << (short)i << std::endl;
                    mexErrMsgTxt(buf.str().c_str());
                }
            }
        }
        // process issue occurring with 1D cut, when axis is 1 and signal array is 2D array with second dimension 1 (always in Matlab) 
        if (nAxis != nDimensions) {
            if ((nDimensions == 2 && nAxis == 1) || nAxis == 0) // this may be actually one dimensional plot or 0 dimensional plot (point)
            {
                if (pmDims[1] == 1) { // have to work with a defied shape (column) arrays 
                    nDimensions = 1;
                }
            }
            else {
                std::stringstream buf;
                buf << " number of output axis " << nAxis << " and number of data dimensions " << nDimensions << " are not equal";
                mexErrMsgTxt(buf.str().c_str());
            }
        }
    }//
    //-------------------------------------------------------------------------------------------------------------
    // preprocess input arguments and identify the grid sizes
    std::vector<mwSize> grid_size(OUT_PIXEL_DATA_WIDTH, 0);
    // integer axis indexes (taken from pPax)
    std::vector<int> iAxis(OUT_PIXEL_DATA_WIDTH, -1); // maximum value not to bother with alloc/delete


    if (nAxis > 0)
    {
        for (int i = 0; i < nDimensions; i++) {
            iAxis[i] = iRound(pPAX[i]);
            grid_size[iAxis[i] - 1] = iRound(pmDims[i]); // here iAxis[i]-1 to agree with the numbering of the arrays in Matlab 
        }                                                 // c-arrays.
    } // else -- everything will be added to a single point, grid_size is all 0;


    //****************************************************************************************************************
    //* Create matrixes for the return arguments */
    //****************************************************************************************************************
    mwSize dims[2]; // the dims will be used later too.
    dims[0] = nPixDataCols;
    dims[1] = 1;

    mxArray *pixOK = mxCreateLogicalArray(2, dims);
    if (!pixOK) {
        mexErrMsgTxt(" Can not allocate memory for pixel validity array\n");
    }
    mxLogical *ok = (mxLogical *)mxGetPr(pixOK);

    plhs[Actual_Pix_Range] = mxCreateDoubleMatrix(2, 4, mxREAL);
    if (!plhs[Actual_Pix_Range]) {
        mexErrMsgTxt(" Can not allocate memory for actual pixel range matrix\n");
    }
    double *pPixRange = (double *)mxGetPr(plhs[Actual_Pix_Range]);

    // Due to COW pointers, we need to duplicate output into inputs
    // signals
    plhs[Signal_modified]=mxDuplicateArray(prhs[Signal]);
    // errors
    plhs[Error_Modified] = mxDuplicateArray(prhs[Error]);
    // nPixels
    plhs[Npixels_out]    = mxDuplicateArray(prhs[Npixels]);
    // *s
    double *pSignal = (double *)mxGetPr(plhs[Signal_modified]);
    // * e                           Array of accumulated variance
    double *pError = (double *)mxGetPr(plhs[Error_Modified]);
    double *pNpix = (double *)mxGetPr(plhs[Npixels_out]);


    plhs[Npix_Retained] = mxCreateDoubleMatrix(1, 1, mxREAL);
    if (!plhs[Npix_Retained]) {
        mexErrMsgTxt(" Can not allocate memory to hold number of retained pixels -- bizarre\n");
    }
    //

    mwSize nPixels_retained = 0;
    try {
        if (pixDataAreDouble) {
            nPixels_retained = accumulate_cut<double>(pSignal, pError, pNpix,
                pPixelData, nPixDataCols,
                ok, plhs[Pixels_Ind], pPixRange,
                rot_matrix, shift_matrix, ebin, e_shift, data_limits,
                grid_size, iAxis, nAxis, projSettings);
        }else {
            const float *pFloatPixData = reinterpret_cast<const float *>(pPixelData);
            nPixels_retained = accumulate_cut<float>(pSignal, pError, pNpix,
                pFloatPixData, nPixDataCols,
                ok, plhs[Pixels_Ind], pPixRange,
                rot_matrix, shift_matrix, ebin, e_shift, data_limits,
                grid_size, iAxis, nAxis, projSettings);

        }
    }
    catch (const char *err) {
        mexErrMsgTxt(err);
    } catch (...) {
        mexErrMsgTxt("Got unhandled exception from accumulate_cut block");
    }


    if (!iRound(projSettings[Keep_pixels])) { // if we do not keep pixels, let's free the array of the pixels in range
        mxDestroyArray(pixOK);
        dims[0] = 0;
        dims[1] = 0;
        plhs[Pixels_Ok] = mxCreateLogicalArray(2, dims);
    }
    else {
        plhs[Pixels_Ok] = pixOK;
    }

    if (ppS) {
        mxDestroyArray(ppS);
    }
    *(mxGetPr(plhs[Npix_Retained])) = (double)nPixels_retained;
}



