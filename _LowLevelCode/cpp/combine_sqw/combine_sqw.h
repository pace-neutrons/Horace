#ifndef H_COMBINE_SQW
#define H_COMBINE_SQW

#include "../../build_all/CommonCode.h"

#include <sstream>
#include <iostream>
#include <fstream>
#include <memory>
#include <map>
#include <stdio.h>
#include <ctime>
#include <thread>
#include <condition_variable>

//#define STDIO

//
// $Revision::      $ ($Date::                                              $)" 
//

/* Class describes a file to combine */
class fileParameters {
public:
    std::string fileName;
    size_t nbin_start_pos; // the initial file position where nbin array is located in the file
    long pix_start_pos;   // the initial file position where the pixel array is located in file
    int    file_id;       // the number which used to identify pixels, obtained from this particular file
    size_t total_NfileBins; // the number of bins in this file (has to be the same for all files)
    fileParameters(const mxArray *pFileParam);
    fileParameters():fileName(""),nbin_start_pos(0), pix_start_pos(0),
    file_id(0), total_NfileBins(0){}
private:
    static const std::map<std::string, int> fileParamNames;
};

// parameters the mex routine uses and accepts in the array of input parameters
struct ProgParameters {
    size_t totNumBins;  // total number of bins in files to combine (has to be the same for all files)
    size_t nBin2read;  // current bin number to read (start from 0 for first bin of the array)
    size_t pixBufferSize; // the size of the buffer to return combined pixels
    int log_level;       // the number defines how talkative program is. usually it its > 1 all 
                         // all diagnostics information gets printed
    size_t num_log_ticks; // how many times per combine files to print log message about completion percentage
                          // Default constructor
    ProgParameters() :totNumBins(0), nBin2read(0),
        pixBufferSize(10000000), log_level(1), num_log_ticks(100)
    {};
};


enum readBinInfoOption {
    sumPixInfo,
    keepPixInfo
};

//-----------------------------------------------------------------------------------------------------------------
/* Class provides unblocking read/write buffer and logging operations for asynchronous read and write operations on 3 threads */
class exchange_buffer {
public:
    // read buffer
    char *const  get_write_buffer(size_t &nPixels,size_t &n_bin_processed);
    float *const get_read_buffer(const size_t buf_size=0);
    // lock write buffer from modifications by other threads too but unlocks read buffer
    void set_and_lock_write_buffer(const size_t nPixels, const size_t nBinsProcessed);
    void unlock_write_buffer();

    void set_interrupted(const std::string &err_message) {
        interrupted=true;
        this->error_message = err_message;
    }
    bool is_interrupted()const{return interrupted; }
    bool is_write_job_completed()const{return write_job_completed;}
    void set_write_job_completed();

    exchange_buffer(size_t b_size,size_t num_bins_2_process,size_t num_log_ticks):
    do_logging(false),
    buf_size(b_size*PIX_SIZE),
    n_read_pixels(0),n_bins_processed(0),
    num_bins_to_process(num_bins_2_process), 
    interrupted(false), write_allowed(false),
    write_job_completed(false),
    break_step(1),num_log_messages(num_log_ticks), break_point(0),n_read_pix_total(0)
    {
        break_step = num_bins_to_process / num_log_messages;
        break_point = break_step;
        c_start = std::clock();
        time(&t_start);
        t_prev = t_start;


    };
    void check_log_and_interrupt();
    void print_log_meassage(int log_level);
    void print_final_log_mess(int log_level)const;

    size_t pix_buf_size()const {
        return( buf_size/ PIX_SIZE);
    }
    // logging semaphore
    bool do_logging;
    std::condition_variable logging_ready;
    // error message used in case if program is interrupted;
    std::string error_message;
private:
    size_t buf_size;
    size_t n_read_pixels, n_bins_processed,num_bins_to_process;
    bool interrupted, write_allowed,write_job_completed;
    // logging and timing:
    size_t break_step, num_log_messages, break_point, n_read_pix_total;
    std::clock_t c_start;
    time_t t_start,t_prev;


    std::condition_variable data_ready;
    std::mutex exchange_lock;
    std::mutex write_lock;


    std::vector<float> read_buf;
    std::vector<float> write_buf;

    static const size_t PIX_SIZE = 9; // size of the pixel in pixel data units (float)

};

//-----------------------------------------------------------------------------------------------------------------
/* Class describes block of bins, loaded in memory and describe location of correspondent block of pixels on HDD*/
class cells_in_memory {
    public:
        cells_in_memory(size_t buf_size) :
            nTotalBins(0), binFileStartPos(0),
            num_first_buf_bin(0), buf_bin_end(0), pix_before_buffer(0),
            BIN_BUF_SIZE(buf_size), BUF_SIZE_STEP(buf_size), buf_end(1){
        }
#ifdef STDIO
        void init(FILE *fileDescr, size_t bin_start_pos,size_t n_tot_bins,size_t bufSize=4096);
        long fpos;
#else
        void init(std::fstream  &fileDescr, size_t bin_start_pos, size_t n_tot_bins, size_t bufSize = 4096);
#endif

