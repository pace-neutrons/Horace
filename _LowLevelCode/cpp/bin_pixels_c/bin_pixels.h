#pragma once
#include "BinningArg.h"
#include <algorithm>

// use C-mutexes while binning the data
// #define C_MUTEXES

/**  return true if input coordinates lie outside of the ranges specified as input
* 
*    Template can be instancitated for ang input numerical types convertible to double
* Inputs:
* coord_ptr   --  pointer to 2-Dimensional array of pixel coordinates allocated
*                 as 1-Dimensional FORTRAN array of COORD_STRIDE*Num_pixels size.
*                 where pixels coordinates are changed along first direction.
* i           --  second index of the pixel array, indicating number of pixel to pick up
*                 from pixels array
* COORD_STRIDE -- size of the first dimension of the pixels array
* cut_range    --  2*COORD_STRIDE array of pixel ranges to check. The ranges are
*                  arranged in 2-Dimensional array with FORTRAN allocation in the form:
*                  [q1_min,q1_max,q2_min,q2_max,... q_COORD_STRIDE_min,q_COORD_STRIDE_max]
* qi           --  Outuput vector of input q-coordinates converted in double
                   if all input coordinates are in range. Undefined if they are not
* Returns:
   true if all input coordinates are in range and false otherwise.
 */
template <class TRG>
bool inline out_of_ranges(TRG const* const coord_ptr, long i, size_t COORD_STRIDE, const std::vector<double>& cut_range, std::vector<double>& qi)
{
    size_t ic0 = i * COORD_STRIDE;
    for (size_t upix = 0; upix < COORD_STRIDE; upix++) {
        qi[upix] = double(coord_ptr[ic0 + upix]);
        if (qi[upix] < cut_range[2 * upix] || qi[upix] > cut_range[2 * upix + 1]) {
            return true;
        }
    }
    return false;
};
/** identifies the image cell where the particular pixel belongs to
* Inputs:
* qi       -- 1-dimensional vector of pixel coordinates to process
* pax      -- 1-to-4 elements vector of pixel indices accounted in binning. Indicates 
*             numbers of pixel coordinates from qi array to include in the binning.
*             I.e. if pax.size()==1 only one coordinates needs to be binned or if
*             pax.size()==4, all four qi coordinates have to be binned in 4-dimensional array
* cut_range -- 6 or 8-elements array defining ranges allowed for pixels. The same as cut_range
*              provided in out_of_range routine above.
* bin_step  -- 6 or 8-elements array defining bin step sizes e.g. (cut_range(2*n+1)-cut_range(2*n))/bin_cell_idx_range(n)
*              where n is the number of pixel coordinate to bin.
* bin_cell_idx_range
*           -- number of bins in each binned direction.
* stride    -- 1-to-4 element's vector which describes 1-D allocation of multidimensional array
*              i.e. if one have 1D arry, stride has 1 element and contains 1.
*              For 3-dimensional array of size 9x10x11, stride == [1,9,9*10]
*              For 4-dimensional array of size 9x10x11*12, stride == [1,9,9*10,9*10*11]
* Returns:
* index of pixel in input multidimensional array.
*/
size_t inline pix_position(const std::vector<double>& qi, const std::vector<size_t>& pax,
    const std::vector<double>& cut_range, const std::vector<double>& bin_step,
    const std::vector<size_t>& bin_cell_idx_range, const std::vector<size_t>& stride)
{
    size_t il(0);
    for (size_t j = 0; j < pax.size(); j++) {
        auto bin_idx = pax[j];
        auto cell_idx = (size_t)std::floor((qi[bin_idx] - cut_range[2 * bin_idx]) * bin_step[j]);
        if (cell_idx > bin_cell_idx_range[j])
            cell_idx = bin_cell_idx_range[j];
        il += cell_idx * stride[j];
    }
    return il;
};

/** Procedure calculates positions of the input pixels coordinates within specified
 *   image box and various other values related to distributions of pixels over the image
 *   bins, including signal per image box, error per image box and distribution of pixels
 *   according to the image. Template instantiacted on the basis of SRC (numerical source type convertable to double)
 *   and TRG (numerical target type convertible to double)
 * Results:
 * npix        -- 1D representation of multidimensional array of pixel distributions over bins
 * s           -- 1D representation of multidimensional array of signal in bins
 * err         -- 1D representation of multidimensional array of error in bins
 * Input-Output parameter:
 * bin_par_ptr -- constant pointer to BinningArg class, containing input parameters which describe binning
 *                and output values calculated in some binning modes.
 */
