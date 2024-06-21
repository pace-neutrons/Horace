#include "bin_io_handler.hpp"

void bin_io_handler::init(const fileParameters & fpar) {


    this->filename = fpar.fileName;
    this->h_out_sqw.open(fpar.fileName, std::ofstream::binary | std::ofstream::out | std::ofstream::app);
    if (!this->h_out_sqw.is_open()) {
        std::string err = "SQW_PIX_WRITER: Can not open target sqw file: " + fpar.fileName;
        mexErrMsgTxt(err.c_str());
    }

    this->last_pix_written = 0;
    this->pix_array_position = fpar.pix_start_pos;
    this->nbin_position = fpar.nbin_start_pos;
}

/* Write chunk on pixels stored in write buffer */
void bin_io_handler::write_pixels(const char* buffer, size_t num_pixels) {
    //
    size_t pix_pos = pix_array_position + last_pix_written * this->pixel_width;
    //s
    this->h_out_sqw.seekp(pix_pos);
    //
    size_t length = num_pixels * this->pixel_width;
    this->h_out_sqw.write(buffer, length);
    this->last_pix_written += length;
    //

}
//
bin_io_handler::~bin_io_handler() {
    this->h_out_sqw.close();
}
