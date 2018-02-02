#include "nsqw_pix_reader.h"
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//
void nsqw_pix_reader::run_read_job() {
    int log_level = param.log_level;


    size_t start_bin = param.nBin2read;
    size_t n_pixels_processed(0);

    //
    size_t n_bins_total = param.totNumBins;
    //
    //
    while (start_bin < n_bins_total && !Buff.is_interrupted()) {
        size_t n_buf_pixels(0);
        this->read_pix_info(n_buf_pixels, start_bin);

        //pixWriter.write_pixels(Buff);
        //new start bin is by one shifted wrt the last bin read
        start_bin++;
        //
        n_pixels_processed += n_buf_pixels;
    }
    Buff.set_write_allowed();
}
/* Read pixels from all input files for correspondent bin and place them all together in the pixels buffer until the buffer is full
   and contains pixels corresponding to number of bins 
   Input as class parameter:
   BinBuffer -- class containing the storage to place pixels

   @param n_buf_pixels     -- on output contains number of pixels, fit into buffer
   @param n_bins_processed -- on input contains number of first bin to read in the buffer, on output --
                              last bin fit to buffer
   */
void nsqw_pix_reader::read_pix_info(size_t &n_buf_pixels, size_t &n_bins_processed, uint64_t *nBinBuffer) {

    n_buf_pixels = 0;
    size_t first_bin = n_bins_processed;


    size_t n_files = this->fileReaders.size();
    const size_t nBinsTotal(this->param.totNumBins);
    size_t n_tot_bins(0);
    size_t npix, pix_start_num;
    //
    bool common_position(false);
    if (n_files == 1) {
        common_position = true;
    }

    float * pPixBuffer = Buff.get_read_buffer();
    size_t pix_buffer_size = Buff.pix_buf_size();
    size_t ii(0);

    for (size_t n_bin = first_bin; n_bin < nBinsTotal; n_bin++) {
        size_t cell_pix = 0;
        // estimate amount of space all files contribute into current cell.
        for (size_t i = 0; i < n_files; i++) {
            fileReaders[i].get_pix_map().get_npix_for_bin(n_bin, pix_start_num, npix);
            cell_pix += npix;
        }
        // Number of bins to read pixels to
        n_bins_processed = n_bin;
        if (nBinBuffer) {
            nBinBuffer[n_bin] = cell_pix;
        }

        if (cell_pix == 0)continue;

        if (cell_pix + n_buf_pixels > pix_buffer_size) {
            if (n_bins_processed - first_bin == 0) {
                if (n_buf_pixels == 0) {
                    pPixBuffer = Buff.get_read_buffer(cell_pix);
                    pix_buffer_size = Buff.pix_buf_size();
                }
                else { // problem occurs if we have range of pixel read into buffer and written to target and then one large pixel. Currently we can only write complete pixels ranges
                    Buff.set_interrupted("==>output pixels buffer is too small to accommodate a single bin. Increase the size of output pixels buffer");
                    break;
                }
            }
            else { // 
                n_bins_processed--;
                break;
            }
        }

        // read pixels from all contributing files into the space, intended for target bin
        for (size_t i = 0; i < n_files; i++) {
            fileReaders[i].get_pix_for_bin(n_bin, pPixBuffer, n_buf_pixels,
                pix_start_num, npix, common_position);
            n_buf_pixels += npix;
        }
    }
    // unlocks read buffer too
    Buff.set_and_lock_write_buffer(n_buf_pixels, n_bins_processed + 1);
}

void nsqw_pix_reader::finish_read_jobs() {
    // cancel read jobs (if any). Need to investigate why this does not properly done in the destructor.
    for (size_t i = 0; i < this->fileReaders.size(); i++) {
        fileReaders[i].finish_read_job();
    }

}