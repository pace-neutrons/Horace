#include "sort_pixels_by_bins.h"
#include "../utility/version.h"

enum Input_Arguments {
    Pixel_data,
    Pixel_Indexes,
    Pixel_Distribution,
    keep_type,
    N_INPUT_Arguments
};
enum Out_Arguments {
    Pixels_Sorted,
    Pixels_range,
    N_OUTPUT_Arguments
};
/* What kind of input/output types the routine supports*/
enum InputOutputTypes {
    Pix8IndIOut8, // Double pixels, Int64 indexes, double output
    Pix8IndDOut8, // Double pixels, Double indexes, double output
    Pix4IndIOut8,
    Pix4IndDOut8, // Float pixels Int64 indexes double output
    Pix4IndIOut4, // Float pixels Int64 indexes float output
    Pix4IndDOut4,
    Pix4Ind4Out4, // float pixels float indexes, fload output
    Pix4Ind4Out8, // float pixels float indexes, double output
    Pix8Ind4Out8, // double pixels float indexes, double output
    ERROR,
    N_InputCases
};
enum InputIndexesType {
    IndI64,  // input indexes are unit64 type
    IndD64,  // input indexes are double64 type
    IndF32,  // input indexes are float32 type.
    N_InputIndexes
};

InputOutputTypes process_types(bool float_pix, InputIndexesType index_type, bool double_out)
{
    if (float_pix) { // input pixels are single precision pix
        switch (index_type)
        {
        case(IndI64):
            if (double_out) { return Pix4IndIOut8; }
            else { return Pix4IndIOut4; }
        case(IndD64):
            if (double_out) { return Pix4IndDOut8; }
            else { return Pix4IndDOut4; }
        case(IndF32):
            if (double_out) { return Pix4Ind4Out8; }
            else { return Pix4Ind4Out4; }
        default:
            return ERROR;
        }
    }
    else { // input pixels are double precision pix
        switch (index_type)
        {
            // we do not reduce double to single by this routine
        case(IndI64):
            return Pix8IndIOut8;
        case(IndD64):
            return Pix8IndDOut8;
        case(IndF32):
            return Pix8Ind4Out8;
        default:
            return ERROR;
        }
    }
}

std::string  verify_pix_array(const mxArray* pix_cell_array_ptr, bool& single_precision, std::vector<size_t>& pix_block_sizes,
    std::vector<const void*>& pPix_blocks, size_t& n_tot_pixels) {
    /* function processes and validates cell array of input pixels

    in particular, it calculates each cell size and number of pixels, containing in each array.
    */

    mxClassID   category;
    bool array_type_is_known(false);

    category = mxGetClassID(pix_cell_array_ptr);
    if (category != mxCELL_CLASS)return "Input pixel array has to be packed in cell array";

    n_tot_pixels = 0;

    const mxArray* cell_element_ptr;

    size_t num_of_cells = mxGetNumberOfElements(pix_cell_array_ptr);
    pix_block_sizes.assign(num_of_cells, 0);
    pPix_blocks.assign(num_of_cells, nullptr);

    /* Each cell mxArray contains 1-by-n cells; Each of these cells
    is an 9xNpix mxArray. */
    for (int ind = 0; ind < num_of_cells; ind++) {

        cell_element_ptr = mxGetCell(pix_cell_array_ptr, ind);
        if (cell_element_ptr == nullptr)
            continue;

        // some data are actually there
        if (mxIsEmpty(cell_element_ptr)) {
            pix_block_sizes[ind] = 0;
            pPix_blocks[ind] = nullptr;
        }
        else {
            // check if a contributing pixels have the same parameters
            category = mxGetClassID(cell_element_ptr);
            switch (category)
            {
            case (mxDOUBLE_CLASS):
                if (array_type_is_known) {
                    if (single_precision)
                        return "Double precision input pixels array contains blocks with single pixels. Only one type of pixels (single or double) is supported";
                }
                else {
                    single_precision = false;
                }
                pPix_blocks[ind] = reinterpret_cast<const double*>(mxGetPr(cell_element_ptr));
                break;
            case (mxSINGLE_CLASS):
                if (array_type_is_known) {
                    if (!single_precision)
                        return "Single precision input pixels array contains blocks with double pixels. Only one type of pixels (single or double) is supported";
                }
                else {
                    single_precision = true;
                }
                pPix_blocks[ind] = reinterpret_cast<const float*>(mxGetPr(cell_element_ptr));
                break;
            default:
                return "Input pixels array contains unsupported type of pixels. Only single and double precision pixels are supported";
            }
            array_type_is_known = true;

            auto number_of_dimensions = mxGetNumberOfDimensions(cell_element_ptr);
            auto dims = mxGetDimensions(cell_element_ptr);
            if (number_of_dimensions != 2)return "Input pixels array contains non-2D block of pixels";

            if (dims[0] != pix_fields::PIX_WIDTH)return "Input pixels array contains block of pixels with dimension 1 not equal to 9. Can not process this";
            // retrieve pixels block data
            n_tot_pixels += dims[1];
            pix_block_sizes[ind] = dims[1];
        }
    }

    return "";
};

