#pragma once
#include <string>
#include <map>
#include <functional>
#include "../CommonCode.h"

// use C-mutexes while binning the data
#define C_MUTEXES
// enumerate input arguments of the mex function
enum in_arg {
    coord,  // 3xnpix or 4xnpix dimensional array of pixels coordinates to bin
    npix,   // image array containing number of pixels contributing into each bin
    Signal, // image array containing signal. May be empty pointer
    Error,  // image array containing errors. May be empty pointer
    param_struct,  // other possible input parameters and data for the binning algorithm, combined into structure processed separately
    N_IN_Arguments
};

// enumerate output arguments of the mex function
enum out_arg {
    npix,   // pointer to modified npix array
    Signal, // pointer to modified signal array 
    Error,  // pointer to modified error array
    cell_out, // pointer to cellarray with other possible outputs
    N_OUT_Arguments
};

// enumerate possible input/output data types
// enumerate possible types of input pixel arguments
enum inTypes { 
    Coord4Pix4,
    Coord8Pix4,
    Coord8Pix8,
    Coord4Pix8
};
// enumerate operational modes bin pixels operates in
enum opModes {
    npix_only = 1, // calculate npix array only binning coordinates over 
    N_OP_Modes =10 // total number of modes code operates in
};

// structure describes all parameters used by binning procedure
struct BinningArg{
    opModes binMode;
    size_t n_dims; // number of dimensions
    std::vector<double> data_range; // range of the data to bin within
    std::vector<size_t> num_bins;   // number of bins in each non-unit dimension
    int num_threads;                // number of computational threads to use in binning loop
    // information about pixels coordinates to bin.
    mxClassID coord_type;           // type of input coordinate array (mxDouble or mxSingle)
    std::vector<int> coord_size;    // 2-element array describing sizes of coordinate array
    void const* pCoord;             // pointer to the start of the coordinate array
    //
    BinningArg() {};
};

/** Procedure calculates positions of the input pixels coordinates within specified
*   image box and various other values related to distributions of pixels over the image
*   bins, including signal per image box, error per image box and distribution of pixels
*   according to the image.
*/
template<class TC, class TP>
bool bin_pixels(double* npix, double* s, double* e,
    TC const* const coord,BinningArg const &bin_par)
{
    mwSize distribution_size, comb_size;
    // numbers of the pixels in grid
    distribution_size = grid_size[0] * grid_size[1] * grid_size[2] * grid_size[3];
    comb_size = distribution_size;
    // input pixel data and their shapes
    double* pixel_data = mxGetPr(pPixel_data);
    mwSize data_size = mxGetN(pPixel_data);
    mwSize nPixelDatas = mxGetM(pPixel_data);

    mwSize nPixel_retained(0), nCellOccupied(0);

    std::vector<char> ok(data_size);
    std::vector<mwSize> nGridCell(data_size);
    //  memory to sort pixels according to the grid bins
    std::vector<mwSize >  ppInd(distribution_size);
#ifdef C_MUTEXES
    std::vector<std::mutex> cell_cnt_mutex(distribution_size);
    /*std::vector<omp_lock_t> cell_cnt_mutex(distribution_size);
     * for (size_t i = 0; i < distribution_size; i++) {
     * omp_init_lock(&(cell_cnt_mutex[i]));
     * }*/
#endif

    bool place_pixels_in_old_array(false); // true does not works properly

    // temporary area for all sorted pixels
    mxArray* tPixelSorted;
    try
    {
        tPixelSorted = mxCreateDoubleMatrix(pix_fields::PIX_WIDTH, data_size, mxREAL);
    }
    catch (...)
    {
        tPixelSorted = NULL;
        throw("  Can not allocate memory for sorted pixels");
    }
    double* pPixelSorted = mxGetPr(tPixelSorted);
    double* pPixels(NULL);
    std::vector<size_t> pix_retained(num_threads, 0);


    omp_set_num_threads(num_threads);


    double  xBinR, yBinR, zBinR, eBinR;             // new bin sizes in four dimensions
    mwSize  nDimX(0), nDimY(0), nDimZ(0), nDimE(0); // reduction dimensions; if 0, the dimension is reduced;

    //       nel=[1,cumprod(grid_size)]; % Number of elements per unit step along each dimension
    mwSize      nDimLength(1);
    nDimX = nDimLength;    nDimLength *= grid_size[0];
    nDimY = nDimLength;    nDimLength *= grid_size[1];
    nDimZ = nDimLength;    nDimLength *= grid_size[2];
    nDimE = nDimLength;
    //
    xBinR = double(grid_size[0]) / (cut_range[1] - cut_range[0]);
    yBinR = double(grid_size[1]) / (cut_range[3] - cut_range[2]);
    zBinR = double(grid_size[2]) / (cut_range[5] - cut_range[4]);
    eBinR = double(grid_size[3]) / (cut_range[7] - cut_range[6]);

    std::unique_ptr<omp_storage> pStorHolder(new omp_storage(num_threads, distribution_size, s, e, npix));
    //if (!pStorHolder){
    //     pStorHolder.reset(new omp_storage(num_threads, distribution_size, s, e, npix));
    //} else {
    //    pStorHolder->init_storage(num_threads, distribution_size, s, e, npix);
    //}
    auto pStor = pStorHolder.get();



#ifdef OMP_VERSION_3
#pragma omp parallel default(none),shared( \
                      pixel_data, ok, nGridCell, pStor, ppInd, \
                      tPixelSorted,pPixelSorted,pPixels,PixelSorted,pix_retained,nPixel_retained,\
                      s, e, npix,comb_size)\
          firstprivate(num_threads,data_size,distribution_size,cut_range,\
                        nDimX,nDimY,nDimZ,nDimE,xBinR,yBinR,zBinR,eBinR)
