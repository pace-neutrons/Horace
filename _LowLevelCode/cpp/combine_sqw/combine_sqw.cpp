#include "combine_sqw.h"
#include <algorithm>
#include <numeric>
#include <iomanip>
#include <chrono>

enum InputArguments {
    inFileParams,
    outFileParams,
    programSettings,
    N_INPUT_Arguments
};
enum OutputArguments { // unique output arguments,
    pix_data,
    npix_in_bins,
    pix_info,
    N_OUTPUT_Arguments
};


// map used to process input file(s) parameters
const std::map<std::string, int> fileParameters::fileParamNames = {
    {std::string("file_name"),0 },
    {std::string("npix_start_pos"),1},
    {std::string("pix_start_pos"),2},
    {std::string("file_id"),3},
    {std::string("nbins_total"),4}
};
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//
//
float *const exchange_buffer::get_read_buffer(const size_t changed_buf_size) {

    //this->read_lock.lock();
    if (changed_buf_size != 0) {
        this->buf_size = changed_buf_size*PIX_SIZE;
    }

    if (this->read_buf.size() != this->buf_size)
        this->read_buf.resize(this->buf_size);

    return &read_buf[0];
}

/* Initiate access to write buffer when read operation is completed and set up the write buffer parameters
@param nPixel        -- number of pixels to write
@param nBinProcessed -- number of bins processed up to this moment of time. Indicates the stage of the combine job
                        as job finishes when nBinsProcessed=nBinsTotal  */
void exchange_buffer::set_and_lock_write_buffer(const size_t nPixels, const size_t nBinsProcessed) {

    // try lock in case write have not been completed yet.
    std::lock_guard<std::mutex> lock(this->write_lock);

    this->write_buf.swap(this->read_buf);
    this->n_read_pixels = nPixels;
    this->n_read_pix_total += nPixels;
    this->n_bins_processed = nBinsProcessed;
    // last bins may not contain pixels so set write allowed instead of npix>0
    this->write_allowed = true;
    this->data_ready.notify_one();

}

/* Give write thread access to the write buffer. Returns NULL if no pixels are currently in buffer and locks
   write buffer, which has to be unlocked later. */
char * const exchange_buffer::get_write_buffer(size_t &n_pix_to_write, size_t &n_bins_processed) {

    std::unique_lock<std::mutex> lock(this->exchange_lock);
    this->data_ready.wait(lock, [this]() {return (this->write_allowed); });

    n_bins_processed = this->n_bins_processed;
    if (this->n_read_pixels > 0) {
        this->write_lock.lock();
        n_pix_to_write = this->n_read_pixels;
        return reinterpret_cast<char * const>(&write_buf[0]);
    }
    else {
        n_pix_to_write = 0;
        return NULL;
    }

}
/* Indicates the end of single write-pixels operations and unlocks write buffer indicating that the data
in the buffer can be discarded */
void exchange_buffer::unlock_write_buffer() {

    this->write_allowed = false;
    this->n_read_pixels = 0;
    this->write_lock.unlock();
}
/* Verifies if logging is due and send messages to logging thread to report progress.
Also verifies if operations should be terminated as user pressed CTRL-C */
void exchange_buffer::check_log_and_interrupt() {
    if (this->n_bins_processed >= this->break_point) {
        time_t t_end;
        time(&t_end);
        double seconds = difftime(t_end, this->t_prev);
        this->t_prev = t_end;
        if (seconds > 30. || seconds < 10.) {
            // want to see logging each 15 second
            double speed = double(break_step) / seconds;
            size_t step = int(15 * speed);
            if (step < 1)step = 1;
            this->break_step = step;
        }

        this->break_point += this->break_step;
        this->do_logging = true;
        this->logging_ready.notify_one();

        if (utIsInterruptPending()) {
            this->set_interrupted("==> C-code interrupted by CTRL-C");
            //mexWarnMsgIdAndTxt("COMBINE_SQW:interrupted", "==> C-code interrupted by CTRL-C");
            return;
        }
    }

}
/* Sets internal variables of exchange buffer to state, indicating end of operations*/
void exchange_buffer::set_write_job_completed() {
    this->do_logging = true;
    // release possible logging
    this->logging_ready.notify_one();
    this->write_job_completed = true;
}
/* runs on main thread and prints log messages when instructed by write thread
 (due to the problem with Matlab if logging is run on worker thread) */
void exchange_buffer::print_log_meassage(int log_level) {


    if (log_level > 0) {
        std::clock_t c_end = std::clock();
        time_t t_end;
        time(&t_end);
        double seconds = difftime(t_end, t_start);
        std::stringstream buf;
        buf << "MEX::COMBINE_SQW: Completed " << std::setw(4) << std::setprecision(3)
            << float(100 * n_bins_processed) / float(num_bins_to_process)
            << "%  of task in " << std::setprecision(0) << std::setw(6) << int(seconds) << " sec; CPU time: "
            << (c_end - c_start) / CLOCKS_PER_SEC << " sec\n";

        mexPrintf("%s", buf.str().c_str());
        //mexEvalString("drawnow");
        mexEvalString("pause(.002);");
        //std::this_thread::sleep_for(std::chrono::milliseconds(2));

    }
    this->do_logging = false;


}

