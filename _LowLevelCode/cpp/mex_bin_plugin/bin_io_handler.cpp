#include "bin_io_handler.hpp"

void bin_io_handler::init(const fileParameters & fpar, const size_t n_bins2process) {

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
//void bin_io_handler::run_write_pix_job() {
//
//	exchange_buffer Buff;
//
//    size_t n_bins_processed(0);
//    // inform reader thread that writer thread ready for exchange
//    //Buff.notify_writer_is_ready(); // It seems it is unnecessary, as writer waits for reader data below,
//    // but worth remembering that we used this option in the past and it is unnecessary.
//    //
//
//    while (n_bins_processed < this->num_bins_to_process && !Buff.is_interrupted()) {
//        size_t n_pix_to_write;
//        // this locks until read completed unless read have not been started
//        Buff.wait_for_reader_data();
//        const char* buf = Buff.get_write_buffer(n_pix_to_write, n_bins_processed);
//
//        size_t length = n_pix_to_write * PIX_BLOCK_SIZE_BYTES;
//
//        if (buf)
//            this->write_pixels(buf, length);
//        last_pix_written += n_pix_to_write;
//
//        Buff.check_logging();
//        Buff.unlock_write_buffer();
//    }
//    Buff.set_write_job_completed();
//}
/* Write chunk on pixels stored in write buffer */
void bin_io_handler::write_pixels(const char* buffer, size_t length) {
	//
	size_t pix_pos = pix_array_position + last_pix_written * PIX_BLOCK_SIZE_BYTES;
	//
	this->h_out_sqw.seekp(pix_pos);
	//
	this->h_out_sqw.write(buffer, length);
	//

}
//
bin_io_handler::~bin_io_handler() {
	this->h_out_sqw.close();
}
