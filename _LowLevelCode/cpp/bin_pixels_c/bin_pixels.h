#pragma once
#include "BinningArg.h"
#include "bin_pixels.h"
#include <algorithm>

// use C-mutexes while binning the data
// #define C_MUTEXES

// return true if input coordinates lie outside of the ranges specified as input
template <class SRC>
bool inline out_of_ranges(SRC const* const coord_ptr, long i, size_t COORD_STRIDE, const std::vector<double>& cut_range, std::vector<double>& qi)
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
/* identify 1D index of the image cell where the particular pixel should be moved
 * qi               -- 4-element array of pixels coordinates in target coordinate system
 * pax              -- 0 to 4 elements array defining projection axes and what dimensions out 4D image will be binned
 * cut_range        -- 8-element array of cut ranges (min_q1,max_q1,min_q2,max_q2.... ). Only minimal values are used here
 * bin_step         -- size(pax) array of bin steps in every binned direction
 * bin_cell_idx_range
 *                  -- size(pax) array of maximal allowed pixel indices in every binned direction. Safety measure to
 *                     avoid oveflow due to round-off errors.
 * stride           -- size(pax) array of indices strides in each binning direction (e.g. change in the position
 *                     of pixel in 1D representation of multidimensional array, if index in one direction changes by one
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
/* calculate pixels position in image array and update pixels accumulators using this position
 *  Inputs:
 * pix_coord_ptr    -- pointer to the array pixels coordinates
 * pix_in_pix_pos   -- position of the pixel in 2D pixel data array, repesented as 1D array with pixels coordinates changing firest
 * qi               -- 4-element array of pixels coordinates in target coordinate system
 * pax              -- 0 to 4 elements array defining projection axes
 * cut_range        -- 8-element array of cut ranges (min_q1,max_q1,min_q2,max_q2.... )
 * bin_step         -- size(pax) array of bin steps in every binned direction
 * bin_cell_idx_range
 *                  -- size(pax) array of maximal allowed pixel indices in every binned direction.
 * stride           -- size(pax) array of indices strides in each binning direction (e.g. change in the position
 *                     of pixel in 1D representation of multidimensional array, if index in one direction changes by one
 * Accumulators:
 * npix             -- number of pixels contributing into given cell of image
 * s                -- accumulated signal per image cell
 * e                -- accumulated error per image cell
 */
template <class SRC>
size_t inline add_pix_to_accumulators(const SRC* pix_coord_ptr, size_t pix_in_pix_pos,
    const std::vector<double>& qi, const std::vector<size_t>& pax,
    const std::vector<double>& cut_range, const std::vector<double>& bin_step,
    const std::vector<size_t>& bin_cell_idx_range, const std::vector<size_t>& stride,
    std::span<double>& npix, std::span<double>& s, std::span<double>& e)
{
    // calculate location of pixel within the image grid
    auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_idx_range, stride);
    // calculate npix accumulators
    npix[il]++;
    // calculate signal and error accumulators
    s[il] += (double)pix_coord_ptr[pix_in_pix_pos + pix_flds::iSign];
    e[il] += (double)pix_coord_ptr[pix_in_pix_pos + pix_flds::iErr];

    return il;
};
// copy selected pixels from oritinal array to the target array, containing only selected pixels
// pixels are not sorted and array of indices which correspond to pixels positions according to image is returned instead
template <class SRC, class TRG>
void inline copy_resiults_to_final_arrays(BinningArg* const bin_par_ptr, const SRC* const pix_coord_ptr,
    size_t data_size, size_t nPixel_retained, std::vector<mxInt64>& pix_ok_bin_idx)
{
    // allocate memory for pixels to retain.
    TRG* selected_pix_ptr(nullptr); // pointer to the actual data position.
    bin_par_ptr->pix_ok_ptr = allocate_pix_memory<TRG>(pix_flds::PIX_WIDTH, nPixel_retained, selected_pix_ptr);
    // allocated memory for pixel indices
    mxInt64* pix_img_idx_ptr(nullptr);
    bin_par_ptr->pix_img_idx_ptr = allocate_pix_memory<mxInt64>(nPixel_retained, 1, pix_img_idx_ptr);
    std::span<mxInt64> pix_img_idx(pix_img_idx_ptr, nPixel_retained);

    bool align_result = bin_par_ptr->alignment_matrix.size() == 9;

    // actually move pixels and copy indices the target array
    size_t targ_pix_pos(0);
    size_t targ_pix_array_pos(0);
    for (size_t i = 0; i < data_size; i++) {
        if (pix_ok_bin_idx[i] < 0) // drop pixels with have not been inculded above
            continue;

        size_t il = (size_t)pix_ok_bin_idx[i]; // numer of image cell pixel should go to
        pix_img_idx[targ_pix_pos] = il + 1; // MATLB indices start from 1 and these -- from 0

        if (align_result) {
            // align q-coordinates and copy all other pixel data into the location requested
            targ_pix_array_pos = align_and_copy_pixels<SRC, TRG>(bin_par_ptr->alignment_matrix, pix_coord_ptr, i, selected_pix_ptr, targ_pix_pos);
        } else {
            // copy all pixel data into the location requested
            targ_pix_array_pos = copy_pixels<SRC, TRG>(pix_coord_ptr, i, selected_pix_ptr, targ_pix_pos);
        }
        // search for unique run_id;
        bin_par_ptr->unique_runID.insert(uint32_t(selected_pix_ptr[targ_pix_array_pos + pix_flds::irun]));

        targ_pix_pos++; // move to the next pixel position within the target array
    }
}

