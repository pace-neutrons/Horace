#pragma once
#include "BinningArg.h"
#include "bin_pixels.h"
#include <algorithm>

// use C-mutexes while binning the data
#define C_MUTEXES

/* Initialize pixel ranges for calculating correct range.
 *  This means assigning to min/max holders values which are completely invalid, namely
 *  minima equal to maximal double value and maxima equal to minimal double value */
std::vector<double> inline init_min_max_range_calc(BinningArg const* const bin_par)
{
    std::vector<double> pix_ranges;
    pix_ranges.resize(2 * bin_par->in_pix_width);
    auto max_range = std::numeric_limits<double>::max();
    auto min_range = -max_range;
    for (size_t i = 0; i < bin_par->in_pix_width; i++) {
        pix_ranges[2 * i] = max_range;
        pix_ranges[2 * i + 1] = min_range;
    }
    return pix_ranges;
};
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
// identify range of all pixel coordinates
template <class TP>
void inline pix_range(std::vector<double>& pix_ranges, TP const* const pix_coord_ptr, size_t ip0)
{
    for (size_t j = 0; j < pix_flds::PIX_WIDTH; j++) {
        pix_ranges[2 * j] = std::min(pix_ranges[2 * j], (double)pix_coord_ptr[ip0 + j]);
        pix_ranges[2 * j + 1] = std::max(pix_ranges[2 * j + 1], (double)pix_coord_ptr[ip0 + j]);
    }
}

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

    size_t nPixel_retained(0), nCellOccupied(0);

    std::vector<double> qi(COORD_STRIDE);
    std::vector<double> cut_range = bin_par_ptr->data_range;
    std::vector<double> bin_step = bin_par_ptr->bin_step;
    std::vector<size_t> pax = bin_par_ptr->pax; // projection axis
    std::vector<size_t> stride = bin_par_ptr->stride;
    std::vector<size_t> bin_cell_range = bin_par_ptr->bin_cell_range;

    std::vector<double> pix_ranges;
    if (bin_par_ptr->binMode > opModes::sig_err) { // higher modes process pixel ranges
        pix_ranges = init_min_max_range_calc(bin_par_ptr);
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

            // calculate location of pixel within 
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

            auto il = pix_position(qi, pax, cut_range, bin_step, bin_cell_range, stride);
            npix[il]++;
            // calculate signal and error accumulators
            s[il] += (double)pix_coord_ptr[ip0 + pix_flds::iSign];
            e[il] += (double)pix_coord_ptr[ip0 + pix_flds::iErr];
        }
        break;
    }
    default: {
        std::stringstream buf;
        buf << "Binning mode: " << (short)bin_mode << " is not yet implemented";
        mexErrMsgIdAndTxt("HORACE:bin_pixels_c:not_implemented",
            buf.str().c_str());
    }
    }

    bin_par_ptr->pix_data_range = pix_ranges;
    return nPixel_retained;
}
