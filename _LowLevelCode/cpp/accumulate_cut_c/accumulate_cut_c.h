#ifndef H_ACCUMULATE_CUT
#define H_ACCUMULATE_CUT

#include "../CommonCode.h"

#define iRound(x) (int)floor((x) + 0.5)

enum program_settings
{
    Ignore_Nan,
    Ignore_Inf,
    Keep_pixels,
    N_Parallel_Processes,
    NbytesInPixel, //
    N_PROG_SETTINGS
};

template <class T>
bool isNaN(T val)
{
    volatile T buf = val;
    return (val != buf);
}

//static std::unique_ptr<omp_storage> pStorHolder;
/** Routine to calculate pixels data belonging to appropriate range */
template <class T>
mwSize accumulate_cut(double* s, double* e, double* npix,
    T const* const pixel_data, size_t data_size,
    mxLogical* ok, mxArray*& ix_final_pixIndex, double* actual_pix_range,
    double const* rot_ustep, double const* trans_bott_left, double ebin, double trans_elo, // transformation matrix
    double const* cut_range,
    const std::vector<mwSize>& grid_size, const std::vector<int>& iAxis, int nAxis,
    const std::vector<double>& progSettings)
{

    T Inf(0);
    double ebin_inv = (1 / ebin);
    bool ignore_something, ignote_all;

    //if we want to ignore nan and inf in the data
    bool ignore_nan(false);
    if (progSettings[Ignore_Nan] > FLT_EPSILON)
    {
        ignore_nan = true;
    }
    bool ignore_inf(false);
    if (progSettings[Ignore_Inf] > FLT_EPSILON)
    {
        ignore_inf = true;
    }
    ignore_something = ignore_nan | ignore_inf;
    ignote_all = ignore_nan & ignore_inf;
    if (ignore_inf)
    {
        Inf = static_cast<T>(mxGetInf());
    }

    int num_OMP_Threads(1);
    if (progSettings[N_Parallel_Processes] > 1)
    {
        num_OMP_Threads = (int)progSettings[N_Parallel_Processes];
    }
    bool keep_pixels(false);
    if (progSettings[Keep_pixels] > FLT_EPSILON)
    {
        keep_pixels = true;
    }

    bool transform_energy;

    //% Catch special (and common) case of energy being an integration axis to save calculations
    if (fabs(ebin - 1) < DBL_EPSILON && fabs(trans_elo) < DBL_EPSILON)
    {
        transform_energy = false;
    }
    else
    {
        transform_energy = true;
    }

    mwSize nPixel_retained = 0;

    size_t ds = data_size;
    if (ds == 0)
        ds = 1;
    mwSize* ind = (mwSize*)mxCalloc(ds, sizeof(mwSize)); //working array of indexes of transformed pixels
    if (!ind)
    {
        throw("accumulate_cut_c: Can not allocate memory for array of indexes\n");
    }

    //
    //0.25       2   79 indx = indx(:,pax); % Now keep only the plot axes with at least two bins
    // set up reduction axis ===>>>
    mwSize nDimX(0), nDimY(0), nDimZ(0), nDimE(0); // reduction dimensions; if 0, the dimension is reduced;
    mwSize nDimLength(1);
    for (int i = 0; i < nAxis; i++)
    {
        if (iAxis[i] == 1)
        {
            nDimX = nDimLength;
            nDimLength *= grid_size[0];
        }
        else if (iAxis[i] == 2)
        {
            nDimY = nDimLength;
            nDimLength *= grid_size[1];
        }
        else if (iAxis[i] == 3)
        {
            nDimZ = nDimLength;
            nDimLength *= grid_size[2];
        }
        else if (iAxis[i] == 4)
        {
            nDimE = nDimLength;
            nDimLength *= grid_size[3];
        }
    }
    //<<<==== end of set-up reduction axes
    size_t distribution_size = nDimLength;

    omp_set_num_threads(num_OMP_Threads);
    int PIXEL_data_width = pix_fields::PIX_WIDTH;

    std::vector<double> qe_min(4 * num_OMP_Threads, FLT_MAX);
    std::vector<double> qe_max(4 * num_OMP_Threads, -FLT_MAX);

    std::unique_ptr<omp_storage> pStorHolder(new omp_storage(num_OMP_Threads, distribution_size, s, e, npix));
    //if (!pStorHolder){
    //  pStorHolder.reset(new omp_storage(num_OMP_Threads, distribution_size, s, e, npix));
    //} else {
    //    pStorHolder->init_storage(num_OMP_Threads, distribution_size, s, e, npix);
    //}

    auto pStor = pStorHolder.get();

#pragma omp parallel default(none)                                                           \
    shared(rot_ustep, trans_bott_left, cut_range, ok, ind, qe_min, qe_max,                   \
           pStor)                                                                            \
        firstprivate(data_size, distribution_size, num_OMP_Threads,                          \
                     trans_elo, ebin_inv, Inf, PIXEL_data_width,                             \
                     ignote_all, ignore_nan, ignore_inf, ignore_something, transform_energy, \
                     nDimX, nDimY, nDimZ, nDimE,                                             \
                     s, e, npix)                                                             \
            reduction(+                                                                      \
                      : nPixel_retained)
    {
#pragma omp for
        for (long i = 0; i < data_size; i++)
        {
            mwSize j0 = i * PIXEL_data_width;

            // Check for the case when either data.s or data.e contain NaNs or Infs, but data.npix is not zero.
            // and handle according to options settings.
            ok[i] = false;
            if (ignore_something)
            {
                if (ignote_all)
                {
                    if (pixel_data[j0 + 7] == Inf || isNaN(pixel_data[j0 + 7]) ||
                        pixel_data[j0 + 8] == Inf || isNaN(pixel_data[j0 + 8]))
                        continue;
                }
                else if (ignore_nan)
                {
                    if (isNaN(pixel_data[j0 + 7]) || isNaN(pixel_data[j0 + 8]))
                        continue;
                }
                else if (ignore_inf)
                {
                    if (pixel_data[j0 + 7] == Inf || pixel_data[j0 + 8] == Inf)
                        continue;
                }
            }

            // Transform the coordinates u1-u4 into the new projection axes, if necessary
            //    indx=[(v(1:3,:)'-repmat(trans_bott_left',[size(v,2),1]))*rot_ustep',v(4,:)'];  % nx4 matrix
            double xt1 = double(pixel_data[j0]) - trans_bott_left[0];
            double yt1 = double(pixel_data[j0 + 1]) - trans_bott_left[1];
            double zt1 = double(pixel_data[j0 + 2]) - trans_bott_left[2];

            double Et;
            if (transform_energy)
            {
                //    indx(4)=[(v(4,:)'-trans_elo)*(1/ebin)];  % nx4 matrix
                Et = (double(pixel_data[j0 + 3]) - trans_elo) * ebin_inv;
            }
            else
            {
                //% Catch special (and common) case of energy being an integration axis to save calculations
                //  indx(4)=[(v(4,:)'];  % nx4 matrix
                Et = double(pixel_data[j0 + 3]);
            }

            //  ok = indx(:,1)>=cut_range(1,1) & indx(:,1)<=cut_range(2,1) & indx(:,2)>=cut_range(1,2) & indx(:,2)<=urange_step(2,2) & ...
            //       indx(:,3)>=cut_range(1,3) & indx(:,3)<=cut_range(2,3) & indx(:,4)>=cut_range(1,4) & indx(:,4)<=cut_range(2,4);
            if (Et < cut_range[6] || Et > cut_range[7])
                continue;
            double Ett = Et; // variables used to calculate indexes and evaluate min-max differ
            if (Ett == cut_range[7])
                Ett *= (1 - FLT_EPSILON);

            double xt = xt1 * rot_ustep[0] + yt1 * rot_ustep[3] + zt1 * rot_ustep[6];
            if (xt < cut_range[0] || xt > cut_range[1])
                continue;
            double xtt = xt; // variables used to calculate indexes and evaluate min-max differ
            if (xtt == cut_range[1])
                xtt *= (1 - FLT_EPSILON);

            double yt = xt1 * rot_ustep[1] + yt1 * rot_ustep[4] + zt1 * rot_ustep[7];
            if (yt < cut_range[2] || yt > cut_range[3])
                continue;
            double ytt = yt; // variables used to calculate indexes and evaluate min-max differ
            if (ytt == cut_range[3])
                ytt *= (1 - FLT_EPSILON);

            double zt = xt1 * rot_ustep[2] + yt1 * rot_ustep[5] + zt1 * rot_ustep[8];
            if (zt < cut_range[4] || zt > cut_range[5])
                continue;
            double ztt = zt; // variables used to calculate indexes and evaluate min-max differ
            if (ztt == cut_range[5])
                ztt *= (1 - FLT_EPSILON);

            nPixel_retained++;

            //     indx=indx(ok,:);    % get good indices (including integration axes and plot axes with only one bin)

            mwSize indX = (mwSize)floor(xtt - cut_range[0]);
            mwSize indY = (mwSize)floor(ytt - cut_range[2]);
            mwSize indZ = (mwSize)floor(ztt - cut_range[4]);
            mwSize indE = (mwSize)floor(Ett - cut_range[6]);

            mwSize il = indX * nDimX + indY * nDimY + indZ * nDimZ + indE * nDimE;
            // check for round-off errors; assure the errors are not bring pixel outside of the histogram
            // range
            if (il >= distribution_size)
                il = distribution_size - 1;
            ok[i] = true;
            ind[i] = il;
            // i0=nPixel_retained*OUT_PIXEL_DATA_WIDTH;    // transformed pixels;
            //
            //
            //    actual_pix_range = [min(actual_pix_range(1,:),min(indx,[],1));max(actual_pix_range(2,:),max(indx,[],1))];  % true range of data
            int n_thread = omp_get_thread_num();

            if (xt < qe_min[4 * n_thread + 0])
                qe_min[4 * n_thread + 0] = xt;
            if (xt > qe_max[4 * n_thread + 0])
                qe_max[4 * n_thread + 0] = xt;

            if (yt < qe_min[4 * n_thread + 1])
                qe_min[4 * n_thread + 1] = yt;
            if (yt > qe_max[4 * n_thread + 1])
                qe_max[4 * n_thread + 1] = yt;

            if (zt < qe_min[4 * n_thread + 2])
                qe_min[4 * n_thread + 2] = zt;
            if (zt > qe_max[4 * n_thread + 2])
                qe_max[4 * n_thread + 2] = zt;

            if (Et < qe_min[4 * n_thread + 3])
                qe_min[4 * n_thread + 3] = Et;
            if (Et > qe_max[4 * n_thread + 3])
                qe_max[4 * n_thread + 3] = Et;

            pStor->add_signal(double(pixel_data[j0 + 7]), double(pixel_data[j0 + 8]), n_thread, il);

        } // end for -- implicit barrier;
#pragma omp barrier
        if (pStor->is_mutlithreaded)
        {
#pragma omp for
            for (long i = 0; i < distribution_size; i++)
            {
                for (int i0 = 0; i0 < num_OMP_Threads; i0++)
                {
                    size_t indl = i0 * distribution_size + i;
                    s[i] += *(pStor->pSignal + indl);
                    e[i] += *(pStor->pError + indl);
                    npix[i] += *(pStor->pNpix + indl);
                }
            }
        }
    } // end parallel region

    pStorHolder.reset();
    // min-max value initialization
    for (int i = 0; i < 4; i++)
    {
        actual_pix_range[2 * i + 0] = std::numeric_limits<double>::max();
        actual_pix_range[2 * i + 1] = -actual_pix_range[2 * i + 0];
    }
    // min-max value collection
    for (int ii = 0; ii < num_OMP_Threads; ii++)
    {
        for (int ike = 0; ike < 4; ike++)
        {
            if (qe_min[4 * ii + ike] < actual_pix_range[2 * ike + 0])
                actual_pix_range[2 * ike + 0] = qe_min[4 * ii + ike];
            if (qe_max[4 * ii + ike] > actual_pix_range[2 * ike + 1])
                actual_pix_range[2 * ike + 1] = qe_max[4 * ii + ike];
        }
    }
#ifdef _DEBUG
    size_t ntot_pix(0);
    for (size_t i = 0; i < distribution_size; i++)
    {
        ntot_pix += size_t(npix[i]);
    }
    if (ntot_pix != nPixel_retained)
    {
        throw(" Multithreading error, number of pixels in array not equal to number of pixels retained");
    }
#endif
    //

    if (nPixel_retained == 0 || !keep_pixels)
    {
        ix_final_pixIndex = mxCreateNumericMatrix(0, 0, mxINT64_CLASS, mxREAL); // allocate empty matrix
    }
    else
    {
        ix_final_pixIndex = mxCreateNumericMatrix(nPixel_retained, 1, mxINT64_CLASS, mxREAL);
    }
    if (!ix_final_pixIndex)
    { // can not allocate memory for reduction;
        throw("accumulate_cut_c: Can not allocate memory for the indexes of the transformed pixels\n");
        return nPixel_retained;
    }

    uint64_t* pFin_pix = reinterpret_cast<uint64_t*>(mxGetPr(ix_final_pixIndex));
    if (nPixel_retained == 0)
    {
        mxFree(ind);
        return 0;
    }
    //
    // pixels indexes has to be ordered according to ok[i] as the data compressing will be done on the basis of ok[i]
    // but separately in another place
    // because of that, we have to compress indexes here using single thread
    if (keep_pixels)
    {
        mwSize ic(0);
        for (size_t i = 0; i < data_size; i++)
        {
            if (ok[i])
            {
                pFin_pix[ic] = ind[i] + 1; // +1 to be consistent with Matlab&Fortran indexing
                ic++;
            }
        }
    }
    mxFree(ind);
    return nPixel_retained;
};

#endif