/** Procedure calculates positions of the input pixels coordinates within specified
 *   image box and various other values related to distributions of pixels over the image
 *   bins, including signal per image box, error per image box and distribution of pixels
 *   according to the image. Template instantiacted on the basis of SRC (source type)
 *   and TRG (target type)
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
    if (bin_par_ptr->binMode > opModes::sigerr_cell && pix_range_ids > 0 && bin_par_ptr->binMode < opModes::siger_selected) { // higher modes process pixel ranges except
        pix_ranges = std::span<double>(mxGetPr(bin_par_ptr->pix_data_range_ptr), pix_range_ids);
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

            // calculate location of pixel within the image grid and add values of this pixels to the accumulators
            add_pix_to_accumulators<SRC>(pix_coord_ptr, ip0, qi, pax, cut_range, bin_step, bin_cell_idx_range, stride,
                npix, s, e);
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
    case (opModes::sort_and_uid): {
        std::vector<mxInt64> pix_ok_bin_idx;
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

            // calculate location of pixel within the image grid and add values of this pixels to the accumulators
            auto il = add_pix_to_accumulators<SRC>(pix_coord_ptr, ip0, qi, pax, cut_range, bin_step, bin_cell_idx_range, stride,
                npix, s, e);
            // store indices of contributing pixels
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
    case (opModes::nosort): {
        std::vector<mxInt64> pix_ok_bin_idx;
        pix_ok_bin_idx.swap(bin_par_ptr->pix_ok_bin_idx);

        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<SRC>(coord_ptr, i, COORD_STRIDE, cut_range, qi))
                continue;

            // drop out already selected pixels, if requested
            size_t ip0 = i * PIX_STRIDE;
            if (check_pix_selection && pix_coord_ptr[ip0 + pix_flds::idet] < 0)
                continue;
            nPixel_retained++;

            // calculate location of pixel within the image grid and add values of this pixels to the accumulators
            auto il = add_pix_to_accumulators<SRC>(pix_coord_ptr, ip0, qi, pax, cut_range, bin_step, bin_cell_idx_range, stride,
                npix, s, e);

            // store indices of contributing pixels
            pix_ok_bin_idx[i] = il;
            // calculate pix ranges
            calc_pix_ranges<SRC>(pix_ranges, pix_coord_ptr, PIX_STRIDE, i);
        }
        // allocate memory for pixels to retain.
        TRG* selected_pix_ptr(nullptr); // pointer to the actual data position.
        bin_par_ptr->pix_ok_ptr = allocate_pix_memory<TRG>(pix_flds::PIX_WIDTH, nPixel_retained, selected_pix_ptr);
        // allocated memory for pixel indices
        mxInt64 * pix_img_idx_ptr(nullptr);
        bin_par_ptr->pix_img_idx_ptr = allocate_pix_memory<mxInt64>(nPixel_retained, 1, pix_img_idx_ptr);
        std::span<mxInt64> pix_img_idx(pix_img_idx_ptr, nPixel_retained);
        copy_resiults_to_final_arrays<SRC, TRG>(bin_par_ptr, pix_coord_ptr,
            data_size, nPixel_retained, pix_ok_bin_idx);
        // swap memory of working arrays back to binning_arguments to retain it for the next call
        bin_par_ptr->pix_ok_bin_idx.swap(pix_ok_bin_idx);
        break;
    }
    case (opModes::nosort_sel):
    case (opModes::siger_selected): {
        auto return_selected_only = bin_par_ptr->binMode == opModes::siger_selected;
        std::vector<mxInt64> pix_ok_bin_idx;
        if (!return_selected_only) {
            pix_ok_bin_idx.swap(bin_par_ptr->pix_ok_bin_idx);
        }

        // Allocate memory for logical array of selected pixels
        mxLogical* is_pix_selected_ptr(nullptr);
        std::span<mxLogical> is_pix_selected;
        bin_par_ptr->is_pix_selected_ptr = allocate_pix_memory<mxLogical>(1, data_size, is_pix_selected_ptr);
        is_pix_selected = std::span<mxLogical>(is_pix_selected_ptr, data_size);

        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<SRC>(coord_ptr, i, COORD_STRIDE, cut_range, qi)) {
                is_pix_selected[i] = false;
                continue;
            } else {
                is_pix_selected[i] = true;
            }

            // drop out already selected pixels, if requested
            size_t ip0 = i * PIX_STRIDE;
            if (check_pix_selection && pix_coord_ptr[ip0 + pix_flds::idet] < 0) {
                is_pix_selected[i] = false;
                continue;
            }

            nPixel_retained++;

            // calculate location of pixel within the image grid and add values of this pixels to the accumulators
            auto il = add_pix_to_accumulators<SRC>(pix_coord_ptr, ip0, qi, pax, cut_range, bin_step, bin_cell_idx_range, stride,
                npix, s, e);
            if (!return_selected_only) {
                pix_ok_bin_idx[i] = il;
                // calculate pix ranges
                calc_pix_ranges<SRC>(pix_ranges, pix_coord_ptr, PIX_STRIDE, i);
            }
        }
        if (return_selected_only) {
            break;
        }
        copy_resiults_to_final_arrays<SRC, TRG>(bin_par_ptr, pix_coord_ptr,
            data_size, nPixel_retained, pix_ok_bin_idx);
        // swap memory of working arrays back to binning_arguments to retain it for the next call
        bin_par_ptr->pix_ok_bin_idx.swap(pix_ok_bin_idx);
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