/* runs on main thread and prints log messages about end of the job
(due to the problem with Matlab if logging is run on worker thread) */
void exchange_buffer::print_final_log_mess(int log_level)const {

    if (log_level > -1) {
        std::clock_t c_end = std::clock();
        time_t t_end;
        time(&t_end);
        double seconds = difftime(t_end, t_start);

        std::stringstream buf;
        buf << "MEX::COMBINE_SQW: Completed combining file with " << n_bins_processed << " bins and " << n_read_pix_total
            << " pixels\n"
            << " Spent: " << std::setprecision(0) << std::setw(6) << int(seconds) << " sec; CPU time: " << (c_end - c_start) / CLOCKS_PER_SEC << " sec\n";
        mexPrintf("%s", buf.str().c_str());
    }

}

//--------------------------------------------------------------------------------------------------------------------
//----------- PIX WRITER ---------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/*Initialize writer parameters
Input:
@param fpar           -- input parameters describing the output file
@param n_bins2process -- number of bins to process (combine)
*/
void sqw_pix_writer::init(const fileParameters &fpar, const size_t n_bins2process) {

    this->num_bins_to_process = n_bins2process;
    this->filename = fpar.fileName;
    this->h_out_sqw.open(fpar.fileName, std::ofstream::binary | std::ofstream::out | std::ofstream::app);
    if (!this->h_out_sqw.is_open()) {
        std::string err = "SQW_PIX_WRITER: Can not open target sqw file: " + fpar.fileName;
        mexErrMsgTxt(err.c_str());
    }

    this->last_pix_written = 0;
    this->pix_array_position = fpar.pix_start_pos;
    this->nbin_position = fpar.nbin_start_pos;
}
/* Operation which runs on separate thread and writes pixels */
void sqw_pix_writer::run_write_pix_job() {

    size_t n_bins_processed(0);

    while (n_bins_processed < this->num_bins_to_process && !Buff.is_interrupted()) {
        size_t n_pix_to_write;
        // this locks until read completed unless read have not been started
        const char *buf = Buff.get_write_buffer(n_pix_to_write, n_bins_processed);
        if (!buf) {
            std::chrono::milliseconds sleepDuration(250);
            std::this_thread::sleep_for(sleepDuration);
            continue;
        }

        size_t length = n_pix_to_write*PIX_BLOCK_SIZE_BYTES;

        this->write_pixels(buf, length);
        last_pix_written += n_pix_to_write;

        Buff.check_log_and_interrupt();
        Buff.unlock_write_buffer();
    }
    Buff.set_write_job_completed();
}
/* Write chunk on pixels stored in write buffer */
void sqw_pix_writer::write_pixels(const char *buffer, size_t length) {
    //
    size_t pix_pos = pix_array_position + last_pix_written*PIX_BLOCK_SIZE_BYTES;
    //
    this->h_out_sqw.seekp(pix_pos);
    //
    this->h_out_sqw.write(buffer, length);
    //

}
//
sqw_pix_writer::~sqw_pix_writer() {
    this->h_out_sqw.close();
}
//--------------------------------------------------------------------------------------------------------------------
//---------------- BINS IN MEMORY ------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
void cells_in_memory::init(const std::string &full_file_name, size_t bin_start_pos, size_t n_tot_bins, size_t BufferSize, bool use_multithreading) {

    this->full_file_name = full_file_name;

#ifdef STDIO
    h_data_file_bin = fopen(full_file_name.c_str(), "rb");
    bin_buffer.fpos = ftell(h_data_file_bin);
    if (!h_data_file_bin) {
        std::string error("Can not open file: ");
        error += full_file_name;
        mexErrMsgTxt(error.c_str());
    }
#else
    h_data_file_bin.open(full_file_name, std::ios::in | std::ios::binary);
    if (!h_data_file_bin.is_open()) {
        std::string error("Can not open file: ");
        error += full_file_name;
        mexErrMsgTxt(error.c_str());
    }
#endif


    BUF_SIZE_STEP = BufferSize;
    BIN_BUF_SIZE = 2 * BUF_SIZE_STEP;

    nbin_buffer.resize(BIN_BUF_SIZE, 0);
    pix_pos_in_buffer.resize(BIN_BUF_SIZE, 0);
    nTotalBins = n_tot_bins;
    binFileStartPos = bin_start_pos;
    // separate read job
    this->use_multithreading = use_multithreading;
    if (this->use_multithreading) {
        this->nbin_read_buffer.resize(BIN_BUF_SIZE);
        std::thread read_bins([this]() {this->read_bins_job(); });
        read_bins_job_holder.swap(read_bins);
    }
}
//
cells_in_memory::~cells_in_memory() {
    if (this->use_multithreading) {
        this->bin_read_lock.lock();
        this->read_completed = true;
        // finish incomplete read job if it has not been finished naturally
        this->nbins_read = false;
        this->read_bins_needed.notify_one();
        this->bin_read_lock.unlock();

        read_bins_job_holder.join();
    }
#ifdef STDIO
    fclose(h_data_file_bin);
#else
    h_data_file_bin.close();
#endif

}

/* return number of pixels this bin buffer describes */
size_t cells_in_memory::num_pix_described(size_t bin_number)const {
    size_t loc_bin = bin_number - this->num_first_buf_bin;
    size_t end = this->buf_end - 1;
    size_t num_pix_start = pix_pos_in_buffer[loc_bin];
    return pix_pos_in_buffer[end] + nbin_buffer[end] - num_pix_start;

}

