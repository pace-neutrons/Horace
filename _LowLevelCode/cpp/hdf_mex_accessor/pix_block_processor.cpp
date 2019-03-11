#include "pix_block_processor.h"

void pix_block_processor::init(double const*const block_pos, double const*const block_sizes, size_t blocks_start_pos,
    size_t pix_start_pos, size_t n_blocks_to_read,
    size_t first_split_block_pos, size_t last_split_block_pos) {

    this->pBlockPos = block_pos + blocks_start_pos;
    this->pBlockSizes = block_sizes + blocks_start_pos;
    this->n_blocks = n_blocks_to_read;

    this->pos_in_first_block = first_split_block_pos;
    this->pos_in_last_block = last_split_block_pos;
    this->pix_buf_pos = pix_start_pos;
}

std::vector<pix_block_processor> pix_block_processor::split_pix_block(double const *const blockPos, double const *const blockSizes,
    size_t n_blocks, size_t n_first_block, size_t pos_in_first_block,
    size_t buf_size, size_t n_parts) {


    // split total number of pixels to read into equal blocks dedicated to each thread.
    std::vector<pix_block_processor> split_info(n_parts + 1);
    size_t npix_per_thread = buf_size / n_parts;
    std::vector<size_t> npix_per_thread_sb(n_parts, npix_per_thread);
    size_t npix_reserved = npix_per_thread*n_parts;
    if (npix_reserved < buf_size) {
        for (size_t i = 0; i < n_parts; i++) {
            npix_per_thread_sb[i]++;
            npix_reserved++;
            if (npix_reserved >= buf_size) break;
        }
    }


    size_t n_thread_blocks_sel(0), blocks_start_pos(n_first_block), pix_start_pos(0);
    size_t last_split_block_pos(pos_in_first_block);
    size_t cur_split_block_pos(0);
    size_t n_blocks_read;
    int64_t n_block_pix_slected(0);

    n_block_pix_slected -= last_split_block_pos;
    for (size_t i = n_first_block; i < n_blocks; ++i) {
        size_t cur_block_size = static_cast<size_t>(blockSizes[i]);
        n_block_pix_slected += cur_block_size;

        if (n_block_pix_slected == npix_per_thread_sb[n_thread_blocks_sel]) {
            size_t n_blocks_to_read = i - blocks_start_pos + 1;
            size_t block_size;
            if (n_blocks_to_read <= 1)
                block_size = npix_per_thread_sb[n_thread_blocks_sel] + last_split_block_pos;
            else
                block_size = cur_block_size;
            split_info[n_thread_blocks_sel].init(blockPos, blockSizes, blocks_start_pos, pix_start_pos, n_blocks_to_read, last_split_block_pos, block_size);
            n_thread_blocks_sel++;


            blocks_start_pos = i + 1;             // The position of the next info block in the pix read info.
            pix_start_pos += n_block_pix_slected; // The position of the next pixels block in the pixel buffer.

            n_block_pix_slected = 0;
            last_split_block_pos = 0;
        }
        else if (fabs(n_block_pix_slected) > npix_per_thread_sb[n_thread_blocks_sel]) {
            size_t n_blocks_to_read = i - blocks_start_pos + 1;


            // initialize block splitting info;
            size_t overhung = n_block_pix_slected - npix_per_thread_sb[n_thread_blocks_sel];
            cur_split_block_pos = cur_block_size - overhung;
            n_block_pix_slected = npix_per_thread_sb[n_thread_blocks_sel];

            split_info[n_thread_blocks_sel].init(blockPos, blockSizes, blocks_start_pos, pix_start_pos, n_blocks_to_read, last_split_block_pos, cur_split_block_pos);
            n_thread_blocks_sel++;

            blocks_start_pos = i;       // The block is split. The position of the next info block in the pix read info is the same as the last block
            pix_start_pos += n_block_pix_slected; // The position of the next pixels block in the pixel buffer.


            n_block_pix_slected = overhung;
            last_split_block_pos = cur_split_block_pos;
            // process big pixels block, hanging 
            while (n_thread_blocks_sel < n_parts && overhung >= npix_per_thread_sb[n_thread_blocks_sel]) {
 

                overhung = n_block_pix_slected - npix_per_thread_sb[n_thread_blocks_sel];
                cur_split_block_pos = cur_block_size - overhung;
                n_block_pix_slected = npix_per_thread_sb[n_thread_blocks_sel];

                split_info[n_thread_blocks_sel].init(blockPos, blockSizes, blocks_start_pos, pix_start_pos, 1, last_split_block_pos, cur_split_block_pos);

                n_thread_blocks_sel++;
                pix_start_pos += n_block_pix_slected; // The position of the next pixels block in the pixel buffer.
                //
                last_split_block_pos = cur_split_block_pos;
                n_block_pix_slected = overhung;
                if (overhung == 0){
                    blocks_start_pos++;
                    last_split_block_pos = 0;
                }
            }
        }
        n_blocks_read = blocks_start_pos;

        if (n_thread_blocks_sel >= n_parts) {
            break;
        }
    }

    // use n_blocks_read as input for last nblocks as it will be used as output only and not to read any data
    split_info[n_parts].init(blockPos, blockSizes, blocks_start_pos, pix_start_pos, n_blocks_read, last_split_block_pos, 0);

    return split_info;

}