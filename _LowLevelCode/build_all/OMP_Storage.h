#ifndef H_OMP_STORAGE
#define H_OMP_STORAGE

//
// $Revision::      $ ($Date::                                              $)" 
//



#include <limits>
//
#include <mex.h>
#include <matrix.h>
#include <vector>

#ifdef __GNUC__
#   if __GNUC__ < 4 || (__GNUC__ == 4)&&(__GNUC_MINOR__ < 2)
// then the compiler does not understand OpenMP functions, let's define them
void omp_set_num_threads(int nThreads) {};
#define omp_get_num_threads() 1
#define omp_get_max_threads() 1
#define omp_get_thread_num()  0
#else
#include <omp.h>
#   endif
# if __GNUC__ > 4 || (__GNUC__ == 4)&&(__GNUC_MINOR__ > 4) 
#define    OMP_VERSION_3 
#endif
#else
#include <omp.h>
#undef    OMP_VERSION_3 
#endif

enum pix_fields
{
    u1 = 0, //      -|
    u2 = 1, //       |  Coordinates of pixel in the pixel projection axes
    u3 = 2, //       |
    u4 = 3, //      -|
    irun = 4, //        Run index in the header block from which pixel came
    idet = 5, //        Detector group number in the detector listing for the pixel
    ien = 6, //         Energy bin number for the pixel in the array in the (irun)th header
    iSign = 7, //      Signal array
    iErr = 8, //         Error array (variance i.e. error bar squared)
    PIX_WIDTH = 9  // Number of pixel fields
};
// modify this to support INTEL compiler (what OMP version(s) it has?




class omp_storage
    /** Class to manage dynamical storage used in OMP loops
    with various sources depending on the size of the storage and
    number of OMP threads  */

{
public:
    /* if memory allocated for multithreaded execution */
    bool is_mutlithreaded;
    /* pointers to the places, where thread data are stored
    depending on condition, this are either final destination or
    place on heap or on stack */
    double *pSignal, *pError, *pNpix;

    omp_storage(int num_OMP_Threads, size_t distribution_size, double *s, double *e, double *npix) :
        distr_size(distribution_size), largeMemory(NULL)
    {
        if (num_OMP_Threads > 1) {
            is_mutlithreaded = true;
            // allocate storage for particular threads
            try {
                se_vec_stor.assign(3 * num_OMP_Threads*distribution_size, 0.);
                double *pArray = &se_vec_stor[0];
                pSignal = pArray;
                pError = pArray + num_OMP_Threads*distribution_size;
                pNpix = pArray + 2 * num_OMP_Threads*distribution_size;
            }
            catch (...) // no space on stack try heap, 
            {
                largeMemory = (double *)mxCalloc(3 * num_OMP_Threads*distribution_size, sizeof(double));
                if (!largeMemory)throw("Can not allocate memory for processing data on threads. Decrease number of threads");
                pSignal = largeMemory;
                pError = largeMemory + num_OMP_Threads*distribution_size;
                pNpix = largeMemory + 2 * num_OMP_Threads*distribution_size;
            }

        }
        else {
            is_mutlithreaded = false;
            pSignal = s;
            pError = e;
            pNpix = npix;
        }


    };
    void add_signal(const double &signal, const double &error, int n_thread, size_t index)
    {
        /*  signal_stor[n_thread][il] += ;
        stor.error_stor[n_thread][il] += ;
        stor.ind_stor[n_thread][il]++; */

        size_t ind = n_thread*distr_size + index;
        (*(pSignal + ind)) += signal;
        (*(pError + ind)) += error;
        (*(pNpix + ind)) += 1;
    }
    ~omp_storage() {
        if (largeMemory) {
            mxFree(largeMemory);
        }
    }

private:
    size_t distr_size;


    std::vector<double > se_vec_stor;
    double * largeMemory;

};


#endif