/* return the number of pixels described by the bins fitting the buffer of the size specified*/
size_t cells_in_memory::num_pix_to_fit(size_t bin_number, size_t buf_size)const {
    size_t n_bin = bin_number - num_first_buf_bin;
    size_t shift = pix_pos_in_buffer[n_bin];
    size_t val = buf_size + shift;
    auto begin = pix_pos_in_buffer.begin() + n_bin;
    auto end = pix_pos_in_buffer.begin() + this->buf_end;
    auto it = std::upper_bound(begin, end, val);

    --it; // went step back to value smaller then the one exceeding the threshold
    if (it == begin) {
        return this->nbin_buffer[n_bin];
    }
    else {
        return *it - shift;
    }


}


/** loads bin information for a pixel, which does not have this information loaded 
*
* get number of pixels, stored in the bin and the position
*  of these pixels within pixel array
*
*@param bin_number -- number of bin to get pixel information for
*pix_pos_in_buffer
* Returns:
* pix_start_num -- initial position of the bin pixels in the pixels array
* num_bin_pix   -- number of pixels, stored in this bin
*/
void cells_in_memory::get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix) {

    //
    if (bin_number >= this->buf_nbin_end) {
        this->read_all_bin_info(bin_number); // Advance cache
    }
    else if (bin_number < this->num_first_buf_bin) { // cache miss
        this->num_first_buf_bin = 0;
        this->buf_nbin_end = 0;
        this->read_all_bin_info(bin_number);
    }
    size_t  num_bin_in_buf = bin_number - this->num_first_buf_bin;
    num_bin_pix = this->nbin_buffer[num_bin_in_buf];
    pix_start_num = this->pix_before_buffer + this->pix_pos_in_buffer[num_bin_in_buf];

}
/* read bin info to describe sufficient number of pixels in buffer
   bin number is already in the bin buffer and we want to read additional bins
   describing more pixels  */