#else
#ifdef C_MUTEXES
#pragma omp parallel default(none),shared(cell_cnt_mutex, \
                      pixel_data, ok, nGridCell, pStor, ppInd, \
                      tPixelSorted,pPixelSorted,pPixels,PixelSorted,pix_retained,nPixel_retained,\
                      s, e, npix,comb_size)\
          firstprivate(num_threads,data_size,distribution_size,cut_range,\
                        nDimX,nDimY,nDimZ,nDimE,xBinR,yBinR,zBinR,eBinR)
#else
#pragma omp parallel default(none),shared( \
                      pixel_data, ok, nGridCell, pStor, ppInd, \
                      tPixelSorted,pPixelSorted,pPixels,PixelSorted,pix_retained,nPixel_retained,\
                      s, e, npix,comb_size)\
          firstprivate(num_threads,data_size,distribution_size,cut_range,\
                        nDimX,nDimY,nDimZ,nDimE,xBinR,yBinR,zBinR,eBinR)
#endif //C_MUTEXES
#endif //OMP_VERSION_3
    {
#pragma omp for
        for (long i = 0; i < data_size; i++)
        {
            size_t i0 = i * PIX_WIDTH;

            double xt = pixel_data[i0 + u1];
            double yt = pixel_data[i0 + u2];
            double zt = pixel_data[i0 + u3];
            double Et = pixel_data[i0 + u4];

            //  ok = indx(:,1)>=cut_range(1,1) & indx(:,1)<=cut_range(2,1) & indx(:,2)>=cut_range(1,2) & indx(:,2)<=urange_step(2,2) & ...
            //       indx(:,3)>=cut_range(1,3) & indx(:,3)<=cut_range(2,3) & indx(:,4)>=cut_range(1,4) & indx(:,4)<=cut_range(2,4);
            ok[i] = false;
            if (xt < cut_range[0] || xt >= cut_range[1]) {
                if (xt == cut_range[1])xt *= (1. - FLT_EPSILON);
                else continue;
            }
            if (yt < cut_range[2] || yt >= cut_range[3]) {
                if (yt == cut_range[3])yt *= (1. - FLT_EPSILON);
                else  continue;
            }
            if (zt < cut_range[4] || zt >= cut_range[5]) {
                if (zt == cut_range[5])zt *= (1. - FLT_EPSILON);
                else continue;
            }
            if (Et<cut_range[6] || Et>cut_range[7]) {
                if (Et == cut_range[7])Et *= (1. - FLT_EPSILON);
                else continue;
            }


            //ibin(ok) = ibin(ok) + nel(id)*max(0,min((grid_size(id)-1),floor(grid_size(id)*((u(id,ok)-urange(1,id))/(urange(2,id)-urange(1,id))))));

            mwSize ix = (mwSize)floor((xt - cut_range[0]) * xBinR);
            mwSize iy = (mwSize)floor((yt - cut_range[2]) * yBinR);
            mwSize iz = (mwSize)floor((zt - cut_range[4]) * zBinR);
            mwSize ie = (mwSize)floor((Et - cut_range[6]) * eBinR);

            mwSize il = ix * nDimX + iy * nDimY + iz * nDimZ + ie * nDimE;
            //Avoid strange situation, when the indexes point behind the grid.
            //Should never happen but causes suspicions on some architectures
            if (il >= distribution_size)il = distribution_size - 1;

            ok[i] = true;
            nGridCell[i] = il;


            ////    sqw_data.s=reshape(accumarray(ibin,sqw_data.pix(8,:),[prod(grid_size),1]),grid_size);
            //#pragma omp atomic   // beware C index one less then Matlab; should use enum instead
            //            s[il]   +=pixel_data[i0+7];
            ////    sqw_data.e=reshape(accumarray(ibin,sqw_data.pix(9,:),[prod(grid_size),1]),grid_size);
            int n_thread = omp_get_thread_num();
            pStor->add_signal(pixel_data[i0 + 7], pixel_data[i0 + 8], n_thread, il);
            pix_retained[n_thread]++;

        } // end for -- implicit barrier;
    // combine all thread-calculated distributions together
        if (!pStor->is_mutlithreaded) {
            comb_size = 0;
        }

#pragma omp barrier
#pragma omp single
        {
            for (long i = 0; i < comb_size; i++) {
                pStor->combine_storage(s, e, npix, i);
            }
        }
        //    sqw_data.s=sqw_data.s./sqw_data.npix;       % normalize data
        //    sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalize variance
#pragma omp barrier
#pragma omp for
        for (long i = 0; i < distribution_size; i++) {
            double nPixSq = npix[i];
            if (nPixSq == 0)nPixSq = 1;
            s[i] /= nPixSq;
            nPixSq *= nPixSq;
            e[i] /= nPixSq;
            ppInd[i] = 0;
        }

        // sort pixels according to grid cells
        //    ix=find(ok);                % Pixel indices that are included in the grid
        //    [ibin,ind]=sort(ibin(ok));  % ordered bin numbers of the included pixels with index array into the original list of bin numbers of included pixels
        //    ix=ix(ind)';                % Indices of included pixels corresponding to ordered list; convert to column vector
        //    % Sort into increasing bin number and return indexing array
        //    % (treat only the contributing pixels: if the the grid is much smaller than the extent of the data this will be faster)
        //    sqw_data.pix=sqw_data.pix(:,ix);
#pragma omp barrier
#pragma omp single
        {
            ppInd[0] = 0;
            for (long i = 1; i < distribution_size; i++) {   // initiate the boundaries of the cells to keep pixels
                ppInd[i] = ppInd[i - 1] + (mwSize)npix[i - 1];
            };
            nPixel_retained = 0;
            for (int i0 = 0; i0 < num_threads; i0++) {
                nPixel_retained += pix_retained[i0];
            }

        }
        //size_t Block_Size = sizeof(*pixel_data)*pix_fields::PIX_WIDTH;


#pragma omp barrier
#if defined(OMP_VERSION_3) || defined(C_MUTEXES)
#pragma omp for
#else
#pragma omp single
#endif
        for (long j = 0; j < data_size; j++)
        {
            if (!ok[j])continue;

            size_t nCell = nGridCell[j];   // this is the index of a pixel in the grid cell
            size_t j0;
#ifdef OMP_VERSION_3
#pragma omp atomic capture
            j0 = ppInd[nCell]++; // each position in a grid cell corresponds to a pixel of the size PIX_WIDTH;
#else
#ifdef C_MUTEXES
            cell_cnt_mutex[nCell].lock();
            j0 = ppInd[nCell]++;
            cell_cnt_mutex[nCell].unlock();
#else
            j0 = ppInd[nCell]++;
#endif
#endif
            copy_pixels(pixel_data, j, pPixelSorted, j0);
        }
    }//end parallel
    {
        //----------------------------------------------------------------------------------
//#pragma omp barrier
//#pragma omp flush (nPixel_retained)

// where to place new pixels
        if (data_size == nPixel_retained) {
            //#pragma omp single
            PixelSorted = tPixelSorted;
        }
        else {
            //#pragma omp single // barrier exist, no other threads will enter region
            {
                try {
                    PixelSorted = mxCreateDoubleMatrix(pix_fields::PIX_WIDTH, nPixel_retained, mxREAL);
                }
                catch (...) {
                    PixelSorted = NULL;
                    throw("  Can not allocate memory for sorted pixels");
                }
                pPixels = mxGetPr(PixelSorted);
            }
            // copy pixels info from heap to Matlab controlled memory;
//#pragma omp barrier
//#pragma omp for
            for (long i = 0; i < nPixel_retained * pix_fields::PIX_WIDTH; i++) {
                pPixels[i] = pPixelSorted[i];
            }
            //#pragma omp barrier
            //#pragma omp single
            {
                if (tPixelSorted) {
                    mxDestroyArray(tPixelSorted);
                    tPixelSorted = nullptr;
                }
            }
        }//Else

    } // end parallel region

    // clear thread-related memory
    pStorHolder.reset();
    return place_pixels_in_old_array;
}

