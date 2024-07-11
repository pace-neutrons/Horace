#pragma once

#include <iostream>
#include <sstream>
#include <fstream>
#include <iomanip>
#include <map>
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
/* Class responsible for writing block of pixels on HDD */
class bin_io_handler {
public:
	bin_io_handler() :
		last_pix_written(0), pix_array_position(12),pixel_width(36),nbin_position(0) {}
	
	//bin_io_handler() = default;

    void init(const fileParameters &fpar);
    void write_pixels(const char * const buffer, const size_t n_pix_to_write);
	void write_pix_info(const size_t& num_pixels);
	
    void read_pix_info(size_t& num_pixels, uint32_t& pix_width);
	size_t get_file_size();
	bool seek_within_bounds(std::streampos position);
    
    ~bin_io_handler();

	// size of the fields containing pixel information, e.g. pixel_width (in bytes)
	// and number of pixels written on disk
	const size_t pixel_info_size{ 12 };
private:
    //exchange_buffer &Buff;
	
    std::string filename;
	std::fstream h_inout_sqw;
	size_t last_pix_written;
	size_t pix_array_position;
	size_t pixel_width;
	size_t nbin_position;
	
	
    std::vector<float> pix_buffer{};
    

};