void cells_in_memory::expand_pixels_selection(size_t bin_number) {
    if (this->buf_nbin_end == this->nTotalBins) {
        return;
    }
    size_t  num_bin_in_buf = bin_number - this->num_first_buf_bin;
    // move bin buffer into new position
    this->num_first_buf_bin = bin_number;
    this->pix_before_buffer += this->pix_pos_in_buffer[num_bin_in_buf];
    for (size_t i = num_bin_in_buf; i < this->buf_end; i++) {
        this->nbin_buffer[i - num_bin_in_buf] = this->nbin_buffer[i];
    }
    size_t buf_start = this->buf_end - num_bin_in_buf;
    size_t buf_nbin_end, buf_end;
    if(this->use_multithreading){
        size_t  num_buf_bins;
        calc_buf_range(bin_number, buf_start, this->BUF_SIZE_STEP, num_buf_bins, buf_nbin_end, buf_end);
        if (bin_number+ buf_start == this->n_first_rbuf_bin) {
            std::unique_lock<std::mutex> lock(this->exchange_lock);
            this->bins_ready.wait(lock, [this]() {return this->nbins_read; });
            // copy bin info from read buffer to nbin buffer
            for (size_t i = 0; i <  num_buf_bins; i++) {
                this->nbin_buffer[buf_start+i] = this->nbin_read_buffer[i];
            }
            // set up parameters for next read job on separate thread
            this->bin_read_lock.lock();
            this->n_first_rbuf_bin = buf_nbin_end;
            this->nbins_read = false;
            this->read_bins_needed.notify_one();
            this->bin_read_lock.unlock();

        }else{ // should never happen
            read_bins(bin_number, buf_start, this->BUF_SIZE_STEP, this->nbin_buffer, buf_nbin_end, buf_end);
        }

    }else{
        read_bins(bin_number, this->buf_end - num_bin_in_buf, this->BUF_SIZE_STEP, this->nbin_buffer, buf_nbin_end, buf_end);
    }
    record_read_bins(bin_number, buf_nbin_end, buf_end, this->nbin_buffer);

}
//
void cells_in_memory::read_all_bin_info(size_t bin_number) {

    if (bin_number < this->num_first_buf_bin) { //cash missed, start reading afresh
        this->num_first_buf_bin = 0;
        this->buf_nbin_end = 0;
        this->pix_before_buffer = 0;
    }
    //------------------------------------------------------------------------------
    size_t firstNewBin = this->buf_nbin_end;
    size_t n_strides = (bin_number - firstNewBin) / this->BUF_SIZE_STEP + 1;
    for (size_t i = 0; i < n_strides; i++) {
        size_t start_bin = firstNewBin + i*this->BUF_SIZE_STEP;
        // store pixel info for all previous bins
        size_t end = this->buf_end - 1;
        this->pix_before_buffer += (this->pix_pos_in_buffer[end] + this->nbin_buffer[end]);
        size_t buf_nbin_end, buf_end;
        if (this->use_multithreading) {
            if (this->n_first_rbuf_bin != start_bin) { // cash missed
                this->bin_read_lock.lock();
                this->n_first_rbuf_bin = start_bin;
                this->nbins_read = false;
                this->read_bins_needed.notify_one();
                this->bin_read_lock.unlock();
            }
            // retrieve results
            std::unique_lock<std::mutex> lock(this->exchange_lock);
            this->bins_ready.wait(lock, [this]() {return this->nbins_read; });

            this->bin_read_lock.lock();
            buf_nbin_end = this->rbuf_nbin_end;
            buf_end = this->rbuf_end;
            this->nbin_read_buffer.swap(this->nbin_buffer);
            // set up parameters for next read job
            this->n_first_rbuf_bin = buf_nbin_end;
            this->nbins_read = false;
            this->read_bins_needed.notify_one();

            this->bin_read_lock.unlock();


        }
        else {
            read_bins(start_bin, 0, this->BUF_SIZE_STEP, this->nbin_buffer, buf_nbin_end, buf_end);
        }
        record_read_bins(start_bin, buf_nbin_end, buf_end, this->nbin_buffer);
    }
}
void cells_in_memory::read_bins_job() {

    std::unique_lock<std::mutex> lock(this->exchange_lock);

    while (!this->read_completed) {
        this->read_bins_needed.wait(lock, [this]() {return !this->nbins_read; });
        if(this->read_completed)break;

        this->bin_read_lock.lock();

        if (this->n_first_rbuf_bin < this->nTotalBins) {
            read_bins(this->n_first_rbuf_bin, 0, this->BUF_SIZE_STEP, this->nbin_read_buffer, this->rbuf_nbin_end, this->rbuf_end);
        }else{
            this->rbuf_nbin_end = this->nTotalBins;
            this->rbuf_end     = 0;
        }
        this->nbins_read = true;
        this->bin_read_lock.unlock();

        this->bins_ready.notify_one();
    }

}
//
void cells_in_memory::calc_buf_range(size_t num_bin, size_t buf_start,size_t buf_size, size_t &tot_num_bins_to_read, size_t & bin_end, size_t & buf_end) {

    bin_end = num_bin + buf_size + buf_start;

    if (bin_end > nTotalBins) {
        bin_end = nTotalBins;
    }
    else if (bin_end + buf_size >= nTotalBins) { // finish reading extended buffer as all bins fit extended buffer 
        bin_end = nTotalBins;
    }

    tot_num_bins_to_read = bin_end - num_bin - buf_start;
    if (tot_num_bins_to_read > this->BIN_BUF_SIZE) {
        tot_num_bins_to_read = this->BIN_BUF_SIZE;
        bin_end = num_bin + this->BIN_BUF_SIZE;
    }
    buf_end = buf_start + tot_num_bins_to_read;

}
/*
* Method to read block of information about number of pixels
* stored according to bins starting with the bin number specified
* as input
*
* num_loc_bin -- the bin within a block to read into the buffer
Returns:
absolute number of last bin read into the buffer.
*/
void cells_in_memory::read_bins(size_t num_bin, size_t buf_start, size_t buf_size,
    std::vector<uint64_t> &inbuf, size_t &bin_end, size_t &buf_end) {

    if (num_bin >= this->nTotalBins) {
        mexErrMsgTxt("READ_SQW::read_bins =>Accessing bin out of bin range");
    }

    size_t  tot_num_bins_to_read;
    calc_buf_range(num_bin, buf_start,buf_size, tot_num_bins_to_read,bin_end,buf_end);

    std::streamoff bin_pos = binFileStartPos + (num_bin + buf_start)*BIN_SIZE_BYTES;
    //
    std::lock_guard<std::mutex> lock(this->io_lock);
#ifdef STDIO
    uint64_t * buffer = reinterpret_cast<uint64_t *>(&nbin_buffer[buf_start]);
    std::streamoff length = tot_num_bins_to_read;

    bin_pos -= this->fpos;
    auto err = fseek(fReader, bin_pos, SEEK_CUR);
    if (err) {
        mexErrMsgTxt("COMBINE_SQW:read_bins seek error ");
    }
    size_t nBytes = fread(buffer, BIN_SIZE_BYTES, tot_num_bins_to_read, fReader);
    if (nBytes != tot_num_bins_to_read) {
        mexErrMsgTxt("COMBINE_SQW:read_bins Read error, can not read the number of bytes requested");
    }
    this->fpos = ftell(fReader);
#else
    std::streamoff length = tot_num_bins_to_read*BIN_SIZE_BYTES;
    char * buffer = reinterpret_cast<char *>(&inbuf[buf_start]);

    h_data_file_bin.seekg(bin_pos);
    std::string err;
    try {
        h_data_file_bin.read(buffer, length);
    }
    catch (std::ios_base::failure &e) {
        err = "COMBINE_SQW:read_bins read error: " + std::string(e.what());
    }
    catch (...) {
        err = "COMBINE_SQW:read_bins unhandled read error.";

    }
    if (err.size() > 0) {
        mexErrMsgTxt(err.c_str());
    }
#endif

}
/*Store results of the read operation within the class memory*/
void  cells_in_memory::record_read_bins(size_t num_bin, size_t buf_nbin_end, size_t buf_end, const std::vector<uint64_t> &buffer) {
    // Store results
    this->num_first_buf_bin = num_bin;
    this->buf_nbin_end = buf_nbin_end;
    this->buf_end = buf_end;


    this->pix_pos_in_buffer[0] = 0;
    for (size_t i = 1; i < buf_end; i++) {
        this->pix_pos_in_buffer[i] = this->pix_pos_in_buffer[i - 1] + this->nbin_buffer[i - 1];
    }

    if (this->buf_nbin_end == this->nTotalBins) {
        size_t last = buf_end-1;
        this->max_num_of_pixels = this->pix_before_buffer+ this->pix_pos_in_buffer[last]+ this->nbin_buffer[last];
    }

}

