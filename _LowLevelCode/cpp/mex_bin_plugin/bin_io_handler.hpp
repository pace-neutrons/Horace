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
		last_pix_written(0), pix_array_position(0),pixel_width(0) {}
	size_t last_pix_written;
	size_t pix_array_position;
	size_t nbin_position;
	size_t pixel_width;
	size_t num_pixels_written;
	

    void init(const fileParameters &fpar);
    void write_pixels(const char * const buffer, const size_t n_pix_to_write);
    void write_pix_info(const size_t &num_pixels, const uint32_t &pix_width);
    void read_pix_info(size_t& num_pixels, uint32_t& pix_width);

    
    ~bin_io_handler();


private:
    //exchange_buffer &Buff;
	
    std::string filename;
	std::ifstream h_in_sqw;
    std::ofstream h_out_sqw;
	/*
	size_t last_pix_written;
    size_t pix_array_position;
    size_t nbin_position;
    size_t pixel_width;
	size_t num_pixels_written;
	
	*/
    std::vector<float> pix_buffer{};
    //

};


