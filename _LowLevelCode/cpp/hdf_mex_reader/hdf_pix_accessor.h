#pragma once

#include <string>
#include <sstream>
#include <vector>

#include <hdf5.h>
#include <hdf5_hl.h>
#include <zlib.h>
#include <szlib.h>

#include <mex.h>
#include "input_parser.h"
#include "pix_block_processor.h"
#include <memory>

// OMP does not work with hdf5 unless protected by mutexes
//#ifndef _OPENMP
//void omp_set_num_threads(int nThreads) {};
//#define omp_get_num_threads() 1
//#define omp_get_max_threads() 1
//#define omp_get_thread_num()  0
//#else
//#include <omp.h>
//#endif


class hdf_pix_accessor
{
public:
    void init(const std::string &filename, const std::string &pix_group_name);
    size_t read_pixels(const pix_block_processor&pix_split_info, float *const pix_buffer,size_t buf_size);

    hdf_pix_accessor();
    ~hdf_pix_accessor();

private:
    std::string filename;
    std::string pix_group_name;

    hid_t  file_handle;
    hid_t  file_space_id;
    hid_t  pix_dataset;
    hid_t  pix_data_id;
    hid_t  pix_group_id;
    hid_t  io_mem_space;

    hsize_t max_num_pixels_;
    size_t  io_chunk_size_;

    void close_pix_dataset();
};