std::string  verify_index_array(const mxArray* pix_cell_array_ptr, InputIndexesType& ind_type, std::vector<size_t>& ind_block_sizes,
    std::vector<const void*>& pInd_blocks, size_t& n_tot_pixels) {
    /* function processes and validates cell array of input indexes

    in particular, it calculates each cell size and number of indexes, retained in each cell array.
    */

    mxClassID   category;
    bool array_type_is_known(false);

    category = mxGetClassID(pix_cell_array_ptr);
    if (category != mxCELL_CLASS)return "Input pixel array has to be packed in cell array";

    n_tot_pixels = 0;


    const mxArray* cell_element_ptr;

    size_t num_of_cells = mxGetNumberOfElements(pix_cell_array_ptr);
    ind_block_sizes.assign(num_of_cells, 0);
    pInd_blocks.assign(num_of_cells, nullptr);


    /* Each cell mxArray contains n cells; Each of these cells
    is an 1D mxArray. */
    for (int ind = 0; ind < num_of_cells; ind++) {

        cell_element_ptr = mxGetCell(pix_cell_array_ptr, ind);
        if (cell_element_ptr == nullptr)
            continue;

        // not a null ptr
        if (mxIsEmpty(cell_element_ptr)) {
            ind_block_sizes[ind] = 0;
            pInd_blocks[ind] = nullptr;
        }
        else {
            // check if a contributing pixels have the same parameters
            category = mxGetClassID(cell_element_ptr);
            switch (category) {
            case (mxDOUBLE_CLASS):
                if (array_type_is_known) {
                    if (ind_type != IndD64)
                        return "Input indexes array contains blocks with different type of indexes. Only one type of indexes (int64, float or double) is supported";
                }
                else {
                    ind_type = IndD64;
                }
                pInd_blocks[ind] = reinterpret_cast<const double*>(mxGetPr(cell_element_ptr));
                break;
            case (mxINT64_CLASS):
                if (array_type_is_known) {
                    if (ind_type != IndI64)
                        return "Input indexes array contains blocks with different type of indexes. Only one type of indexes (int64, float or double) is supported";
                }
                else {
                    ind_type = IndI64;
                }
                pInd_blocks[ind] = reinterpret_cast<const int64_t*>(mxGetPr(cell_element_ptr));
                break;
            case (mxSINGLE_CLASS):
                if (array_type_is_known) {
                    if (ind_type != IndF32)
                        return "Input indexes array contains blocks with different type of indexes. Only one type of indexes (int64, float or double) is supported";
                }
                else {
                    ind_type = IndF32;
                }
                pInd_blocks[ind] = reinterpret_cast<const float*>(mxGetPr(cell_element_ptr));
                break;
            default:
                if (!mxIsEmpty(cell_element_ptr))
                    return "Input indexes array contains unsupported type of indexes. Only int64, float or double precision indexes are supported";
            }
            //
            array_type_is_known = true;
            auto number_of_dimensions = mxGetNumberOfDimensions(cell_element_ptr);
            auto dims = mxGetDimensions(cell_element_ptr);
            if (number_of_dimensions != 2)return "Input pixels array contains non-2D block of pixels";

            auto nInd = (dims[1] + dims[0] - 1);
            n_tot_pixels += nInd;
            ind_block_sizes[ind] = nInd;

        }
    }

    return "";
};


