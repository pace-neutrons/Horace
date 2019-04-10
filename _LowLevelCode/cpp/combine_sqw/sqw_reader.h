#ifndef H_SQW_READER
#define H_SQW_READER

#include "pix_mem_map.h"
#include "fileParameters.h"
//-----------------------------------------------------------------------------------------------------------------
class sqw_reader
{
    /* Class provides bin and pixel information for a pixels of a single sqw file.

    Created to read bin and pixel information from a cell stored on hdd,
    but optimized for subsequent data access, so subsequent cells are
    cashed in a buffer and provided from the buffer if available

    %
    % $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
    %
    */
public:
    sqw_reader();
    ~sqw_reader();
    void init(const fileParameters &fpar, bool changefileno, bool fileno_provided, size_t working_buf_size = 4096, int use_multithreading = 0);
    /* return pixel information for the pixels stored in the bin */
    void get_pix_for_bin(size_t bin_number, float *const pix_info, size_t cur_buf_position,
        size_t &pix_start_num, size_t &num_bin_pix, bool position_is_defined = false);

    size_t get_npix()const{return _nPixInFile;}
    void finish_read_job();

    pix_mem_map & get_pix_map(){return pix_map;}

private:
    void _update_cash(size_t bin_number, size_t pix_start_num, size_t num_pix_in_bin, float *const pix_info);

    void _read_pix(size_t pix_start_num, float *const pix_buffer, size_t &num_pix_to_read);
    bool _get_thread_pix_param(size_t &first_thbuf_pix, size_t &last_thbuf_pix, size_t &n_tot_pix);
    void _get_thread_data(size_t &first_buf_pix, size_t &n_pix_in_buf,std::vector<float> &pixbuf, size_t next_pix_to_read);


    // parameters, which describe file 
    fileParameters fileDescr;
    pix_mem_map pix_map;
    // number of pixels, stored in the map;
    size_t _nPixInFile;



    size_t npix_in_buf_start; //= 0;
    size_t buf_pix_end; //  number of last pixel in the buffer+1
    std::vector<float> pix_buffer; // buffer containing pixels (9*npix size)

    bool use_streambuf_direct;
    std::ifstream h_data_file_pix;


   // number of pixels to read in pix buffer
    size_t PIX_BUF_SIZE;
    //Boolean indicating that the id, which specify pixel run number should be modified
    bool change_fileno;
    // Boolean, indicating if one needs to offset pixel's run number id by fileDescr.file_id
    // or set up its value into fileDescr.file_id;
    bool fileno;
    
    static const size_t PIX_SIZE = 9; // size of the pixel in pixel data units (float)
    static const size_t PIX_SIZE_BYTES = 36; //9 * 4; // size of the pixel block in bytes
    static const size_t PIX_BUF_DEFAULT_SIZE = 512; // in pixels, real size x 9;


    // thread buffer and thread reading operations ;
    std::mutex pix_read_lock, pix_exchange_lock;
    bool use_multithreading_pix, pix_read, pix_read_job_completed;
    size_t n_first_threadbuf_pix,num_treadbuf_pix;
    std::vector<float> thread_pix_buffer;
    std::condition_variable pix_ready, read_pix_needed;
    std::thread read_pix_job_holder;

    void read_pixels_job();



};

#endif