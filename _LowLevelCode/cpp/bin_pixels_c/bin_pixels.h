#pragma once
#include "BinningArg.h"
#include "bin_pixels.h"

// use C-mutexes while binning the data
#define C_MUTEXES

/** Procedure calculates positions of the input pixels coordinates within specified
 *   image box and various other values related to distributions of pixels over the image
 *   bins, including signal per image box, error per image box and distribution of pixels
 *   according to the image.
 */
template <class TP>
size_t bin_pixels(double* const npix, double* const s, double* const e, BinningArg* const bin_par)
{
    // numbers of bins in the grid
    auto distribution_size = bin_par->n_grid_points();

    // what do we actually calculate
    auto opMode = bin_par->binMode;

    auto coord_ptr = mxGetPr(bin_par->coord_ptr);
    // if (bin_par.all_pix_ptr) {  // -----------------> this is aProjection.bin_pixels mode
    //     coord_ptr = mxGetPr(bin_par.all_pix_ptr);
    // }
    auto COORD_STRIDE = bin_par->in_coord_width;
    auto PIX_STRIDE = bin_par->in_pix_width;


    size_t nPixel_retained(0), nCellOccupied(0);
    /*
    #ifdef C_MUTEXES
        std::vector<std::mutex> cell_cnt_mutex(distribution_size);
        /*std::vector<omp_lock_t> cell_cnt_mutex(distribution_size);
         * for (size_t i = 0; i < distribution_size; i++) {
         * omp_init_lock(&(cell_cnt_mutex[i]));
         * }*/
    // #endif

    // std::vector<size_t> pix_retained(num_threads, 0);

    // omp_set_num_threads(num_threads);

    //
    // std::unique_ptr<omp_storage> pStorHolder(new omp_storage(num_threads, distribution_size, s, e, npix));
    // if (!pStorHolder){
    //     pStorHolder.reset(new omp_storage(num_threads, distribution_size, s, e, npix));
    //} else {
    //    pStorHolder->init_storage(num_threads, distribution_size, s, e, npix);
    //}
    // auto pStor = pStorHolder.get();

    std::vector<double> qi(COORD_STRIDE);
    std::vector<double> cut_range(bin_par->data_range.begin(), bin_par->data_range.end());
    std::vector<double> bin_step(bin_par->bin_step.begin(), bin_par->bin_step.end());
    std::vector<size_t> pax(bin_par->pax.begin(), bin_par->pax.end()); // projection axis
    std::vector<size_t> stride(bin_par->stride.begin(), bin_par->stride.end());
    std::vector<size_t> bin_cell_range(bin_par->bin_cell_range.begin(), bin_par->bin_cell_range.end());

    long data_size = bin_par->n_data_points;

    for (long i = 0; i < data_size; i++) {
        // drop out coordinates outside of the binning range
        size_t i0 = i * PIX_STRIDE;
        for (size_t upix = 0; upix < COORD_STRIDE; upix++) {
            qi[upix] = double(coord_ptr[i0 + upix]);
            if (qi[upix] < cut_range[2 * upix] || qi[upix] > cut_range[2 * upix + 1])
                continue;
        }
        // identify the indices of the image cell, pixel belongs to
        size_t il(0);
        for (size_t j = 0; j < pax.size(); j++) {
            auto bin_idx = pax[j];
            auto cell_idx = (size_t)std::floor((qi[bin_idx] - cut_range[2 * bin_idx]) * bin_step[j]);
            if (cell_idx > bin_cell_range[j])
                cell_idx = bin_cell_range[j];
            il += cell_idx * stride[j];
        }
        nPixel_retained++;
        npix[il]++;
        //            ok[i] = true;
        //            nGridCell[i] = il;

        ////    sqw_data.s=reshape(accumarray(ibin,sqw_data.pix(8,:),[prod(grid_size),1]),grid_size);
        // #pragma omp atomic   // beware C index one less then Matlab; should use enum instead
        //             s[il]   +=pixel_data[i0+7];
        ////    sqw_data.e=reshape(accumarray(ibin,sqw_data.pix(9,:),[prod(grid_size),1]),grid_size);
        // int n_thread = omp_get_thread_num();
        // pStor->add_signal(pixel_data[i0 + 7], pixel_data[i0 + 8], n_thread, il);
        // pix_retained[n_thread]++;

    } // end for -- implicit barrier;
    // combine all thread-calculated distributions together
    //        //if (!pStor->is_mutlithreaded) {
    //            comb_size = 0;
    //        //}
    //
    // #pragma omp barrier
    // #pragma omp single
    //        {
    //            for (long i = 0; i < comb_size; i++) {
    //                pStor->combine_storage(s, e, npix, i);
    //            }
    //        }
    //        //    sqw_data.s=sqw_data.s./sqw_data.npix;       % normalize data
    //        //    sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalize variance
    // #pragma omp barrier
    // #pragma omp for
    //        for (long i = 0; i < distribution_size; i++) {
    //            double nPixSq = npix[i];
    //            if (nPixSq == 0)nPixSq = 1;
    //            s[i] /= nPixSq;
    //            nPixSq *= nPixSq;
    //            e[i] /= nPixSq;
    //            ppInd[i] = 0;
    //        }
    //
    // sort pixels according to grid cells
    //    ix=find(ok);                % Pixel indices that are included in the grid
    //    [ibin,ind]=sort(ibin(ok));  % ordered bin numbers of the included pixels with index array into the original list of bin numbers of included pixels
    //    ix=ix(ind)';                % Indices of included pixels corresponding to ordered list; convert to column vector
    //    % Sort into increasing bin number and return indexing array
    //    % (treat only the contributing pixels: if the the grid is much smaller than the extent of the data this will be faster)
    //        //    sqw_data.pix=sqw_data.pix(:,ix);
    // #pragma omp barrier
    // #pragma omp single
    //        {
    //            ppInd[0] = 0;
    //            for (long i = 1; i < distribution_size; i++) {   // initiate the boundaries of the cells to keep pixels
    //                ppInd[i] = ppInd[i - 1] + (mwSize)npix[i - 1];
    //            };
    //            nPixel_retained = 0;
    //            for (int i0 = 0; i0 < num_threads; i0++) {
    //                nPixel_retained += pix_retained[i0];
    //            }
    //
    //        }
    //        //size_t Block_Size = sizeof(*pixel_data)*pix_fields::PIX_WIDTH;
    //
    //
    // #pragma omp barrier
    // #if defined(OMP_VERSION_3) || defined(C_MUTEXES)
    // #pragma omp for
    // #else
    // #pragma omp single
    // #endif
    //        for (long j = 0; j < data_size; j++)
    //        {
    //            if (!ok[j])continue;
    //
    //            size_t nCell = nGridCell[j];   // this is the index of a pixel in the grid cell
    //            size_t j0;
    // #ifdef OMP_VERSION_3
    // #pragma omp atomic capture
    //            j0 = ppInd[nCell]++; // each position in a grid cell corresponds to a pixel of the size PIX_WIDTH;
    // #else
    // #ifdef C_MUTEXES
    //            cell_cnt_mutex[nCell].lock();
    //            j0 = ppInd[nCell]++;
    //            cell_cnt_mutex[nCell].unlock();
    // #else
    //            j0 = ppInd[nCell]++;
    // #endif
    // #endif
    //            copy_pixels(pixel_data, j, pPixelSorted, j0);
    //        }
    //    }//end parallel
    //    {
    //        //----------------------------------------------------------------------------------
    ////#pragma omp barrier
    ////#pragma omp flush (nPixel_retained)
    //
    //// where to place new pixels
    //        if (data_size == nPixel_retained) {
    //            //#pragma omp single
    //            PixelSorted = tPixelSorted;
    //        }
    //        else {
    //            //#pragma omp single // barrier exist, no other threads will enter region
    //            {
    //                try {
    //                    PixelSorted = mxCreateDoubleMatrix(pix_fields::PIX_WIDTH, nPixel_retained, mxREAL);
    //                }
    //                catch (...) {
    //                    PixelSorted = NULL;
    //                    throw("  Can not allocate memory for sorted pixels");
    //                }
    //                pPixels = mxGetPr(PixelSorted);
    //            }
    //            // copy pixels info from heap to Matlab controlled memory;
    ////#pragma omp barrier
    ////#pragma omp for
    //            for (long i = 0; i < nPixel_retained * pix_fields::PIX_WIDTH; i++) {
    //                pPixels[i] = pPixelSorted[i];
    //            }
    //            //#pragma omp barrier
    //            //#pragma omp single
    //            {
    //                if (tPixelSorted) {
    //                    mxDestroyArray(tPixelSorted);
    //                    tPixelSorted = nullptr;
    //                }
    //            }
    //        }//Else

    //    } // end parallel region

    return nPixel_retained;
}