/**********************************************************************************************
! the function moves the pixels information into the places which correspond to the cells,
! to which the pixels belong to.
! takes 3 arguments:
!
! 1 -- cellarray of arrays of pixels for sorting
! 2 -- cellarray of arrays of indexes of pixels within cells (a cell has more then one pixel and all pixels within this cell have the same index)
! 3 -- number of pixels in each cell  (densities)
!
/**********************************************************************************************/
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
        plhs[0] = mxCreateString(Horace::VERSION);
        return;
    }

    std::stringstream buf;
    if (nrhs != N_INPUT_Arguments) {
        buf << "ERROR::sort_pixels_by_bins needs" << (short)N_INPUT_Arguments << "  but got " << (short)nrhs << " input arguments\n";
        mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:invalid_argument",
            buf.str().c_str());
    }
    if (nlhs > N_OUTPUT_Arguments) {
        buf << "ERROR::sort_pixels_by_bins accept only " << (short)N_OUTPUT_Arguments << " but requested to return" << (short)nlhs << " arguments\n";
        mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:invalid_argument",
            buf.str().c_str());
    }

    for (int i = 0; i < nrhs; i++) {
        if (prhs[i] == NULL) {
            buf << "ERROR::sort_pixels_by_bins=> input argument N" << i + 1 << " undefined\n";
            mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:invalid_argument",
                buf.str().c_str());
        }
    }
    // check if routine should keep input type
    bool keep_input_type(true);
    keep_input_type = (bool)getMatlabScalar<double>(prhs[keep_type], "keep_type");


    // evaluate input pixels cell array
    bool pix_single_precision(false);
    std::vector<size_t> pix_sizes;
    std::vector<const void*> pPix_blocks;
    size_t n_Input_pixels;
    std::string err_code = verify_pix_array(prhs[Pixel_data], pix_single_precision, pix_sizes, pPix_blocks, n_Input_pixels);
    if (err_code.size() > 0) {
        mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:invalid_argument", err_code.c_str());
    }
    // evaluate input indexes cell array
    InputIndexesType index_type;
    std::vector<size_t> index_sizes;
    std::vector<const void*> pIndex_blocks;
    size_t nPixelsSorted;
    err_code = verify_index_array(prhs[Pixel_Indexes], index_type, index_sizes, pIndex_blocks, nPixelsSorted);
    if (err_code.size() > 0) {
        mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:invalid_argument", err_code.c_str());
    }
    //Get  npix  array
    double* pCellDens = (double*)mxGetPr(prhs[Pixel_Distribution]);
    size_t distribution_size = mxGetNumberOfElements(prhs[Pixel_Distribution]);

    //mexWarnMsgTxt("entering allocation routines");
    bool double_output(false);
    try {
        std::vector<mwSize> dimVec(2, 9);
        dimVec[1] = nPixelsSorted;
        const mwSize* dims = &dimVec[0];
        if (pix_single_precision && keep_input_type) {
            plhs[Pixels_Sorted] = mxCreateNumericArray(2, dims, mxSINGLE_CLASS, mxREAL);
            double_output = false;
        }
        else {
            plhs[Pixels_Sorted] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
            double_output = true;
        }
        if (!plhs[Pixels_Sorted]) {
            mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:runtime_error",
                "Can not allocate memory for output pixels array");
        }
    }
    catch (...) {
        mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:runtime_error",
            "Can not allocate memory for output pixels array");
    }
    double* pPixelRange(nullptr);
    if (nlhs == 2) {
        try {
            plhs[Pixels_range] = mxCreateDoubleMatrix(2, pix_fields::PIX_WIDTH, mxREAL);
            if (!plhs[Pixels_range]) {
                mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:runtime_error",
                    "Can not allocate memory for output pixels ranges");
            }
        }
        catch (...) {
            mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:runtime_error",
                "Can not allocate memory for output pixels ranges");
        }
        pPixelRange = (double*)mxGetPr(plhs[Pixels_range]);
    }

    InputOutputTypes type_requested = process_types(pix_single_precision, index_type, double_output);
    if (type_requested == ERROR) {
        mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:invalid_argument",
            "Sort_pixels_by_bins: unsupported combination of input/output types");
    }

    try {
        size_t array_size = distribution_size;
        if (array_size == 0)array_size = 1;
        void* ppInd = mxMalloc(array_size * sizeof(size_t)); //working array of indexes for transformed pixels
        if (!ppInd) {
            throw("Sort_pixels_by_bins: memory allocation error for auxiliary array of indexes");
        }
        //---------------------------------------------------------------------------------------------

        switch (type_requested) {
        case Pix8IndIOut8: {
            double* const pPixelSorted = (double*)mxGetPr(plhs[Pixels_Sorted]);
            //
            sort_pixels_by_bins<double, int64_t, double>(pPixelSorted, nPixelsSorted, pPixelRange, pPix_blocks, pix_sizes,
                pIndex_blocks, index_sizes,
                pCellDens, distribution_size,
                reinterpret_cast<size_t*>(ppInd));
            break;
        }
        case Pix8IndDOut8: {
            double* const pPixelSorted = (double*)mxGetPr(plhs[Pixels_Sorted]);
            sort_pixels_by_bins<double, double, double>(pPixelSorted, nPixelsSorted, pPixelRange, pPix_blocks, pix_sizes,
                pIndex_blocks, index_sizes,
                pCellDens, distribution_size,
                reinterpret_cast<size_t*>(ppInd));
            break;
        }
        case Pix4IndIOut8: {
            double* const pPixelSorted = (double*)mxGetPr(plhs[Pixels_Sorted]);
            sort_pixels_by_bins<float, int64_t, double>(pPixelSorted, nPixelsSorted, pPixelRange, pPix_blocks, pix_sizes,
                pIndex_blocks, index_sizes,
                pCellDens, distribution_size,
                reinterpret_cast<size_t*>(ppInd));
            break;
        }
        case Pix4IndDOut8: {
            double* const pPixelSorted = (double*)mxGetPr(plhs[Pixels_Sorted]);
            //
            sort_pixels_by_bins<float, double, double>(pPixelSorted, nPixelsSorted, pPixelRange, pPix_blocks, pix_sizes,
                pIndex_blocks, index_sizes,
                pCellDens, distribution_size,
                reinterpret_cast<size_t*>(ppInd));
            break;
        }
        case Pix4IndIOut4: {
            float* const pPixelSorted = (float*)mxGetPr(plhs[Pixels_Sorted]);
            //
            sort_pixels_by_bins<float, int64_t, float>(pPixelSorted, nPixelsSorted, pPixelRange, pPix_blocks, pix_sizes,
                pIndex_blocks, index_sizes,
                pCellDens, distribution_size,
                reinterpret_cast<size_t*>(ppInd));
            break;
        }
        case Pix4IndDOut4: {
            float* const pPixelSorted = (float*)mxGetPr(plhs[Pixels_Sorted]);
            //
            sort_pixels_by_bins<float, double, float>(pPixelSorted, nPixelsSorted, pPixelRange, pPix_blocks, pix_sizes,
                pIndex_blocks, index_sizes,
                pCellDens, distribution_size,
                reinterpret_cast<size_t*>(ppInd));
            break;
        }
        case Pix4Ind4Out4: {
            float* const pPixelSorted = (float*)mxGetPr(plhs[Pixels_Sorted]);
            sort_pixels_by_bins<float, float, float>(pPixelSorted, nPixelsSorted, pPixelRange, pPix_blocks, pix_sizes,
                pIndex_blocks, index_sizes,
                pCellDens, distribution_size,
                reinterpret_cast<size_t*>(ppInd));
            break;
        }
        case Pix4Ind4Out8: {
            double* const pPixelSorted = (double*)mxGetPr(plhs[Pixels_Sorted]);

            sort_pixels_by_bins<float, float, double>(pPixelSorted, nPixelsSorted, pPixelRange, pPix_blocks, pix_sizes,
                pIndex_blocks, index_sizes,
                pCellDens, distribution_size,
                reinterpret_cast<size_t*>(ppInd));
            break;
        }
        case Pix8Ind4Out8: {
            double* const pPixelSorted = (double*)mxGetPr(plhs[Pixels_Sorted]);

            sort_pixels_by_bins <double, float, double >(pPixelSorted, nPixelsSorted, pPixelRange, pPix_blocks, pix_sizes,
                pIndex_blocks, index_sizes,
                pCellDens, distribution_size,
                reinterpret_cast<size_t*>(ppInd));
            break;
        }
        case ERROR:
            if (ppInd)
                mxFree(ppInd);
            throw("Sort_pixels_by_bins: Got unsupported combination of input / output types");
        case N_InputCases:
            if (ppInd)
                mxFree(ppInd);
            throw("Sort_pixels_by_bins: Got unsupported combination of input/output types");
        default:
            if (ppInd)
                mxFree(ppInd);
            throw("Sort_pixels_by_bins: Got unsupported combination of input / output types");
        }
        mxFree(ppInd);
    }
    catch (const char* err) {
        mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:runtime_error", err);
    }
    catch (...) {
        mexErrMsgIdAndTxt("HORACE:sort_pixels_by_bins_mex:runtime_error",
            "Sort_pixels_by_bins: unhandled exception in sort_pixels_by_bins procedure, location 3");
    }

}
