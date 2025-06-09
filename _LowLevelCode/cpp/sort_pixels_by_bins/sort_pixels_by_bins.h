#pragma once


#include <include/CommonCode.h>
#include <algorithm>
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

#define iRound(x)  (int)floor((x)+0.5)

InputOutputTypes process_types(bool float_pix, InputIndexesType index_type, bool double_out);

//
template<class T, class N, class K>
void sort_pixels_by_bins( K * const pPixelSorted, size_t nPixelsSorted, double *const pPixRange,
    std::vector<const void *> &PixelData, std::vector<size_t> &NPixels,
    std::vector<const void *> &PixelIndexes, std::vector<size_t> NIndexes,
    double const *const pCellDens, size_t distribution_size,
    size_t *const ppInd) {


    ppInd[0] = 0;
    for (size_t i = 1; i < distribution_size; i++) {   // calculate the ranges of the cell arrays
        ppInd[i] = ppInd[i - 1] + (size_t)pCellDens[i - 1]; // the next cell starts from the the previous one
    };                                      // plus the number of pixels in the previous cell
    if (ppInd[distribution_size - 1] + (size_t)pCellDens[distribution_size - 1] != nPixelsSorted) {
        throw("Sort_pixels_by_bins: pixels data and their cell distributions are inconsistent ");
    }
    bool calc_pix_range(false);
    if (pPixRange) {
        calc_pix_range = true;
        for (size_t i = 0; i < pix_fields::PIX_WIDTH; i++) {
            pPixRange[2 * i]     =  std::numeric_limits<double>::max();
            pPixRange[2 * i + 1] = -std::numeric_limits<double>::max();
        }
    }


    //#pragma omp parallel
    for(size_t nblock=0; nblock < PixelIndexes.size();nblock++)
    {
        size_t nBlockInd = NIndexes[nblock];
        const N* pCellInd = reinterpret_cast<const N*>(PixelIndexes[nblock]);
        if (pCellInd == nullptr)continue;

        const T* pPixData= reinterpret_cast<const T*>(PixelData[nblock]);
        if (pPixData == nullptr)continue;

        for (size_t j = 0; j < nBlockInd ; j++) {    // sort pixels according to cells
            size_t i0 = j*pix_fields::PIX_WIDTH;
            size_t ind = (size_t)(pCellInd[j] - 1); // -1 as Matlab arrays start from one;
            size_t jBase = ppInd[ind] * pix_fields::PIX_WIDTH;
            ppInd[ind]++;
            if (calc_pix_range) {
                for (size_t i = 0; i < pix_fields::PIX_WIDTH; i++) {
                    double pix_val = static_cast<double>(pPixData[i0 + i]);
                    pPixRange[2 * i]     = std::min(pPixRange[2 * i], pix_val);
                    pPixRange[2 * i + 1] = std::max(pPixRange[2 * i + 1], pix_val);
                }
            }

            for (size_t i = 0; i < pix_fields::PIX_WIDTH; i++) {  // copy all pixel data into the location requested
                pPixelSorted[jBase + i] = static_cast<K>(pPixData[i0 + i]);
            }
        }
    }


}