//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//
void pix_reader::run_read_job() {
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
        //------------Logging and interruptions ---
        n_pixels_processed += n_buf_pixels;
    }

}
void pix_reader::read_pix_info(size_t &n_buf_pixels, size_t &n_bins_processed, uint64_t *nBinBuffer) {

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
        if(n_bin>=471822){
            ii++;
        }

        for (size_t i = 0; i < n_files; i++) {
            fileReaders[i].get_npix_for_bin(n_bin, pix_start_num, npix);
            cell_pix += npix;
        }

        n_bins_processed = n_bin;
        if (nBinBuffer) {
            nBinBuffer[n_bin] = cell_pix;
        }

        if (cell_pix == 0)continue;

        if (cell_pix + n_buf_pixels > pix_buffer_size) {
            if (n_bins_processed == 0) {
                if (n_buf_pixels == 0) {
                    pPixBuffer = Buff.get_read_buffer(cell_pix);
                    pix_buffer_size = Buff.pix_buf_size();
                }
                else {
                    Buff.set_interrupted("==>output pixels buffer is to small to accommodate single bin. Increase the size of output pixels buffer");
                    break;
                }
            }
            else {
                n_bins_processed--;
                break;
            }
        }


        for (size_t i = 0; i < n_files; i++) {
            fileReaders[i].get_pix_for_bin(n_bin, pPixBuffer, n_buf_pixels,
                pix_start_num, npix, common_position);
            n_buf_pixels += npix;
        }
    }
    // unlocks read buffer too
    Buff.set_and_lock_write_buffer(n_buf_pixels, n_bins_processed + 1);
}
//--------------------------------------------------------------------------------------------------------------------
//--------- MAIN COMBINE JOB -----------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/* combine range of input sqw files into single output sqw file */
void combine_sqw(ProgParameters &param, std::vector<sqw_reader> &fileReaders, const fileParameters &outPar) {

    exchange_buffer Buff(param.pixBufferSize, param.totNumBins, param.num_log_ticks);

    pix_reader Reader(param, fileReaders, Buff);

    sqw_pix_writer pixWriter(Buff);
    pixWriter.init(outPar, param.totNumBins);

    int log_level = param.log_level;


    std::thread reader([&Reader]() {
        Reader.run_read_job();
    });
    std::thread writer([&pixWriter]() {
        pixWriter.run_write_pix_job();
    });

    std::mutex log_mutex;
    while (!Buff.is_write_job_completed()) {

        std::unique_lock<std::mutex> l(log_mutex);
        Buff.logging_ready.wait(l, [&Buff]() {return Buff.do_logging; });

        Buff.print_log_meassage(log_level);
    }

    reader.join();
    writer.join();

    Buff.print_final_log_mess(log_level);


    if (Buff.is_interrupted()) {
        mexErrMsgIdAndTxt("MEX_COMBINE_SQW:interrupted", Buff.error_message.c_str());
    }
}
//--------------------------------------------------------------------------------------------------------------------
//-----------  SQW READER (FOR SINGLE SQW FILE)  ---------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
sqw_reader::sqw_reader(size_t working_buf_size) :
    cells_in_memory(working_buf_size),
    npix_in_buf_start(0), buf_pix_end(0),
    PIX_BUF_SIZE(working_buf_size), change_fileno(false), fileno(true),
    use_multithreading_pix(true),pix_read(false), pix_read_job_completed(false), n_first_buf_pix(0)
{}

sqw_reader::~sqw_reader() {
    if (this->use_multithreading_pix) {
        this->pix_read_lock.lock();

        this->pix_read_job_completed = true;
        // finish incomplete read job if it has not been finished naturally
        this->pix_read = false;
        this->read_pix_needed.notify_one();
        this->pix_read_lock.unlock();

        read_pix_job_holder.join();
    }
#ifdef STDIO
    fclose(h_data_file_pix);
#else
    h_data_file_pix.close();
#endif

}


sqw_reader::sqw_reader(const fileParameters &fpar, bool changefileno, bool fileno_provided, size_t working_buf_size)
    : sqw_reader(working_buf_size)
{
    this->init(fpar, changefileno, fileno_provided, working_buf_size);
}
//
void sqw_reader::init(const fileParameters &fpar, bool changefileno, bool fileno_provided, size_t working_buf_size, int multithreading_settings) {
    bool bin_multithreading;
   switch(multithreading_settings){
    case(0):
        bin_multithreading = false;
        use_multithreading_pix=false;
    break;
    case(1):
        bin_multithreading = true;
        use_multithreading_pix = true;
    break;
    case(2):
        bin_multithreading = true;
        use_multithreading_pix = false;
    break;
    case(3) :
        bin_multithreading = false;
        use_multithreading_pix = true;
        break;
    default:
        mexErrMsgTxt("Input multithreading parameter should be 0 (no multithreading) 1 (multithreading)"
        ", 2 (debug mode, only bin thread used for reading ) or 3 (debug mode , use pix read thread, and disable bin reading)");
   }

    cells_in_memory::init(fpar.fileName, fpar.nbin_start_pos, fpar.total_NfileBins, working_buf_size, bin_multithreading);
#ifdef STDIO
    h_data_file_pix = fopen(full_file_name.c_str(), "rb");
    bin_buffer.fpos = ftell(h_data_file_pix);
    if (!h_data_file_pix) {
        std::string error("Can not open file: ");
        error += full_file_name;
        mexErrMsgTxt(error.c_str());
    }
#else
    h_data_file_pix.open(this->full_file_name, std::ios::in| std::ios::binary);
    if (!h_data_file_pix.is_open()) {
        std::string error("Can not open file: ");
        error += this->full_file_name;
        mexErrMsgTxt(error.c_str());
    }
#endif


    this->fileDescr = fpar;
    this->change_fileno = changefileno;
    this->fileno = fileno_provided;

    this->PIX_BUF_SIZE = working_buf_size;
    this->pix_buffer.resize(PIX_BUF_SIZE*PIX_SIZE);

    if (this->use_multithreading_pix) {
        this->thread_pix_buffer.resize(PIX_BUF_SIZE*PIX_SIZE);
        std::thread read_pix([this]() {this->read_pixels_job(); });
        read_pix_job_holder.swap(read_pix);
    }

}


