#include "bin_io_handler.hpp"

 void bin_io_handler::init(const fileParameters & fpar) {

    fileParameters check_inputs_provided();

    this->filename = fpar.fileName;
    this->h_inout_sqw.open(fpar.fileName, std::ofstream::binary | std::ofstream::out | std::ofstream::app);
    if (!this->h_inout_sqw.is_open()) {
        std::string err = "SQW_PIX_WRITER: Can not open target sqw file: " + fpar.fileName;
        mexErrMsgTxt(err.c_str());
    }

    this->last_pix_written = 0;
    this->pix_array_position = fpar.pix_start_pos;
    this->nbin_position = fpar.nbin_start_pos;
}/*
void  bin_io_handler::write_pix_info(const size_t& num_pixels, const uint32_t& pix_width) {

    size_t pix_info_position = this->pix_array_position - 32 - 64;
	this->h_inout_sqw.seekp(pix_info_position);
    this->h_inout_sqw.write(reinterpret_cast<const char * const>(&pix_width), sizeof(pix_width));
    this->h_inout_sqw.write(reinterpret_cast<const char * const>(&num_pixels), sizeof(num_pixels));

}
void bin_io_handler::read_pix_info(size_t &num_pixels, uint32_t& pix_width) {

    size_t pix_info_position = this->pix_array_position - 32 - 64;
    this->h_inout_sqw.seekg(pix_info_position);
	this->h_inout_sqw.read(reinterpret_cast<char*>(&pix_width), sizeof(pix_width));
	this->h_inout_sqw.read(reinterpret_cast<char*>(&num_pixels), sizeof(num_pixels));
	
}*/

 void bin_io_handler::write_pix_info(const size_t& num_pixels, const uint32_t& pix_width) {
	 size_t pix_info_position = this->pix_array_position - 32 - 64;
	 this->h_inout_sqw.seekp(pix_info_position);
	 this->h_inout_sqw.write(reinterpret_cast<const char*>(&pix_width), sizeof(pix_width));
	 this->h_inout_sqw.write(reinterpret_cast<const char*>(&num_pixels), sizeof(num_pixels));
 }

 void bin_io_handler::read_pix_info(size_t& num_pixels, uint32_t& pix_width) {
	 size_t pix_info_position = this->pix_array_position - 32 - 64;
	 this->h_inout_sqw.seekg(pix_info_position);  // Changed to seekg for reading
	 this->h_inout_sqw.read(reinterpret_cast<char*>(&pix_width), sizeof(pix_width));
	 this->h_inout_sqw.read(reinterpret_cast<char*>(&num_pixels), sizeof(num_pixels));
 }


/* Write chunk on pixels stored in write buffer */
void bin_io_handler::write_pixels(const char* buffer, size_t num_pixels) {
    //
    size_t pix_pos = pix_array_position + last_pix_written * this->pixel_width;
    //s
    this->h_inout_sqw.seekp(pix_pos);
    //
    size_t length = num_pixels * this->pixel_width;
    this->h_inout_sqw.write(buffer, length);
    this->last_pix_written += length;
    //

}

void set_properties(const  std::string& fileName, const size_t num_pixels(), const size_t pix_start_pos(), const size_t pix_width()) {
	
	fileParameters input;
	//std::vector<char> x(10, 'a'); {
		input.fileName = "/_test/file_for_metadata.bin";
		input.pix_start_pos = 64;
		input.pixel_width = 32;
		
	//}
	//bin_io_handler(input);
}
//
bin_io_handler::~bin_io_handler() {
    this->h_inout_sqw.close();
}
