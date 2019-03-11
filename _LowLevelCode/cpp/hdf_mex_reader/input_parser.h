#pragma once

#include <mex.h>
#include <string>
#include <sstream>
#include "pix_block_processor.h"


enum input_types {
    close_file,
    open_and_read_data,
    read_initiated_data
};
enum InputArguments { // all input arguments
    filename,
    pixel_group_name,

    block_positions,
    block_sizes,
    n_first_block,
    pos_in_first_block,

    pix_buf_size,
    num_threads,
    N_INPUT_Arguments
};

enum OutputArguments { // unique output arguments,
    pix_array,
    n_first_block_left,
    pos_in_first_block_left,
    N_OUTPUT_Arguments
};


/* The structure defines the position of the pixel dataset in an nxsqw hdf file and consist of
   the name of the file and the full name of the group, containing pixels dataset*/
struct input_file {
    /* the name of hdf file to access pixels */
    std::string filename;
    /*the name of the group, containing pixels information */
    std::string groupname;

    /* check if the name and group name of other input file are equal to the current file*/
    bool equal(input_file &other_file) {
        if (other_file.filename == this->filename && other_file.groupname == this->groupname)
            return true;
        else return false;
    }
    bool do_destructor() {
        if ((this->filename.compare("close") == 0) || (this->groupname.compare("close") == 0))return true;
        else return false;
    }
    input_file& operator=(const input_file& other) {
        if (this != &other) {
            this->filename = other.filename;
            this->groupname = other.groupname;
        }
        return *this;
    }

};


input_types parse_inputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[],
    input_file &new_file,
    double *&block_pos, double *&block_size, size_t &n_blocks, int &n_bytes,
    std::vector<pix_block_processor> &block_split_info, size_t &npix_to_read);