/* return pixel information for the pixels stored in the bin
* @param bin_number  -- the bin number to get results for
* @param pix_info    -- the pointer to the pixel buffer where results should be placed
* @param buf_position-- position in the pix buffer where pixels should be stored
* @param pix_start_num      --calculated first bin's pixel number in the linear array of all pixels
*                             (on hdd or Horace pix array)
* @param num_bin_pix         -- number of pixels in the bin requested
* @param position_is_defined -- if true, pix_start_num and num_bin_pix are already calculated and used as input,
*                               if false, they are calculated internally and returned.
*
* @returns pix_info -- fills block of size = [9*num_bin_pix] containing pixel info
*                      for the pixels, belonging to the bin requested. The data start at buf_position
*/
void sqw_reader::get_pix_for_bin(size_t bin_number, float *const pix_info, size_t buf_position,
    size_t &pix_start_num, size_t &num_bin_pix, bool position_is_defined) {

    if (!position_is_defined) {
        this->get_npix_for_bin(bin_number, pix_start_num, num_bin_pix);
    }
    if (num_bin_pix == 0) return;

    if (pix_start_num < this->npix_in_buf_start || pix_start_num + num_bin_pix > this->buf_pix_end) {
        this->read_pixels(bin_number, pix_start_num);
    }

    size_t out_buf_start = buf_position*PIX_SIZE;
    size_t in_buf_start = (pix_start_num - this->npix_in_buf_start)*PIX_SIZE;
    for (size_t i = 0; i < num_bin_pix*PIX_SIZE; i++) {
        pix_info[out_buf_start + i] = pix_buffer[in_buf_start + i];
    }

}
/*
% read pixels information, located in the bin with the number requested
%
% read either all pixels in the buffer or at least the number
% specified
%
*/
void sqw_reader::read_pixels(size_t bin_number, size_t pix_start_num) {

    //check if we have loaded enough bin information to read enough
    //pixels and return enough pixels to fill - in buffer.Expand or
    // shrink if necessary
    // if we are here, nbin buffer is intact and pixel buffer is
    // invalidated
    size_t num_pix_to_read = this->check_binInfo_loaded_(bin_number,true, pix_start_num);
    if (this->use_multithreading_pix) {
   
        std::unique_lock<std::mutex> lock(this->pix_exchange_lock);
        this->pix_ready.wait(lock, [this]() {return this->pix_read; });

        this->thread_pix_buffer.swap(this->pix_buffer);
        this->n_first_buf_pix=pix_start_num+ num_pix_to_read;
        this->pix_read = false;
        this->read_pix_needed.notify_one();

    }else{
        read_pix_io(pix_start_num,this->pix_buffer,num_pix_to_read);
    }
    this->npix_in_buf_start = pix_start_num;
    this->buf_pix_end = this->npix_in_buf_start + num_pix_to_read;

}
//
void sqw_reader::read_pixels_job() {

    std::unique_lock<std::mutex> lock(this->pix_exchange_lock);

    while (!this->pix_read_job_completed) {
        this->read_pix_needed.wait(lock, [this]() {return !this->pix_read; });
        if (this->pix_read_job_completed)break;

        this->pix_read_lock.lock();
        size_t n_pix_to_read = PIX_BUF_SIZE;
        if (this->n_first_buf_pix + n_pix_to_read >= this->max_num_of_pixels) {
            n_pix_to_read = this->max_num_of_pixels- this->n_first_buf_pix;
        }

        if (n_pix_to_read>0) {
            read_pix_io(this->n_first_buf_pix, thread_pix_buffer, n_pix_to_read);
        }
 
        this->pix_read = true;
        this->pix_read_lock.unlock();

        this->pix_ready.notify_one();
    }

}
void sqw_reader::read_pix_io(size_t pix_start_num, std::vector<float> &pix_buffer, size_t num_pix_to_read) {

    std::streamoff pix_pos = this->fileDescr.pix_start_pos + pix_start_num*PIX_BLOCK_SIZE_BYTES;
    //std::lock_guard<std::mutex> lock(this->io_lock); <-- not necessary for separate file access
#ifdef STDIO
    if (num_pix_to_read == 0) {
        return;
    }
    void * buffer = &pix_buffer[0];

    pix_pos -= this->bin_buffer.fpos;
    auto err = fseek(h_data_file_pix, pix_pos, SEEK_CUR);
    if (err) {
        mexErrMsgTxt("COMBINE_SQW:read_pixels seek error");
    }
    size_t nBytes = fread(buffer, PIX_BLOCK_SIZE_BYTES, num_pix_to_read, h_data_file_pix);
    if (nBytes != num_pix_to_read) {
        mexErrMsgTxt("COMBINE_SQW:read_pixels Read error, can not read the number of pixels requested");
    }
    this->bin_buffer.fpos = ftell(h_data_file_pix);

#else
    char * buffer = reinterpret_cast<char *>(&pix_buffer[0]);
    size_t length = num_pix_to_read*PIX_BLOCK_SIZE_BYTES;

    std::string err;
    h_data_file_pix.seekg(pix_pos);
    try {
        h_data_file_pix.read(buffer, length);
    }
    catch (std::ios_base::failure &e) {
        err = "COMBINE_SQW:read_pixels read error: " + std::string(e.what());
    }
    catch (...) {
        err = "COMBINE_SQW:read_pixels unhandled read error. ";
    }
    if (err.size() > 0) {
        mexErrMsgTxt(err.c_str());
    }
    size_t n_read_pixels = num_pix_to_read;
    if (h_data_file_pix.eof()) {
        n_read_pixels = h_data_file_pix.gcount()/ PIX_BLOCK_SIZE_BYTES;
        h_data_file_pix.clear();
    }
#endif
    if (this->change_fileno) {
        for (size_t i = 0; i < n_read_pixels; i++) {
            if (fileno) {
                pix_buffer[4 + i * 9] = float(this->fileDescr.file_id);
            }
            else {
                pix_buffer[4 + i * 9] += float(this->fileDescr.file_id);
            }
        }

    }


}
/*
% verify bin information loaded to memory and identify sufficient number
% of pixels to fill - in pixels buffer.
%
% read additional bin information if not enough bins have been
% processed
%
*/
size_t sqw_reader::check_binInfo_loaded_(size_t bin_number, bool extend_bin_buffer,size_t pix_start_num) {

    // assume bin buffer is intact with bin_number loaded and get number of pixels this bin buffer describes
    size_t num_pix_to_read = this->num_pix_described(bin_number);

    if (num_pix_to_read > this->PIX_BUF_SIZE) {
        num_pix_to_read = this->num_pix_to_fit(bin_number, this->PIX_BUF_SIZE);
        //
        if (num_pix_to_read > this->PIX_BUF_SIZE ) {  // single bin still contains more pixels then pix buffer
            this->PIX_BUF_SIZE = num_pix_to_read;
            // pix buffer should be extended
            this->pix_buffer.resize(this->PIX_BUF_SIZE*PIX_SIZE);
            if(this->use_multithreading_pix){
                this->pix_read_lock.lock();

                this->thread_pix_buffer.resize(PIX_BUF_SIZE*PIX_SIZE);
                this->n_first_buf_pix = pix_start_num;
                this->pix_read = false;
                this->read_pix_needed.notify_one();

                this->pix_read_lock.unlock();

            }
        }
    }
    else { // bin buffer should be extended
        if (extend_bin_buffer) {
            this->expand_pixels_selection(bin_number);
            return check_binInfo_loaded_(bin_number, false, pix_start_num);
        }

    }
    return num_pix_to_read;

}

