#include "bin_io_handler.hpp"

void bin_io_handler::init(const fileParameters& fpar) {

    this->filename = fpar.fileName;
    this->h_inout.open(this->filename.c_str(), std::ios::binary | std::ios::in | std::ios::out | std::ofstream::app);
    if (!this->h_inout.is_open()) {
        std::string err = "Can not open target sqw file: " + fpar.fileName;
        mexErrMsgIdAndTxt(MEX_ERR_INPUT.c_str(), err.c_str());
    }

    this->last_pix_written = 0;
    this->pix_array_position = fpar.pix_start_pos;
    this->nbin_position = fpar.nbin_start_pos;
    this->pixel_width = fpar.pixel_width;
    this->h_inout.seekg(0, std::ios::end);
    this->file_size = this->h_inout.tellg();

}

size_t bin_io_handler::get_file_size() {//in order to create bounds for seekp and seekg need size of file 
    std::streampos current_pos = this->h_inout.tellg();
    this->h_inout.seekg(0, std::ios::end);
    size_t size = this->h_inout.tellg();
    this->h_inout.seekg(current_pos);
    return size;
}

bool bin_io_handler::seek_within_bounds(std::streampos position) {//seekp and seekg need bounds in order for them to not seek too far and break the code
    if (position > 0 || size_t(position) <= this->file_size) {
        this->h_inout.seekg(position);
        return true;
    }
    else {
        std::stringstream buf;
        size_t num_pixel = (size_t(position) - this->pix_array_position)/this->pixel_width;
        buf << "Seek position:" << position << "pixel number: " << num_pixel << " is out of bounds";
        mexErrMsgIdAndTxt(MEX_ERR_INPUT.c_str(), buf.str().c_str());
        return false;
    }
}
/**
  * Write pixel metadata containing information about pixel width
  * and number of pixels stored in pixels array
  * Inputs:
  * @param num_pixels -- number of pixes to be written in appropriate position in the file
  * @return           file is modified
   */
void bin_io_handler::write_pix_info(const size_t& num_pixels) {

    size_t pix_info_position = this->pix_array_position - this->pixel_info_size;
    uint32_t pix_width = uint32_t(this->pixel_width);

	this->seek_within_bounds(pix_info_position);
	this->h_inout.seekp(pix_info_position);
    this->h_inout.clear();

    //this->h_inout.write(reinterpret_cast<const char*>(&pix_width), sizeof(num_pixels));
	this->h_inout.write(reinterpret_cast<const char*>(&pix_width), sizeof(pix_width));
    this->h_inout.write(reinterpret_cast<const char*>(&num_pixels), sizeof(num_pixels));

    this->n_pixels_written_info = num_pixels;
}

/* Restore information about pixels block stored in the file */
void bin_io_handler::read_pix_info(size_t& num_pixels, uint32_t& pix_width) {
    size_t pix_info_position = this->pix_array_position - this->pixel_info_size;

    this->seek_within_bounds(pix_info_position);

    this->h_inout.read(reinterpret_cast<char*>(&pix_width), sizeof(pix_width));
    this->h_inout.read(reinterpret_cast<char*>(&num_pixels), sizeof(num_pixels));
	//this->h_inout.read(reinterpret_cast<char*>(&pix_width), sizeof(num_pixels));
}


/* Write chunk on pixel information stored in write buffer
*
*/
void bin_io_handler::write_pixels(const char* buffer, size_t num_pixels) {
    size_t pix_pos = pix_array_position + last_pix_written * this->pixel_width;
    this->h_inout.seekp(pix_pos);
    this->h_inout.clear();

    size_t length = num_pixels * this->pixel_width;
    this->h_inout.write(buffer, length);
    this->last_pix_written += length;
    auto last_pos = this->h_inout.tellp();
    if (last_pos > this->file_size) {
        this->file_size = last_pos;
    }
}



bin_io_handler::~bin_io_handler() {
    if (this->last_pix_written > this->n_pixels_written_info)
        this->write_pix_info(this->last_pix_written);

    this->h_inout.close();
}
