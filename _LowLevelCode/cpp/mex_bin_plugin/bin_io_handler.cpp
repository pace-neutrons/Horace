#include "bin_io_handler.h"

void bin_io_handler::init(const fileParameters& fpar) {

    this->last_pix_written = 0;
    this->pix_array_position = fpar.pix_start_pos;
    this->nbin_position = fpar.nbin_start_pos;
    this->pixel_width = fpar.pixel_width;

    this->filename = fpar.fileName;
    bool new_file(false);
    auto file_mode = std::ios::binary | std::ios::in | std::ios::out;
    if (!std::ifstream(filename.c_str())) {
        file_mode = file_mode | std::ios::trunc;
        new_file = true;
    }
    this->h_inout.open(this->filename.c_str(), file_mode);
    if (!this->h_inout.is_open()) {
        std::string err = "Can not open target sqw file: " + fpar.fileName;
        mexErrMsgIdAndTxt(MEX_ERR_ARGUMENTS.c_str(), err.c_str());
    }
    // identify actual file size
    this->h_inout.seekp(0, std::ios::end);
    this->file_size = this->h_inout.tellg();

    // padd files with 0 to allow writing pixel info or npix data at specified positions
    if ((this->pix_array_position > this->file_size + this->pixel_info_size) || (this->nbin_position > this->file_size)) {

        size_t add_size = std::max(this->pix_array_position, this->nbin_position);
        std::filesystem::path file(this->filename);
        std::filesystem::resize_file(file, add_size);
    }
    if (new_file) // write pix width
        this->write_pix_info(0);
}

/**
  * Write pixel metadata containing information about pixel width
  * and number of pixels stored in pixels array
  * Inputs:
  * @param num_pixels -- number of pixes to be written in appropriate position in the file
  * @return           file is modified
   */
void bin_io_handler::write_pix_info(const uint64_t& num_pixels) {

    size_t pix_info_position = this->pix_array_position - this->pixel_info_size;
    uint32_t pix_width = uint32_t(this->pixel_width);

    this->h_inout.seekp(pix_info_position, std::ios::beg);
    if (!this->h_inout.good()) {
        std::stringstream buf;
        buf << "Can not seek to pixel into position:" << pix_info_position;
        mexErrMsgIdAndTxt(MEX_ERR_IO.c_str(), buf.str().c_str());
    }


    this->h_inout.write(reinterpret_cast<const char*>(&pix_width), sizeof(pix_width));
    this->h_inout.write(reinterpret_cast<const char*>(&num_pixels), sizeof(num_pixels));
    if (!this->h_inout.good()) {
        std::stringstream buf;
        buf << "Can not write number of pixels:" << num_pixels;
        mexErrMsgIdAndTxt(MEX_ERR_IO.c_str(), buf.str().c_str());
    }

    this->n_pixels_written_info = num_pixels;
}

/**
Restore information about pixels block stored in the file

*/
void bin_io_handler::read_pix_info(size_t& num_pixels, uint32_t& pix_width) {
    size_t pix_info_position = this->pix_array_position - this->pixel_info_size;

    //this->seek_within_bounds(pix_info_position);
    this->h_inout.seekg(pix_info_position, std::ios::beg);
    if (!this->h_inout.good()) {
        std::stringstream buf;
        buf << "Can not seek to pixel into position for reading:" << pix_info_position;
        mexErrMsgIdAndTxt(MEX_ERR_IO.c_str(), buf.str().c_str());
    }


    this->h_inout.read(reinterpret_cast<char*>(&pix_width), sizeof(pix_width));
    this->h_inout.read(reinterpret_cast<char*>(&num_pixels), sizeof(num_pixels));
    //this->h_inout.read(reinterpret_cast<char*>(&pix_width), sizeof(num_pixels));
}

/**
*/
size_t  bin_io_handler::read_pixels(char* const buffer, size_t num_pixels_to_read, const size_t pix_position/* wrt the pixel block start */) {
    std::stringstream err_buf;
    if (pix_position + num_pixels_to_read > this->last_pix_written)
        num_pixels_to_read = this->last_pix_written - pix_position;

    this->h_inout.seekg(this->pix_array_position + pix_position * this->pixel_width);
    if (!this->h_inout.good()) {
        err_buf << "Can not seek to pixel array postioon to read pixels:" << this->pix_array_position + pix_position;
        mexErrMsgIdAndTxt(MEX_ERR_IO.c_str(), err_buf.str().c_str());
    }

    this->h_inout.read(buffer, num_pixels_to_read * sizeof(this->pixel_width));
    if (!this->h_inout.good()) {
        err_buf << "ERROR reading " << num_pixels_to_read << "pixels ";
        mexErrMsgIdAndTxt(MEX_ERR_IO.c_str(), err_buf.str().c_str());
    }

    // actually it would be bumber of really read pixels
    return num_pixels_to_read;
}

/** Write chunk on pixel information stored in write buffer
*
*  It is assumed that pixels are always written consequently and appended at the 
*  end of the existing pixel block
*/
void bin_io_handler::write_pixels(const char* buffer, size_t num_pixels) {
    // where to write next block of pixels
    size_t pix_pos = this->pix_array_position + this->last_pix_written * this->pixel_width;

    size_t length = num_pixels * this->pixel_width;
    this->h_inout.write(buffer, length);
    if (!this->h_inout.good()) {
        std::stringstream err_buf;
        err_buf << "ERROR adding to file containing " << this->last_pix_written
            << " pixels " << num_pixels << "additional pixels";
        mexErrMsgIdAndTxt(MEX_ERR_IO.c_str(), err_buf.str().c_str());
    }

    this->last_pix_written += num_pixels;
    auto last_pos = this->h_inout.tellp();
    if (last_pos > this->file_size) {
        this->file_size = last_pos;
    }

}



bin_io_handler::~bin_io_handler() {
    if (this->last_pix_written > this->n_pixels_written_info) {
        this->write_pix_info(this->last_pix_written);
    }
    else {
        this->write_pix_info(this->n_pixels_written_info);
    }


    this->h_inout.close();
}
