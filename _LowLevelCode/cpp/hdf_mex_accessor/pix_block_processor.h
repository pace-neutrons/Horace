#pragma once
#include <vector>
#include <hdf5.h>
/* The class which describes a block of information necessary to process block of pixels */
class pix_block_processor {
public:
    // number of blocks to process
    size_t n_blocks;
    // the initial position of the pixels, described by this block in the pixels buffer;
    size_t  pix_buf_pos;

    // how many pixels to skip while processing the first block
    size_t pos_in_first_block;
    // how many pixels to take from the last block
    size_t pos_in_last_block;



    hsize_t block_pos(size_t ind)const {
        hsize_t sel_block_pos;
        if (ind == 0)
            sel_block_pos = static_cast<hsize_t>(*this->pBlockPos) + this->pos_in_first_block - 1; //-1 to convert Matlab array convention to C array convention
        else
            sel_block_pos = static_cast<hsize_t>(this->pBlockPos[ind]) - 1; //-1 to convert Matlab array convention to C array convention
        return sel_block_pos;
    }

    hsize_t block_size(size_t ind)const {
        hsize_t sel_block_size;
        if (n_blocks == 1) {
            sel_block_size = this->pos_in_last_block - this->pos_in_first_block;
        }
        else {
            if (ind == 0)
                sel_block_size = static_cast<hsize_t>(*this->pBlockSizes) - this->pos_in_first_block;
            else if (ind < this->n_blocks - 1)
                sel_block_size = static_cast<hsize_t>(this->pBlockSizes[ind]);
            else
                sel_block_size = this->pos_in_last_block;
        }
        return sel_block_size;
    }

    pix_block_processor() :
        n_blocks(0), pix_buf_pos(0),
        pos_in_first_block(0), pos_in_last_block(0),
        pBlockPos(nullptr), pBlockSizes(nullptr) {}

    size_t npix_in_last_block() {
        return (this->pos_in_last_block + 1);
    };
    void init(double const*const block_pos, double const*const block_sizes, size_t last_split_block_num, size_t last_split_block_pos,
        size_t cur_split_block_num, size_t cur_split_block_pos, size_t n_pix_processed_before);
    static std::vector<pix_block_processor> split_pix_block(double const *const blockPos, double const *const blockSizes,
        size_t n_blocks, size_t n_first_block, size_t pos_in_first_block, size_t buf_size, size_t n_parts);
private:
    // pointer to the initial place in array of block positions
    double const *pBlockPos;
    // pointer to the inital place in array of block sizes
    double const *pBlockSizes;



};