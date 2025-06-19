#pragma once
#include "BinningArg.h"
#include "bin_pixels.h"
#include <algorithm>

// use C-mutexes while binning the data
//#define C_MUTEXES


// return true if input coordinates lie outside of the ranges specified as input
template <class TP>
bool inline out_of_ranges(TP const* const coord_ptr, long i, size_t COORD_STRIDE, const std::vector<double>& cut_range, std::vector<double>& qi)
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
// identify the image cell where the particular pixel belongs to
size_t inline pix_position(const std::vector<double>& qi, const std::vector<size_t>& pax,
    const std::vector<double>& cut_range, const std::vector<double>& bin_step,
    const std::vector<size_t>& bin_cell_range, const std::vector<size_t>& stride)
{
    size_t il(0);
    for (size_t j = 0; j < pax.size(); j++) {
        auto bin_idx = pax[j];
        auto cell_idx = (size_t)std::floor((qi[bin_idx] - cut_range[2 * bin_idx]) * bin_step[j]);
        if (cell_idx > bin_cell_range[j])
            cell_idx = bin_cell_range[j];
        il += cell_idx * stride[j];
    }
    return il;
};

/** Procedure calculates positions of the input pixels coordinates within specified
 *   image box and various other values related to distributions of pixels over the image
 *   bins, including signal per image box, error per image box and distribution of pixels
 *   according to the image.
 */
template <class TP>
size_t bin_pixels(double* const npix, double* const s, double* const e, BinningArg* const bin_par_ptr)
{
    // numbers of bins in the grid
    auto distribution_size = bin_par_ptr->n_grid_points();

    // what do we actually calculate
    auto opMode = bin_par_ptr->binMode;

    TP const* const coord_ptr = reinterpret_cast<TP*>(mxGetPr(bin_par_ptr->coord_ptr));
    TP const* pix_coord_ptr(nullptr);
    if (bin_par_ptr->all_pix_ptr) {
        pix_coord_ptr = reinterpret_cast<TP*>(mxGetPr(bin_par_ptr->all_pix_ptr));
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
    std::vector<size_t> bin_cell_range = bin_par_ptr->bin_cell_range;

    // initialize space for calculating pixel data ranges
    auto pix_range_ids = (bin_par_ptr->pix_data_range_ptr == nullptr) ? 0 : 2 * pix_flds::PIX_WIDTH;
    std::span<double> pix_ranges(mxGetPr(bin_par_ptr->pix_data_range_ptr), pix_range_ids);
    if (bin_par_ptr->binMode > opModes::sigerr_cell && pix_range_ids>0) { // higher modes process pixel ranges
        init_min_max_range_calc(pix_ranges, pix_flds::PIX_WIDTH);
    }
    bool check_pix_selection = bin_par_ptr->check_pix_selection && (pix_coord_ptr != nullptr);
    auto bin_mode = bin_par_ptr->binMode;

    long data_size = bin_par_ptr->n_data_points;
    switch (bin_mode) {
    case (opModes::npix_only): {
        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<TP>(coord_ptr, i, COORD_STRIDE, cut_range, qi))
                continue;
            nPixel_retained++;

            // calculate location of pixel within the image grid
            auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_range, stride);
            npix[il]++;
        }
        break;
    }
    case (opModes::sig_err): {
        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<TP>(coord_ptr, i, COORD_STRIDE, cut_range, qi))
                continue;
            // drop out already selected pixels, if requested
            size_t ip0 = i * PIX_STRIDE;
            if (check_pix_selection && pix_coord_ptr[ip0 + pix_flds::idet] < 0)
                continue;
            nPixel_retained++;

            // calculate location of pixel within the image grid
            auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_range, stride);
            // calculate npix accumulators
            npix[il]++;
            // calculate signal and error accumulators
            s[il] += (double)pix_coord_ptr[ip0 + pix_flds::iSign];
            e[il] += (double)pix_coord_ptr[ip0 + pix_flds::iErr];
        }
        break;
    }
    case (opModes::sigerr_cell): {
        std::vector<double*> accum_ptr(2);
        accum_ptr[0] = s;
        accum_ptr[1] = e;

        auto n_cells_to_bin = bin_par_ptr->n_Cells_to_bin;
        std::vector<const double*> cell_data_ptr(n_cells_to_bin,nullptr);

        // fill in cell_data_ptr with pointers to contents of cell data to bin
        for (auto i = 0; i < n_cells_to_bin; i++) {
            const mxArray* cell_array_ptr = mxGetCell(bin_par_ptr->all_pix_ptr, i);
            cell_data_ptr[i] = mxGetPr(cell_array_ptr);
        }

        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<TP>(coord_ptr, i, COORD_STRIDE, cut_range, qi))
                continue;
            nPixel_retained++;

            // calculate location of pixel within the image grid
            auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_range, stride);
            // calculate npix accumulators
            npix[il]++;
            // calculate signal and, if necessary error accumulators
            for (auto j = 0; j < n_cells_to_bin; j++) {
                auto acc_ptr = accum_ptr[j];
                auto data_ptr = cell_data_ptr[j];
                acc_ptr[il] += data_ptr[i];
            }
        }
        break;
    }
    case (opModes::sort_pix): {
        std::vector<size_t> pix_idx;
        pix_idx.swap(bin_par_ptr->pix_ok_bin_idx);
        for (long i = 0; i < data_size; i++) {
            // drop out coordinates outside of the binning range
            if (out_of_ranges<TP>(coord_ptr, i, COORD_STRIDE, cut_range, qi))
                continue;
            // drop out already selected pixels, if requested
            size_t ip0 = i * PIX_STRIDE;
            if (check_pix_selection && pix_coord_ptr[ip0 + pix_flds::idet] < 0)
                continue;
            nPixel_retained++;

            // calculate location of pixel within the image grid
            auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_range, stride);
            // calculate npix accumulators
            npix[il]++;
            // calculate signal and error accumulators
            s[il] += (double)pix_coord_ptr[ip0 + pix_flds::iSign];
            e[il] += (double)pix_coord_ptr[ip0 + pix_flds::iErr];
            pix_idx[nPixel_retained] = il;
        }

        bin_par_ptr->pix_ok_bin_idx.swap(pix_idx);
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
