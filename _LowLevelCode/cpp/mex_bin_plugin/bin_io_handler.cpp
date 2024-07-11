#include "bin_io_handler.hpp"

 void bin_io_handler::init(const fileParameters & fpar) {

    this->filename = fpar.fileName;
    this->h_inout_sqw.open(this->filename.c_str(), std::ios::binary | std::ios::in | std::ios::out | std::ofstream::app);
    if (!this->h_inout_sqw.is_open()) {
        std::string err = "SQW_PIX_WRITER: Can not open target sqw file: " + fpar.fileName;
        mexErrMsgTxt(err.c_str());
    }

    this->last_pix_written   = 0;
    this->pix_array_position = fpar.pix_start_pos;
    this->nbin_position      = fpar.nbin_start_pos;
	this->pixel_width        = fpar.pixel_width;
}

 size_t bin_io_handler::get_file_size() {//in order to create bounds for seekp and seekg need size of file 
	 std::streampos current_pos = this->h_inout_sqw.tellg();
	 this->h_inout_sqw.seekg(0, std::ios::end);
	 size_t size = this->h_inout_sqw.tellg();
	 this->h_inout_sqw.seekg(current_pos);
	 return size;
 }
 bool bin_io_handler::seek_within_bounds(std::streampos position) {
	 size_t file_size = get_file_size();
	 if (position > 0 || size_t (position) <= file_size) {
		 this->h_inout_sqw.seekp(position);

		 return true;
	 }
	 else {
		 std::cerr << "Error: Seek position " << position << " is out of bounds." << std::endl;
		 this->h_inout_sqw.seekp(position);
		 return false;
		 
	 }
 }
 /* write pixel metadata containing information about pixel width 
    and number of pixels stored in pixels array
    Inputs:
    num_pixels -- number of pixes to be written in appropriate position in the file
    */
 void bin_io_handler::write_pix_info(const size_t& num_pixels) {
     size_t pix_info_position = this->pix_array_position - this->pixel_info_size;
     uint32_t pix_width = uint32_t(this->pixel_width) ;
     //this->h_inout_sqw.seekp(pix_info_position);
	 //if (seek_within_bounds(pix_info_position)) {
		 
		 this->h_inout_sqw.write(reinterpret_cast<const char*>(&pix_width), sizeof(pix_width));
		 this->h_inout_sqw.write(reinterpret_cast<const char*>(&num_pixels), sizeof(num_pixels));
	// }
 }

 void bin_io_handler::read_pix_info(size_t& num_pixels, uint32_t& pix_width) {
     size_t pix_info_position = this->pix_array_position - this->pixel_info_size;
	 if (seek_within_bounds(pix_info_position)) {
		 //this->h_inout_sqw.seekg(pix_info_position);  // Changed to seekg for reading
		 this->h_inout_sqw.read(reinterpret_cast<char*>(&pix_width), sizeof(pix_width));
		 this->h_inout_sqw.read(reinterpret_cast<char*>(&num_pixels), sizeof(num_pixels));
	 }
 }


/* Write chunk on pixels stored in write buffer */
void bin_io_handler::write_pixels(const char* buffer, size_t num_pixels) { 
    size_t pix_pos = pix_array_position + last_pix_written * this->pixel_width;
	//this->h_inout_sqw.seekp(pix_pos);
	//seek_within_bounds(pix_pos);
	if (seek_within_bounds(pix_pos)) {
		size_t length = num_pixels * this->pixel_width;
		this->h_inout_sqw.write(buffer, length);
		this->last_pix_written += length;
	}
	/*else {
	size_t length = num_pixels * this->pixel_width;
	this->h_inout_sqw.write(buffer, length);
	this->last_pix_written += length;
    }*/


}


bin_io_handler::~bin_io_handler() {
    this->h_inout_sqw.close();
}
