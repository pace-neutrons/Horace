#include "hdf_pix_accessor.h"

void hdf_pix_accessor::process_data(const input_file &new_input_file, input_types work_type,
    std::vector<std::unique_ptr<hdf_pix_accessor> > &readers,
    const std::vector<pix_block_processor> &pix_split_info, float *const pix_buffer, size_t buf_size) {
    int n_threads = static_cast<int>(readers.size());


    switch (work_type)
    {
    case close_file:
        for (int i = 0; i < n_threads; i++) {
            readers[i].reset(nullptr);
        }
        break;
    case open_and_read_data:
//        omp_set_num_threads(n_threads);
//#pragma omp parallel for
        for (int i = 0; i < n_threads; i++) {
            readers[i].reset(new hdf_pix_accessor());
            readers[i]->init(new_input_file.filename, new_input_file.groupname);
            readers[i]->read_pixels(pix_split_info[i], pix_buffer, buf_size);
        }
        break;
    case read_initiated_data:
//        omp_set_num_threads(n_threads);
//#pragma omp parallel for
        for (int i = 0; i < n_threads; i++) {
            readers[i]->read_pixels(pix_split_info[i], pix_buffer, buf_size);
        }
        break;
    default:
        mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", "Unknown operation mode");
        break;
    }
}


/* Simple initializer providing access to pixel data
 Assumes that all files and all groups are present.

Opens the file and pixels group for read access
The destructor should close all files and groups
Inpits:
in_filename          -- the name of nxsqw file to read
in_pixels_group_name -- full name of the pixels group within the hdf file.
*/
void hdf_pix_accessor::init(const std::string &in_filename, const std::string &in_pixels_group_name)
{
    this->filename = in_filename;
    this->pix_group_name = in_pixels_group_name;

    this->pix_data_id = H5Tcopy(H5T_NATIVE_FLOAT);

    this->file_handle = H5Fopen(in_filename.c_str(), H5F_ACC_RDONLY, H5P_DEFAULT);
    if (this->file_handle < 0) {
        mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", "can not open input file");
    }
    this->pix_group_id = H5Gopen(this->file_handle, in_pixels_group_name.c_str(), H5P_DEFAULT);
    if (this->pix_group_id < 0) {
        mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", "can not open pixels group");
    }
    this->pix_dataset = H5Dopen(this->pix_group_id, "pixels", H5P_DEFAULT);
    if (this->pix_dataset < 0) {
        mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", "can not open pixels dataset");
    }

    //
    this->file_space_id = H5Dget_space(this->pix_dataset);
    if (this->file_space_id < 0) {
        mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", "can not retrieve pixels dataspace on file");
    }
    int n_dims = H5Sget_simple_extent_ndims(this->file_space_id);
    if (n_dims != 2) {
        std::ostringstream  err_ss("pixels array dimensions should be equal to 2 but actually is: ");
        err_ss << n_dims;
        std::string err = err_ss.str();
        mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", err.c_str());
    }

    hsize_t dims[2], max_dims[2];
    int ndims = H5Sget_simple_extent_dims(this->file_space_id, dims, max_dims);
    if (ndims < 0) {
        mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", "can not retrieve pixels array dimensions");
    }

    this->max_num_pixels_ = dims[0];
    if (max_dims[1] != 9) {
        std::ostringstream  err_ss("'wrong size of pixel dataset. dimenison 1 has to be 9 but is: ");
        err_ss << max_dims[1];
        std::string err = err_ss.str();
        mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", err.c_str());
    }

    hid_t dcpl_id = H5Dget_create_plist(this->pix_dataset);
    hsize_t chunk_size[2];
    n_dims = H5Pget_chunk(dcpl_id, 2, chunk_size);
    if (n_dims != 2) {
        std::ostringstream  err_ss("pixels array chunk dimensions should be equal to 2 but actually is: ");
        err_ss << n_dims;
        std::string err = err_ss.str();
        mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", err.c_str());
    }

    this->io_chunk_size_ = chunk_size[0];
    const hsize_t block_dims[2] = { this->io_chunk_size_ , 9 };

    this->io_mem_space = H5Screate_simple(2, block_dims, block_dims);

    H5Dclose(dcpl_id);

}
//
void hdf_pix_accessor::close_pix_dataset() {

    if (this->file_space_id != -1) {
        H5Sclose(this->file_space_id);
        this->file_space_id = -1;
    }

    if (this->pix_dataset != -1) {
        H5Dclose(this->pix_dataset);
        this->pix_dataset = -1;
    }


}

