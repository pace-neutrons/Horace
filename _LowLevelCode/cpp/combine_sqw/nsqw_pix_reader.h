#ifndef H_NSQW_PIX_READER
#define H_NSQW_PIX_READER

#include "sqw_reader.h"
#include "exchange_buffer.h"

// parameters the mex routine uses and accepts in the array of input parameters
struct ProgParameters {
    size_t totNumBins;  // total number of bins in files to combine (has to be the same for all files)
    size_t nBin2read;  // current bin number to read (start from 0 for first bin of the array)
    size_t pixBufferSize; // the size of the buffer to return combined pixels
    int log_level;       // the number defines how talkative program is. usually it its > 1 all 
                         // all diagnostics information gets printed
    size_t num_log_ticks; // how many times per combine files to print log message about completion percentage
                          // Default constructor
    int thread_mode;      // integer defining the thread spawn strategy to use while reading and combining files.
    ProgParameters() :totNumBins(0), nBin2read(0),
        pixBufferSize(10000000), log_level(1), num_log_ticks(100), thread_mode(0)
    {};
};

//-----------------------------------------------------------------------------------------------------------------
/* Structure (class) supporting the read operations for range of input files and combining the information
from this files together in the file buffer*/
class nsqw_pix_reader {
    ProgParameters &param;
    std::vector<sqw_reader> &fileReaders;
    exchange_buffer &Buff;
public:
    nsqw_pix_reader(ProgParameters &prog_par, std::vector<sqw_reader> &tmpReaders, exchange_buffer &buf) :
        param(prog_par), fileReaders(tmpReaders), Buff(buf)
    { }
    // satisfy thread interface
    void operator()() {
        this->run_read_job();
    }
    void finish_read_jobs();

    //
    void run_read_job();
    void read_pix_info(size_t &n_buf_pixels, size_t &n_bins_processed, uint64_t *nBinBuffer = NULL);
};

#endif

