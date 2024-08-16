#pragma once

#include <iostream>
#include <sstream>
#include <fstream>
#include <iomanip>
#include <map>
#include <memory>
#include <vector>
#include <mex.h>
#include <matrix.h>
#include <sys/stat.h>
#include <condition_variable>
#include <ctime>
#include <thread>
#include <mex.h>
#include <matrix.h>
#include <limits>
#include <sys/stat.h>
#include <filesystem>

#include "../file_parameters/fileParameters.h"


//-----------------------------------------------------------------------------------------------------------------
/** @brief
  *Class responsible for reading and writing block of pixels and pixel distributin information on HDD
  */
class bin_io_handler {
public:
	bin_io_handler() :
		last_pix_written(0), pix_array_position(bin_io_handler::pixel_info_size), pixel_width(36), nbin_position(0),
		n_pixels_written_info(0), nbins_field_size(0), file_size(0)
	{}


	void init(const fileParameters& fpar);
	void write_pixels(const char* const buffer, const size_t n_pix_to_write);
	void write_pix_info(const uint64_t& num_pixels);

	void read_pix_info(size_t& num_pixels, uint32_t& pix_width);
	size_t read_pixels(char* const buffer, size_t num_pixels,const size_t pix_position = 0/* wrt the pixel block start */);

	~bin_io_handler();

private:

	//VARIABLES:
	std::string filename;       // name of the file this class works with
	std::fstream h_inout;      // holder for the stream, operated with the file
	//
	size_t last_pix_written;   // counter for number of pixels stored in subsequent write operations
	size_t pix_array_position; // location of pix_array within the binary file
	size_t pixel_width;        // how many bytes single pixels block takes
	size_t nbin_position;      // where nbin_info field is stored.


	//tests and internal variables
	size_t n_pixels_written_info; // contains the information about pixels metadata
	// to ensure pixel metadata are synchroneous with number of pixels actually written in file
	size_t nbins_field_size;    // the size of npix block written in file
	size_t file_size;           //initial file size

	// size of the fields containing pixel information, e.g. pixel_width (in bytes)
	// and number of pixels written on disk
	const size_t pixel_info_size{ 12 };
	// message ID this class return to Matlab in case of errors
	const std::string MEX_ERR_ARGUMENTS{"HORACE:bin_io_handler:invalid_argument"};
	const std::string MEX_ERR_IO{"HORACE:bin_io_handler:io_error"};

};