//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/* Convert input Matlab structure with the fields, necessary to describe input & output sqw file into
   fileParameters class*/
fileParameters::fileParameters(const mxArray *pFileParam) {

    mwSize total_num_of_elements = mxGetNumberOfElements(pFileParam);
    mwSize number_of_fields = mxGetNumberOfFields(pFileParam);

    if (total_num_of_elements != 1) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw ==> each field of file parameter structure should contain only one element, not: " << (short)total_num_of_elements << std::endl;
        mexErrMsgTxt(buf.str().c_str());
    }
    if (number_of_fields > 5) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw ==> each file parameter structure should contain no more then 5 fields but have: " << (short)number_of_fields << std::endl;
        mexErrMsgTxt(buf.str().c_str());
    }

    for (int field_index = 0; field_index < number_of_fields; field_index++) {
        const std::string FieldName(mxGetFieldNameByNumber(pFileParam, field_index));
        int ind(-1);
        try {
            ind = fileParamNames.at(FieldName);
        }
        catch (std::out_of_range) {
            std::string err = "ERROR::combine_sqw ==> file parameters structure contains unknown parameter: " + FieldName;
            mexErrMsgTxt(err.c_str());
        }

        const mxArray *pFieldCont = mxGetFieldByNumber(pFileParam, 0, field_index);
        switch (ind) {
        case(0) : {
            fileName = std::string(mxArrayToString(pFieldCont));
            break;
        }
        case(1) : {
            double *pnBin_start = mxGetPr(pFieldCont);
            nbin_start_pos = int64_t(pnBin_start[0]);
            break;
        }
        case(2) : {
            double *pPixStart = mxGetPr(pFieldCont);
            pix_start_pos = long(pPixStart[0]);
            break;
        }
        case(3) : {
            double *pFileID = mxGetPr(pFieldCont);
            file_id = int(pFileID[0]);
            break;
        }
        case(4) : {
            double *pNpixTotal = mxGetPr(pFieldCont);
            total_NfileBins = size_t(pNpixTotal[0]);
            break;
        }
        default: {
            mexWarnMsgTxt("combine_sqw: unknown parameter (should never happen)");
        }
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision::      $ ($Date::                                              $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }
    //--------------------------------------------------------
    //-------   PROCESS PARAMETERS   -------------------------
    //--------------------------------------------------------

    bool debug_file_reader(false);
    size_t n_prog_params(4);
    // if pixel's run numbers id should be renamed and in which manned
    bool change_fileno(false), fileno_provided(true);
    size_t read_buf_size(4096);
    //* Check for proper number of arguments. */
    {
        if (nrhs != N_INPUT_Arguments) {
            std::stringstream buf;
            buf << "ERROR::combine_sqw needs " << (short)N_INPUT_Arguments << " but got " << (short)nrhs
                << " input arguments and " << (short)nlhs << " output argument(s)\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        if (nlhs == N_OUTPUT_Arguments) {
            debug_file_reader = true;
        }
        n_prog_params = mxGetN(prhs[programSettings]);
        if (!(n_prog_params == 4 || n_prog_params == 8 || n_prog_params == 9)) {
            std::string err = "ERROR::combine_sqw => array of program parameter settings (input N 3) should have  4 or 8 or 9 elements but got: " +
                std::to_string(n_prog_params);
            mexErrMsgTxt(err.c_str());
        }

    }
    /********************************************************************************/
    /* retrieve input parameters */
    // Pointer to list of file parameters to process. The parameters may change as
    // module takes more from Matlab code
    auto pParamList = prhs[inFileParams];
    mxClassID  category = mxGetClassID(pParamList);
    if (category != mxCELL_CLASS)mexErrMsgTxt("Input file parameters have to be packed in cellarray");

    size_t n_files = mxGetNumberOfElements(pParamList);
    size_t n_realFiles = 0;
    std::vector<fileParameters> fileParam(n_files);
    for (size_t i = 0; i < n_files; i++) {
        const mxArray *pCellElement;
        pCellElement = mxGetCell(pParamList, i);
        if (pCellElement == NULL) { // empty cell
            continue;
        }
        if (mxSTRUCT_CLASS != mxGetClassID(pCellElement)) {
            std::stringstream buf;
            buf << "ERROR::combine_sqw => all cells in the input parameter list have to be structures but element N" << i << " is not\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        fileParam[n_realFiles] = fileParameters(pCellElement);
        n_realFiles++;
    }

    // Retrieve programs parameters
    ProgParameters ProgSettings;
    int read_files_multitreaded(0);

    auto pProg_settings = (double *)mxGetPr(prhs[programSettings]);

    for (size_t i = 0; i < n_prog_params; i++) {
        switch (i) {
        case(0) :
            ProgSettings.totNumBins = size_t(pProg_settings[i]);
            break;
        case(1) :
            // -1 --> convert to C-arrays from Matlab array counting
            ProgSettings.nBin2read = size_t(pProg_settings[i]) - 1;
            break;
        case(2) :
            ProgSettings.pixBufferSize = size_t(pProg_settings[i]);
            break;
        case(3) :
            ProgSettings.log_level = int(pProg_settings[i]);
            break;
        case(4) :
            change_fileno = (pProg_settings[i]>0)?true:false;
            break;
        case(5) :
            fileno_provided = (pProg_settings[i]>0) ? true : false;;
            break;
        case(6) :
            ProgSettings.num_log_ticks = size_t(pProg_settings[i]);
            break;
        case(7) :
            read_buf_size = size_t(pProg_settings[i]);
            break;
        case(8) :
            read_files_multitreaded =int(pProg_settings[i]);
            break;

        }
    }
    // set up the number of bins, which is currently equal for all input files
    for (size_t i = 0; i < n_files; i++) {
        fileParam[i].total_NfileBins = ProgSettings.totNumBins;
    }


    // Pointer to output file parameters;
    auto pOutFileParams = prhs[outFileParams];
    if (mxSTRUCT_CLASS != mxGetClassID(pOutFileParams)) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw => the output file parameters have to be a structure but it is not";
        mexErrMsgTxt(buf.str().c_str());
    }
    auto OutFilePar = fileParameters(pOutFileParams);
    // set up the number of bins, which is currently equal for input and output files
    OutFilePar.total_NfileBins = ProgSettings.totNumBins;

    //--------------------------------------------------------
    //-------   RUN PROGRAM      -----------------------------
    //--------------------------------------------------------
    std::vector<sqw_reader> fileReader(n_files);
    for (size_t i = 0; i < n_files; i++) {
        fileReader[i].init(fileParam[i], change_fileno, fileno_provided, read_buf_size, read_files_multitreaded);
    }
    size_t n_buf_pixels(0), n_bins_processed(0);
    if (debug_file_reader) {

        auto nbin_Buffer = mxCreateNumericMatrix(ProgSettings.totNumBins, 1, mxUINT64_CLASS, mxREAL);
        uint64_t *nbinBuf = (uint64_t *)mxGetPr(nbin_Buffer);

        exchange_buffer Buffer(ProgSettings.pixBufferSize, ProgSettings.totNumBins, ProgSettings.num_log_ticks);
        pix_reader Reader(ProgSettings, fileReader, Buffer);


        n_bins_processed = ProgSettings.nBin2read;
        Reader.read_pix_info(n_buf_pixels, n_bins_processed, nbinBuf);

        size_t nReadPixels, n_bin_max;
        const float * buf = reinterpret_cast<const float *>(Buffer.get_write_buffer(nReadPixels, n_bin_max));
        n_bins_processed = n_bin_max - 1;
        auto PixBuffer = mxCreateNumericMatrix(9, nReadPixels, mxSINGLE_CLASS, mxREAL);
        if (!PixBuffer) {
            mexErrMsgTxt("Can not allocate output pixels buffer");
        }
        float *pPixBuffer = (float *)mxGetPr(PixBuffer);
        for (size_t i = 0; i < nReadPixels * 9; i++) {
            pPixBuffer[i] = buf[i];
        }
        Buffer.unlock_write_buffer();

        auto OutParam = mxCreateNumericMatrix(2, 1, mxUINT64_CLASS, mxREAL);
        uint64_t *outData = (uint64_t *)mxGetPr(OutParam);
        outData[0] = n_buf_pixels;
        outData[1] = n_bins_processed + 1;

        plhs[pix_data] = PixBuffer;
        plhs[npix_in_bins] = nbin_Buffer;
        plhs[pix_info] = OutParam;
    }


    else {
        combine_sqw(ProgSettings, fileReader, OutFilePar);
    }
}

