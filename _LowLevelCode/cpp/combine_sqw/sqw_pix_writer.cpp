#include <iostream>
#include <fstream>

#include "sqw_pix_writer.h"

//--------------------------------------------------------------------------------------------------------------------
//----------- PIX WRITER ---------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/*Initialize writer parameters
Input:
@param fpar           -- input parameters describing the output file
@param n_bins2process -- number of bins to process (combine)
*/
void sqw_pix_writer::init(const fileParameters &fpar, const size_t n_bins2process) {

    this->num_bins_to_process = n_bins2process;
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
/* Operation which runs on separate thread and writes pixels */
void sqw_pix_writer::run_write_pix_job() {

    size_t n_bins_processed(0);

    while (n_bins_processed < this->num_bins_to_process && !Buff.is_interrupted()) {
        size_t n_pix_to_write;
        // this locks until read completed unless read have not been started
        const char *buf = Buff.get_write_buffer(n_pix_to_write, n_bins_processed);

        size_t length = n_pix_to_write*PIX_BLOCK_SIZE_BYTES;

        if (buf)
            this->write_pixels(buf, length);
        last_pix_written += n_pix_to_write;

        Buff.check_logging();
        Buff.unlock_write_buffer();
    }
    Buff.set_write_job_completed();
}
/* Write chunk on pixels stored in write buffer */
void sqw_pix_writer::write_pixels(const char *buffer, size_t length) {
    //
    size_t pix_pos = pix_array_position + last_pix_written*PIX_BLOCK_SIZE_BYTES;
    //
    this->h_out_sqw.seekp(pix_pos);
    //
    this->h_out_sqw.write(buffer, length);
    //

}
//
sqw_pix_writer::~sqw_pix_writer() {
    this->h_out_sqw.close();
}