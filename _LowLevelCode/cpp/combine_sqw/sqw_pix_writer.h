#ifndef H_SQW_PIX_WRITER
#define H_SQW_PIX_WRITER

//#include "pix_mem_map.h"
#include "fileParameters.h"
#include "exchange_buffer.h"

//-----------------------------------------------------------------------------------------------------------------
/* Class responsible for writing block of pixels on HDD */
class sqw_pix_writer {
public:
    sqw_pix_writer(exchange_buffer &buf) :
        Buff(buf),
        last_pix_written(0), pix_array_position(0),
        num_bins_to_process(0) {}

    void init(const fileParameters &fpar, const size_t nBins2Process);
    void write_pixels(const char * const buffer, const size_t n_pix_to_write);
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

#endif