size_t hdf_pix_accessor::read_pixels(const pix_block_processor&pix_split_info, float *const pix_buffer, size_t buf_size) {

    //hsize_t n_hs_blocks[2]    = { 1,1 };
    hsize_t block_start[2] = { 0,0 };
    hsize_t pix_chunk_size[2] = { 0,9 };
    hsize_t n_pix_processed(0), n_pix_selected(0);

    herr_t err;
    // input block positions provided as in Matlab/Fortran (starting from 1) so C position is one less

    size_t n_blocks = pix_split_info.n_blocks;
    size_t pix_buf_pos = pix_split_info.pix_buf_pos;
    size_t pix_buf_0pos = pix_buf_pos * 9;


    for (size_t i = 0; i < n_blocks; ++i) {
        hsize_t block_pos = pix_split_info.block_pos(i);
        n_pix_selected = pix_split_info.block_size(i);
        if (pix_buf_pos + n_pix_processed + n_pix_selected > buf_size) {
            mexWarnMsgIdAndTxt("HDF_MEX_ACCESSOR:logical_error",
                "Selected number of pixels exceeds allocated buffer. Pixels truncated but result may be incomplete");
            n_pix_selected = buf_size - pix_buf_pos + n_pix_processed;
        }


        if (block_pos + n_pix_selected > this->max_num_pixels_) {
            mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error",
                "Attempt to read pixels beyond of existing range of the pixels");
        }
        block_start[0] = block_pos;
        pix_chunk_size[0] = n_pix_selected;

        err = H5Sselect_hyperslab(this->file_space_id, H5S_SELECT_SET, block_start, NULL, pix_chunk_size, NULL);
        if (err < 0) {
            mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", "Can not select hyperslab while selecting pixels");
        }
        if (this->io_chunk_size_ != n_pix_selected) {
            err = H5Sset_extent_simple(this->io_mem_space, 2, pix_chunk_size, pix_chunk_size);
            if (err < 0)
                mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", "Can not extend memory dataspace to load pixels");
            this->io_chunk_size_ = n_pix_selected;
        }

        err = H5Dread(this->pix_dataset, this->pix_data_id, this->io_mem_space, this->file_space_id, H5P_DEFAULT, pix_buffer + pix_buf_0pos + n_pix_processed * 9);
        if (err < 0) {
            mexErrMsgIdAndTxt("HDF_MEX_ACCESSOR:runtime_error", "Error reading pixels");
        }
        n_pix_processed += n_pix_selected;
    }

    return n_pix_processed;

}


hdf_pix_accessor::~hdf_pix_accessor()
{
    if (this->io_mem_space != -1) {
        H5Sclose(this->io_mem_space);
    }
    if (this->pix_data_id != -1) {
        H5Tclose(this->pix_data_id);
    }
    this->close_pix_dataset();

    if (this->pix_group_id != -1) {
        H5Gclose(this->pix_group_id);
    }
    if (this->file_handle != -1) {
        H5Fclose(this->file_handle);
    }

}

hdf_pix_accessor::hdf_pix_accessor()
{
    this->file_handle = -1;
    this->pix_group_id = -1;

    this->pix_dataset = -1;
    this->pix_data_id = -1;

    this->file_space_id = -1;

    this->io_mem_space = -1;


}