        size_t num_pix_described(size_t bin_number)const;
        size_t num_pix_to_fit(size_t bin_number,size_t buf_size)const;
        void   get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix);
        void expand_pixels_selection(size_t bin_number);

    private:
        size_t  nTotalBins;
        size_t  binFileStartPos;

        size_t  num_first_buf_bin; // number of first bin in the buffer
        size_t  buf_bin_end; //  number of the last bin in the buffer+1
                             // buffer containing bin info
        size_t  pix_before_buffer; /* number of pixels, located before the first pixel, described by the buffer 
        e.g. position of the first pixel located in the first bin of the buffer */
        std::vector<uint64_t> nbin_buffer;
        std::vector<uint64_t> pix_pos_in_buffer;
        size_t BIN_BUF_SIZE; // physical size of the pixels buffer
        size_t BUF_SIZE_STEP; // unit step for BIN_BUF_SIZE, which should not exceed 2*BUF_SIZE_STEP;
        size_t buf_end; /* points to the place after the last bin actually read into the buffer.
        Differs from BIN_BUF_SIZE, as BIN_BUF_SIZE is physical buffer size which may not have all or any bins read into
        e.g at the end, where all available bins were read */
#ifdef STDIO
        FILE *fReader;
#else
        std::fstream  *fReader;
#endif

        size_t read_bins(size_t num_bin,size_t buf_start,size_t buf_size);
        void read_all_bin_info(size_t bin_number);

        static const long BIN_SIZE_BYTES=8;
};
//-----------------------------------------------------------------------------------------------------------------
/* Class responsible for writing block of pixels on HDD */
class sqw_pix_writer {
public:
    sqw_pix_writer(exchange_buffer &buf):
    Buff(buf),
    last_pix_written(0), pix_array_position(0),
    num_bins_to_process(0){}

    void init(const fileParameters &fpar,const size_t nBins2Process);
    void write_pixels(const char * const buffer,const size_t n_pix_to_write);
    void run_write_pix_job();
    void operator()() {
        this->run_write_pix_job();
    }
    ~sqw_pix_writer();

private:
    exchange_buffer &Buff;

    // size of write pixels buffer (in pixels)
    std::string filename;

    std::ofstream h_out_sqw;
    size_t last_pix_written;
    size_t pix_array_position;
    size_t nbin_position;
    size_t num_bins_to_process;

    std::vector<float> pix_buffer;
    //
    static const size_t PIX_BLOCK_SIZE_BYTES = 36; //9 * 4; // size of the pixel block in bytes


};

//-----------------------------------------------------------------------------------------------------------------
class sqw_reader {
    /* Class provides bin and pixel information for a pixels of a sinlge sqw file.

    Created to read bin and pixel information from a cell stored on hdd,
    but optimized for subsequent data access, so subsequent cells are
    cashed in a buffer and provided from the buffer if available

    %
    % $Revision$($Date : 2015 - 12 - 07 21 : 20 : 34 + 0000 (Mon, 07 Dec 2015) $)
    %
    */
public:
    sqw_reader(size_t working_buf_size=4096);
    sqw_reader(const fileParameters &fpar, bool changefileno, bool fileno_provided,size_t working_buf_size=4096);
    void init(const fileParameters &fpar,bool changefileno, bool fileno_provided,size_t working_buf_size=4096);
    ~sqw_reader() {
#ifdef STDIO
       fclose(h_data_file);
#else
        h_data_file.close();
#endif
    }
    /* get number of pixels, stored in the bin and the position of these pixels within pixel array */
    void get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix);
    /* return pixel information for the pixels stored in the bin */
    void get_pix_for_bin(size_t bin_number,  float *const pix_info,size_t cur_buf_position,
                         size_t &pix_start_num, size_t &num_bin_pix, bool position_is_defined = false);
private:
    void read_pixels(size_t bin_number, size_t pix_start_num);
    size_t check_binInfo_loaded_(size_t bin_number, bool extend_pix_buffer=true);

    // the name of the file to process
    std::string full_file_name;
    // handle pointing to open file
#ifdef STDIO
    FILE *h_data_file;
#else
    std::fstream h_data_file;
#endif

    // parameters, which describe 
    fileParameters fileDescr;

    cells_in_memory bin_buffer;

    size_t npix_in_buf_start; //= 0;
    size_t buf_pix_end; //  number of last pixel in the buffer+1
    std::vector<float> pix_buffer; // buffer containing pixels (9*npix size)

     // number of pixels to read in pix buffer
    size_t PIX_BUF_SIZE;
    //Boolean indicating that the id, which specify pixel run number should be modified
    bool change_fileno;
    // Boolean, indicating if one needs to offset pixel's run number id by fileDescr.file_id
    // or set up its value into fileDescr.file_id;
    bool fileno;

    static const size_t PIX_SIZE = 9; // size of the pixel in pixel data units (float)
    static const size_t PIX_BLOCK_SIZE_BYTES = 36; //9 * 4; // size of the pixel block in bytes


};



//-----------------------------------------------------------------------------------------------------------------
/* Structure (class) supporting the read operations for range of input files and combining the information 
from this files together in the file buffer*/
struct pix_reader {
    ProgParameters &param;
    std::vector<sqw_reader> &fileReaders;
    exchange_buffer &Buff;

    pix_reader(ProgParameters &prog_par, std::vector<sqw_reader> &tmpReaders, exchange_buffer &buf) :
        param(prog_par), fileReaders(tmpReaders), Buff(buf)
    { }
    // satisfy thread interface
    void operator()() {
        this->run_read_job();
    }

    //
    void run_read_job();
    void read_pix_info(size_t &n_buf_pixels, size_t &n_bins_processed, uint64_t *nBinBuffer = NULL);
};

#endif