template <class SRC, class TRG>
size_t bin_pixels(std::span<double>& npix, std::span<double>& s, std::span<double>& e, BinningArg* const bin_par_ptr)
{
    // numbers of bins in the grid
    auto distribution_size = bin_par_ptr->n_grid_points();

    // what do we actually calculate
    auto opMode = bin_par_ptr->binMode;

    SRC const* const coord_ptr = reinterpret_cast<SRC*>(mxGetPr(bin_par_ptr->coord_ptr));
    SRC const* pix_coord_ptr(nullptr);
    if (bin_par_ptr->all_pix_ptr) {
        pix_coord_ptr = reinterpret_cast<SRC*>(mxGetPr(bin_par_ptr->all_pix_ptr));
    }
    auto COORD_STRIDE = bin_par_ptr->in_coord_width;
    auto PIX_STRIDE = bin_par_ptr->in_pix_width;

    // internal loop variables (firstprivate)
    size_t nPixel_retained(0), nCellOccupied(0);

    std::vector<double> qi(COORD_STRIDE);
    std::vector<double> cut_range = bin_par_ptr->data_range;
    std::vector<double> bin_step = bin_par_ptr->bin_step;
    std::vector<size_t> pax = bin_par_ptr->pax; // projection axis
    std::vector<size_t> stride = bin_par_ptr->stride;
    std::vector<size_t> bin_cell_idx_range = bin_par_ptr->bin_cell_idx_range;

    // initialize space for calculating pixel data ranges if necessary
    std::span<double> pix_ranges;
    auto pix_range_ids = (bin_par_ptr->pix_data_range_ptr == nullptr) ? 0 : 2 * pix_flds::PIX_WIDTH;
    if (bin_par_ptr->binMode > opModes::sigerr_cell && pix_range_ids > 0) { // higher modes process pixel ranges
        pix_ranges  = std::span<double>(mxGetPr(bin_par_ptr->pix_data_range_ptr), pix_range_ids);
        init_min_max_range_calc(pix_ranges, pix_flds::PIX_WIDTH);
    }
    bool check_pix_selection = bin_par_ptr->check_pix_selection && (pix_coord_ptr != nullptr);
    auto bin_mode = bin_par_ptr->binMode;

    long data_size = bin_par_ptr->n_data_points;
    switch (bin_mode) {
    case (opModes::npix_only): {
        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<SRC>(coord_ptr, i, COORD_STRIDE, cut_range, qi))
                continue;
            nPixel_retained++;

            // calculate location of pixel within the image grid
            auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_idx_range, stride);
            npix[il]++;
        }
        break;
    }
    case (opModes::sig_err): {
        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<SRC>(coord_ptr, i, COORD_STRIDE, cut_range, qi))
                continue;
            // drop out already selected pixels, if requested
            size_t ip0 = i * PIX_STRIDE;
            if (check_pix_selection && pix_coord_ptr[ip0 + pix_flds::idet] < 0)
                continue;
            nPixel_retained++;

            // calculate location of pixel within the image grid
            auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_idx_range, stride);
            // calculate npix accumulators
            npix[il]++;
            // calculate signal and error accumulators
            s[il] += (double)pix_coord_ptr[ip0 + pix_flds::iSign];
            e[il] += (double)pix_coord_ptr[ip0 + pix_flds::iErr];
        }
        break;
    }
    case (opModes::sigerr_cell): {
        std::vector<double*> accum_ptr(3);
        accum_ptr[0] = s.data();
        accum_ptr[1] = e.data();
        accum_ptr[2] = npix.data();
        auto n_cells_to_bin = bin_par_ptr->n_Cells_to_bin;
        bool npix_acc_separate = n_cells_to_bin < 3; // values for npix accumulators may be provided in separate array
        // if they are not, calculate this value anyway
        std::vector<const double*> cell_data_ptr(n_cells_to_bin, nullptr);

        // fill in cell_data_ptr with pointers to contents of cell data to bin
        for (auto i = 0; i < n_cells_to_bin; i++) {
            const mxArray* cell_array_ptr = mxGetCell(bin_par_ptr->all_pix_ptr, i);
            cell_data_ptr[i] = mxGetPr(cell_array_ptr);
        }

        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<SRC>(coord_ptr, i, COORD_STRIDE, cut_range, qi))
                continue;
            nPixel_retained++;

            // calculate location of pixel within the image grid
            auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_idx_range, stride);

            if (npix_acc_separate) {
                // calculate npix accumulators separately if their value is not provided as input
                npix[il]++;
            }

            // calculate signal and, if necessary error accumulators
            for (auto j = 0; j < n_cells_to_bin; j++) {
                auto acc_ptr = accum_ptr[j];
                auto data_ptr = cell_data_ptr[j];
                acc_ptr[il] += data_ptr[i];
            }
        }
        break;
    }
    case (opModes::sort_pix):
    case (opModes::sort_and_uid):
    {
        std::vector<long> pix_ok_bin_idx;
        pix_ok_bin_idx.swap(bin_par_ptr->pix_ok_bin_idx);
        std::vector<size_t> npix1;
        npix1.swap(bin_par_ptr->npix1);
        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<SRC>(coord_ptr, i, COORD_STRIDE, cut_range, qi))
                continue;
            // drop out already selected pixels, if requested
            size_t ip0 = i * PIX_STRIDE;
            if (check_pix_selection && pix_coord_ptr[ip0 + pix_flds::idet] < 0)
                continue;
            nPixel_retained++;

            // calculate location of pixel within the image grid
            auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_idx_range, stride);
            // calculate npix accumulators for sinle page of pixels
            npix1[il]++;
            // calculate signal and error accumulators
            s[il] += (double)pix_coord_ptr[ip0 + pix_flds::iSign];
            e[il] += (double)pix_coord_ptr[ip0 + pix_flds::iErr];
            pix_ok_bin_idx[i] = il;
            // calculate pix ranges
            calc_pix_ranges<SRC>(pix_ranges, pix_coord_ptr, PIX_STRIDE, i);
        }
        // allocate memory for pixels to retain.
        TRG* sorted_pix_ptr(nullptr); // pointer to the actual data position.
        bin_par_ptr->pix_ok_ptr = allocate_pix_memory<TRG>(pix_flds::PIX_WIDTH, nPixel_retained, sorted_pix_ptr);
        // calculate ranges of cells to place pixels
        std::vector<size_t> bin_start;
        bin_start.swap(bin_par_ptr->npix_bin_start);
        bin_start[0] = 0;
        npix[0] += npix1[0];
        if (distribution_size > 1) {
            for (size_t i = 1; i < distribution_size; i++) {
                bin_start[i] = bin_start[i - 1] + npix1[i - 1]; // range of cell to place pixels
                npix[i] += npix1[i]; // increase multicall accumulators
            }
        }
        bool align_result = bin_par_ptr->alignment_matrix.size() == 9;
        size_t targ_pix_pos(0);
        bool keep_unique_id = bin_par_ptr->binMode == opModes::sort_and_uid;
        // actually sort pixels and copy selected pixels into proper locations within the target array
        for (size_t i = 0; i < data_size; i++) {
            if (pix_ok_bin_idx[i] < 0) // drop pixels with have not been inculded above
                continue;

            size_t il = (size_t)pix_ok_bin_idx[i]; // number of cell pixel should go to
            auto cell_pix_ind = bin_start[il]++; // pixel position within the array defined by cell
            if (align_result) {
                // align q-coordinates and copy all other pixel data into the location requested
                targ_pix_pos = align_and_copy_pixels<SRC, TRG>(bin_par_ptr->alignment_matrix, pix_coord_ptr, i, sorted_pix_ptr, cell_pix_ind); 
            } else {
                targ_pix_pos = copy_pixels<SRC, TRG>(pix_coord_ptr, i, sorted_pix_ptr, cell_pix_ind); // copy all pixel data into the location requested
            }
            if (keep_unique_id) {
                bin_par_ptr->unique_runID.insert(uint32_t(sorted_pix_ptr[targ_pix_pos + pix_flds::irun]));
            }
        }
        // swap memory of working arrays back to binning_arguments to retain it for the next call
        bin_par_ptr->pix_ok_bin_idx.swap(pix_ok_bin_idx);
        bin_par_ptr->npix_bin_start.swap(bin_start);
        bin_par_ptr->npix1.swap(npix1);
        break;
    }
    default: {
        std::stringstream buf;
        buf << "Binning mode: " << (short)bin_mode << " is not yet implemented";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:not_implemented",
            buf.str().c_str());
    }
    }

    return nPixel_retained;
}
