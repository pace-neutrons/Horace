#ifndef H_CELLS_MEM_MAP
#define H_CELLS_MEM_MAP
//
#include <vector>
#include <string>
#include <list>
#include <iostream>
#include <fstream>

#include <thread>
#include <mutex>
#include <condition_variable>

#include <algorithm>
// Matlab includes
#include <mex.h>

//-----------------------------------------------------------------------------------------------------------------
/* Class describes block of bins, loaded in memory and used to find location of correspondent block of pixels on HDD
*  practically providing pixels memory map
*
*  Its assumed that bins and pixels are the arrays of Horace data format 
*/
class pix_mem_map{
public:
    // the structure describes the part of bins, loaded in memory.
    struct bin_info {
        uint64_t num_bin_pixels; // number of pixels in given bins
        uint64_t pix_pos;        // position of the pixels wrt to the first bin loaded in memory
        bin_info() :
            num_bin_pixels(0), pix_pos(0) {}
        bin_info(size_t num_pix,size_t pix_pos_e) :
            num_bin_pixels(num_pix), pix_pos(pix_pos_e)
        {}
    };

    pix_mem_map();

    void init(const std::string &full_file_name, size_t bin_start_pos, size_t n_tot_bins, size_t BufferSize, bool use_multithreading);
    /* get number of pixels, stored in the bin and the position of these pixels within pixel array */
    void   get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix);
    /* expand memory map to accommodate and address the specified number of pixels. Returns maximal number of pixels
    to fit into buffer addressed by the integer number of bins */
    size_t check_expand_pix_map(size_t bin_number,size_t num_pix_to_fit, bool &end_of_pix_reached);
    /* Get information about the bins, stored in memory*/ 
    void get_map_param(size_t &first_mem_bin,size_t &last_mem_bin, size_t &n_tot_bins)const;
    /* return number of pixels, described by the map, stored in memory starting from the bin specified */
    size_t num_pix_described(size_t bin_number)const;
    void finish_read_bin_job();

    ~pix_mem_map();
    /* Return number of pixels, stored in file and defined by this memory map*/
    uint64_t num_pix_in_file()const {
        if (this->map_capacity_isknown) {
            return this->_numPixInMap;
        }else{
            return std::numeric_limits<uint64_t>::max();
        }
    }
protected: // for testing
    // EXPOSED FOR TESTING
    bool _read_bins(size_t num_bin,std::vector<bin_info> &buffer,
        size_t &bin_end, size_t &buf_end);

    void _update_data_cash(size_t bin_number);
    void _update_data_cash_(size_t bin_number, std::vector<bin_info> &nbin_buffer,
        size_t &num_first_buf_bin, size_t &num_last_buf_bin, size_t &end_buf_bin, size_t &prebuf_pix_num);
    size_t _flatten_memory_map(const std::list<std::vector<bin_info> > &bin_buf_holder, size_t map_size, size_t first_bin_number);
    bool _thread_get_data(size_t &num_bin, std::vector<bin_info> &inbuf, size_t &bin_end, size_t &buf_end);
    void _thread_query_data(size_t &num_first_bin, size_t &num_last_bin, size_t &buf_end);
    void _thread_request_to_read(size_t start_bin);
private:
    // the name of the file to process
    std::string full_file_name;

    bool use_streambuf_direct; //bin read mode
    size_t num_first_buf_bin,num_last_buf_bin,buf_end; // number of first and last bin stored in memory and number of last bin in the buffer

    size_t prebuf_pix_num;                // total number of pixels, stored before the pixels corresponding to the first bin buffer
    std::vector<bin_info> nbin_buffer;   // buffer containing bin info
    // temporary buffer, used by pix reader to read raw bin info.
    std::vector<uint64_t> nbin_read_buffer;

    //----------------------------------------------------------------------------
    size_t  _nTotalBins;
    size_t  _binFileStartPos;

    bool map_capacity_isknown;
    uint64_t  _numPixInMap;
    size_t  BUF_EXTENSION_STEP;


    // thread buffer and thread reading operations ;
    bool use_multithreading;
protected: // for testing only
    bool nbins_read, read_job_completed,thread_read_to_end;
    size_t n_first_rbuf_bin, rbuf_nbin_end, rbuf_end;

    std::vector<bin_info>  thread_nbin_buffer;
    std::mutex  exchange_lock,bin_read_lock;
    std::thread read_bins_job_holder;
    std::condition_variable read_bins_needed, bins_ready;


    void read_bins_job();


    //void calc_buf_range(size_t num_bin, size_t buf_size, size_t &tot_num_bins_to_read);

private:

    static const long BIN_SIZE_BYTES = 8;
    size_t BIN_BUF_SIZE; // physical size of the bins buffer
    //
    std::ifstream h_data_file_bin;


};

#endif