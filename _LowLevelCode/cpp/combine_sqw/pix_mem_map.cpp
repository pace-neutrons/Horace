#include "pix_mem_map.h"
//--------------------------------------------------------------------------------------------------------------------
//---------------- BINS IN MEMORY ------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/*Constructor */
pix_mem_map::pix_mem_map() :
    use_streambuf_direct(true),
    prebuf_pix_num(0),
    num_first_buf_bin(0), num_last_buf_bin(0), buf_end(0),

    _nTotalBins(0), _binFileStartPos(0),
    map_capacity_isknown(false),
    _numPixInMap(std::numeric_limits<uint64_t>::max()),
    BUF_EXTENSION_STEP(1024), // 4K 

    BIN_BUF_SIZE(1024),
    //
    use_multithreading(false),
    nbins_read(false), read_job_completed(false), thread_read_to_end(false),
    n_first_rbuf_bin(0), rbuf_nbin_end(0), rbuf_end(0)

{}
/* Destructor */
pix_mem_map::~pix_mem_map() {
    this->finish_read_bin_job();
    h_data_file_bin.close();


}
void pix_mem_map::get_map_param(size_t &first_mem_bin, size_t &last_mem_bin, size_t &n_tot_bins)const {
    first_mem_bin = this->num_first_buf_bin;
    last_mem_bin = this->num_last_buf_bin;
    n_tot_bins = this->_nTotalBins;

}

void pix_mem_map::init(const std::string &full_file_name, size_t bin_start_pos, size_t n_tot_bins, size_t BufferSize, bool use_multithreading) {

    this->_nTotalBins = n_tot_bins;
    this->_binFileStartPos = bin_start_pos;
    this->num_first_buf_bin = 0;
    this->num_last_buf_bin = 0;
    this->buf_end = 0;
    this->prebuf_pix_num = 0;

    this->finish_read_bin_job();

    this->full_file_name = full_file_name;

    if (this->h_data_file_bin.is_open()) {
        this->h_data_file_bin.close();
        this->map_capacity_isknown = false;
        this->_numPixInMap = std::numeric_limits<uint64_t>::max();
    }
    //
    if (BufferSize != 0) {
        this->BIN_BUF_SIZE = BufferSize;
        this->BUF_EXTENSION_STEP = BIN_BUF_SIZE;
        this->nbin_read_buffer.resize(BIN_BUF_SIZE);
         h_data_file_bin.rdbuf()->pubsetbuf(0, 0);
        use_streambuf_direct = false;
        //
        nbin_buffer.resize(BIN_BUF_SIZE);
    }
    else {
        this->BUF_EXTENSION_STEP = 1024;
        this->BIN_BUF_SIZE = BUF_EXTENSION_STEP;
        use_streambuf_direct = true;
        nbin_read_buffer.resize(BIN_BUF_SIZE);
        nbin_buffer.resize(BUF_EXTENSION_STEP);
    }
    h_data_file_bin.open(full_file_name, std::ios::in | std::ios::binary);
    if (!h_data_file_bin.is_open()) {
        std::string error("Can not open file: ");
        error += full_file_name;
        mexErrMsgTxt(error.c_str());
    }
    // 
    size_t n_last = nbin_buffer.size() - 1;
    nbin_buffer[n_last].pix_pos = 0;
    nbin_buffer[n_last].num_bin_pixels = 0;



    // start separate read job
    this->use_multithreading = use_multithreading;
    if (this->use_multithreading) {
        this->nbins_read = false;
        this->read_job_completed = false;
        this->thread_read_to_end = false;
        this->n_first_rbuf_bin = 0;
        this->rbuf_nbin_end = 0;
        this->rbuf_end = 0;


        this->thread_nbin_buffer.resize(BUF_EXTENSION_STEP);

        std::thread read_bins([this]() {this->read_bins_job(); });
        read_bins_job_holder.swap(read_bins);
    }
}
//

/* return number of pixels this memory map describes starting from the bin number provided*/
size_t pix_mem_map::num_pix_described(size_t bin_number)const {
    if (bin_number < this->num_first_buf_bin || bin_number >= this->num_last_buf_bin) {
        mexErrMsgTxt("pix_mem_map::num_pix_described -- bin number out of bin cache range");
    }
    size_t loc_bin = bin_number - this->num_first_buf_bin;
    auto pEnd = this->nbin_buffer.begin() + (this->num_last_buf_bin - this->num_first_buf_bin - 1);
    size_t num_pix_start = this->nbin_buffer[loc_bin].pix_pos;
    return pEnd->pix_pos + pEnd->num_bin_pixels - num_pix_start;

}
/*
* Method to read block of information about number of pixels
* stored according to bins starting with the bin number specified
* as input
* num_bin   -- first bin to read information into
* buf_start -- position of the bins to place into the bugger (default, from the beginning of the buffer)
*
* num_loc_bin -- the bin within a block to read into the buffer
Returns:
bin_end -- absolute number of last bin read into the buffer
buf_end -- last filled buffer cell (ideally equal to the buf_size, but may be smaller near eof)

*/
bool pix_mem_map::_read_bins(size_t num_bin, std::vector<bin_info> &inbuf, size_t &bin_end, size_t &buf_end) {

    if (num_bin >= this->_nTotalBins) {
        mexErrMsgTxt("READ_SQW::read_bins =>Accessing bin out of bin range");
    }
    size_t buf_size = inbuf.size();
    bin_end = num_bin + buf_size;

    bool end_of_map_reached(false);
    if (bin_end >= this->_nTotalBins) {
        bin_end = this->_nTotalBins;
        end_of_map_reached = true;
    }

    size_t tot_num_bins_to_read = bin_end - num_bin;


    std::streamoff bin_pos = this->_binFileStartPos + num_bin*BIN_SIZE_BYTES;
    auto pbuf = h_data_file_bin.rdbuf();
    pbuf->pubseekpos(bin_pos);

    if (tot_num_bins_to_read > nbin_read_buffer.size()) {
        this->nbin_read_buffer.resize(tot_num_bins_to_read);
    }
    std::streamoff length = tot_num_bins_to_read*BIN_SIZE_BYTES;
    char * buffer = reinterpret_cast<char *>(&nbin_read_buffer[0]);
    //pbuf->pubsetbuf(buffer, length);
    pbuf->sgetn(buffer, length);

    inbuf[0] = bin_info(this->nbin_read_buffer[0], 0);
    for (size_t i = 1; i < tot_num_bins_to_read; i++) {
        inbuf[i] = bin_info(this->nbin_read_buffer[i], inbuf[i - 1].pix_pos + inbuf[i - 1].num_bin_pixels);
    }

    //
    buf_end = tot_num_bins_to_read;
    // store number of pixels described by the whole pix map
    return end_of_map_reached;
}
/* nbin_buffer may already contain some bin buffer data */
void pix_mem_map::_update_data_cash(size_t bin_number) {
    size_t last_buf_pix(0);
    if (this->buf_end > 0) {
        last_buf_pix = this->buf_end - 1;
    }
    this->_update_data_cash_(bin_number, this->nbin_buffer, this->num_first_buf_bin,
        this->num_last_buf_bin, last_buf_pix, this->prebuf_pix_num);

    this->buf_end = last_buf_pix;
}
/* get information about the bin info, stored in the thread buffer*/
void pix_mem_map::_thread_query_data(size_t &num_first_bin, size_t &num_last_bin, size_t &buf_end) {
    std::unique_lock<std::mutex> data_ready(this->exchange_lock);
    // wait for data ready
    this->bins_ready.wait(data_ready, [this]() {return this->nbins_read; });

    buf_end = this->rbuf_end;
    num_first_bin = this->n_first_rbuf_bin;
    num_last_bin = this->rbuf_nbin_end;

}
/* ignore current content and request the thread to read data for the bin provided and forward*/
void pix_mem_map::_thread_request_to_read(size_t start_bin) {
    std::unique_lock<std::mutex> data_ready(this->exchange_lock);

    this->bins_ready.wait(data_ready, [this]() {return this->nbins_read; });
    {
        std::lock_guard<std::mutex> lock(this->bin_read_lock); // lock read operation as the thread may be started from more then one place


        this->n_first_rbuf_bin = start_bin;
        this->nbins_read = false;
    }
    this->read_bins_needed.notify_one();


}

bool pix_mem_map::_thread_get_data(size_t &num_first_bin, std::vector<bin_info> &inbuf, size_t &num_last_bin, size_t &buf_end) {

    bool end_of_map_reached;
    std::unique_lock<std::mutex> data_ready(this->exchange_lock);
    // wait for data ready
    this->bins_ready.wait(data_ready, [this]() {return this->nbins_read; });
    // retrieve results
    {
        // lock read operation as the thread may be started from more then one place
        std::lock_guard<std::mutex> lock(this->bin_read_lock);

        num_first_bin = this->n_first_rbuf_bin;
        num_last_bin = this->rbuf_nbin_end;
        buf_end = this->rbuf_end;
        if (inbuf.size() != this->thread_nbin_buffer.size()) {
            inbuf.resize(this->thread_nbin_buffer.size());
        }
        inbuf.swap(this->thread_nbin_buffer);


        // set up parameters for the next read job
        this->n_first_rbuf_bin = num_last_bin;
        this->nbins_read = false;
        end_of_map_reached = this->thread_read_to_end;
    }
    this->read_bins_needed.notify_one();
    return end_of_map_reached;



}


/* Get data for the bin provided and place all subsequent bin info into data cash */
void pix_mem_map::_update_data_cash_(size_t bin_number, std::vector<bin_info> &nbin_buffer,
    size_t &num_first_buf_bin, size_t &num_last_buf_bin, size_t &end_buf_bin, size_t &prebuf_pix_num) {

    // Actual last bin info, stored in buffer
    size_t n_last(end_buf_bin);
    if (n_last == 0) { // nothing has been stored yet
        n_last = nbin_buffer.size() - 1;
    }


    if (bin_number < num_first_buf_bin) { //cash missed, start reading from the beginning of the bin array
        num_first_buf_bin = 0;
        num_last_buf_bin = 0; // number of first and last bin stored in memory
        prebuf_pix_num = 0; // total number of pixels, stored before first pixel in bin.
        nbin_buffer[n_last].pix_pos = 0;
        nbin_buffer[n_last].num_bin_pixels = 0;
        this->map_capacity_isknown = false;
    }
    bool end_of_map_reached(false);
    //------------------------------------------------------------------------------
    size_t start_bin = num_first_buf_bin;
    size_t end_bin = num_last_buf_bin;
    while (!(bin_number >= start_bin && bin_number < end_bin)) {
        if (this->use_multithreading) {
            size_t first_thread_bin, last_thread_bin, thread_buf_end;
            this->_thread_query_data(first_thread_bin, last_thread_bin, thread_buf_end);
            if (bin_number < first_thread_bin) { // cash missed so we need to start read job again
                this->_thread_request_to_read(start_bin);
            }
            // adjust last position of the pix info
            prebuf_pix_num += nbin_buffer[n_last].pix_pos + nbin_buffer[n_last].num_bin_pixels;
            end_of_map_reached = this->_thread_get_data(start_bin, nbin_buffer, end_bin, end_buf_bin);
            if (end_buf_bin > 0) {
                n_last = end_buf_bin - 1;
            }
            if (this->read_job_completed) { // data may have been interrupted so we do not actually have data ready
                break;
            }
        }
        else {
            prebuf_pix_num += nbin_buffer[n_last].pix_pos + nbin_buffer[n_last].num_bin_pixels;
            start_bin = end_bin;
            end_of_map_reached = this->_read_bins(start_bin, nbin_buffer, end_bin, end_buf_bin);

        }
        if (end_of_map_reached && !this->map_capacity_isknown) {
            this->_numPixInMap = this->prebuf_pix_num + nbin_buffer[end_buf_bin - 1].pix_pos + nbin_buffer[end_buf_bin - 1].num_bin_pixels;
            this->map_capacity_isknown = true;
        }

    }
    num_first_buf_bin = start_bin;
    num_last_buf_bin = end_bin;

}

/** get number of pixels, stored in the bin and the position of these pixels within pixel array
*
* loads bin information for a pixel, which does not have this information loaded
*
*@param bin_number -- number of bin to get pixel information for
*pix_pos_in_buffer
* Returns:
* pix_start_num    -- position of the bin pixels in the pixels array
* num_pix_in_bin   -- number of pixels, stored in this bin
*/

void pix_mem_map::get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_pix_in_bin) {

    //
    if (bin_number >= this->num_last_buf_bin || bin_number < this->num_first_buf_bin) {
        this->_update_data_cash(bin_number); // Advance cache or cache miss
    }
    size_t  num_bin_in_buf = bin_number - this->num_first_buf_bin;
    num_pix_in_bin = this->nbin_buffer[num_bin_in_buf].num_bin_pixels;
    pix_start_num = this->prebuf_pix_num + this->nbin_buffer[num_bin_in_buf].pix_pos;

}

/* function to compare two bin_info classes*/
bool comp_fun(const pix_mem_map::bin_info & lhs, const size_t & rhs) {
    return lhs.pix_pos + lhs.num_bin_pixels <= rhs;
}
/* convert memory map build in the form of the chunked list into the vector form.
*
*@returns number of pixels the map describes
*Sets up nbin_buffer to keep the map, which describes these pixels
*/
size_t pix_mem_map::_flatten_memory_map(const std::list<std::vector<bin_info> > &bin_buf_holder, size_t map_size, size_t first_bin_number) {

    // Store rest of existing memory map in the beginning of the new map
    size_t loc_bin_number = first_bin_number - this->num_first_buf_bin;
    size_t num_bins = this->num_last_buf_bin - this->num_first_buf_bin;
    size_t prebuf_pix_num_shift = this->nbin_buffer[loc_bin_number].pix_pos;
    // this adjust the first pixel number, described by the bin buffer
    this->prebuf_pix_num += prebuf_pix_num_shift;


    std::vector<bin_info> bin_mem_map;
    auto pSourceBuf = &this->nbin_buffer;
    auto pTargBuf = &bin_mem_map;
    if (map_size > nbin_buffer.size()) {
        bin_mem_map.resize(map_size); // Target buffer increased, so need to reallocate
    }
    else {
        pTargBuf = pSourceBuf;       // target buffer has sufficient size, so use same buffer and do copy in-place.
    }

    for (size_t i = loc_bin_number; i < num_bins; i++) {
        (*pTargBuf)[i - loc_bin_number] = bin_info((*pSourceBuf)[i].num_bin_pixels, (*pSourceBuf)[i].pix_pos - prebuf_pix_num_shift);
    }
    // initial location of the next bin chunk in the bin buffer
    loc_bin_number = num_bins - loc_bin_number;
    // next pixel will be shifted by this number:
    prebuf_pix_num_shift = (*pTargBuf)[loc_bin_number - 1].pix_pos + (*pTargBuf)[loc_bin_number - 1].num_bin_pixels;
    // loop over all buffer and fill in the final vector of positions
    for (auto it = bin_buf_holder.begin(); it != bin_buf_holder.end(); ++it) {
        //size_t loc_bin_number = 
        for (size_t i = 0; i < it->size(); ++i) {
            (*pTargBuf)[loc_bin_number + i] = bin_info(it->operator[](i).num_bin_pixels, it->operator[](i).pix_pos + prebuf_pix_num_shift);
        }
        loc_bin_number += it->size();
        prebuf_pix_num_shift = (*pTargBuf)[loc_bin_number - 1].pix_pos + (*pTargBuf)[loc_bin_number - 1].num_bin_pixels;
    }
    // add size of the last buffer chunk
    //loc_bin_number += bin_buf_holder.back().size();

    // Store changes
    if (pTargBuf != pSourceBuf) {
        std::lock_guard<std::mutex> lock(this->bin_read_lock);
        this->nbin_buffer.swap(bin_mem_map);
    }
    this->num_first_buf_bin = first_bin_number;
    this->num_last_buf_bin = first_bin_number + loc_bin_number;
    this->buf_end = loc_bin_number;
    return (this->nbin_buffer[loc_bin_number - 1].pix_pos + this->nbin_buffer[loc_bin_number - 1].num_bin_pixels);

}

/* verify if memory map is defined for the number of pixels provided as the second argument
 * Expand the map if necessary & possible.

 Intended to deal with situation, when we want to read some number of pixels,
 and need to be sure that the memory map for these pixels is defined.

 * Return actual number of pixels best described by existing or extended memory map.
 * Input:
  bin_number      -- current bin number to start estimate
  num_pix_to_fit  -- number of pixels to verify memory map for
 *Output:
  @returns number of pixels memory map describes after the current element
  end_of_pix_reached -- sets up to true if no more pixels is defined in the file.
*/
size_t pix_mem_map::check_expand_pix_map(size_t bin_number, size_t num_pix_to_fit, bool &end_of_pix_reached) {

    end_of_pix_reached = false;
    size_t pix_start_num, num_pix_in_bin;
    this->get_npix_for_bin(bin_number, pix_start_num, num_pix_in_bin);

    if (num_pix_in_bin >= num_pix_to_fit) {
        return num_pix_in_bin;
    }
    size_t num_pix_in_map = this->num_pix_described(bin_number);
    if (num_pix_in_map == num_pix_to_fit) {
        return num_pix_in_map;
    }
    else if (num_pix_in_map > num_pix_to_fit) {// find 
        size_t  num_bin_in_buf = bin_number - this->num_first_buf_bin;
        size_t  num_pix_before_bin = this->nbin_buffer[num_bin_in_buf].pix_pos;
        auto pEnd = this->nbin_buffer.begin() + (this->num_last_buf_bin - this->num_first_buf_bin);
        auto first_out = std::lower_bound(this->nbin_buffer.begin() + num_bin_in_buf, pEnd, num_pix_to_fit + num_pix_before_bin, comp_fun);
        return (first_out->pix_pos - num_pix_before_bin);
    }
    else {
        if (this->map_capacity_isknown) { // we have read the whole memory map.
            end_of_pix_reached = true;
            return num_pix_in_map;
        }
        // Expand memory map
        std::list<std::vector<bin_info> > bin_buf_holder;
        size_t block_size = this->BUF_EXTENSION_STEP;
        size_t num_first_bin = this->num_last_buf_bin;
        size_t last_tmp_bin;
        size_t map_size(this->num_last_buf_bin - bin_number);   // initial pix map size (map for pixels from first requested to the last)
        while (num_pix_in_map < num_pix_to_fit) {
            bin_buf_holder.push_back(std::vector<bin_info>(block_size));
            if (this->use_multithreading) {
                end_of_pix_reached = this->_thread_get_data(num_first_bin, bin_buf_holder.back(), last_tmp_bin, this->buf_end);
            }
            else {
                end_of_pix_reached = this->_read_bins(num_first_bin, bin_buf_holder.back(), last_tmp_bin, this->buf_end);
            }
            if (this->buf_end != block_size) { // if less then block_size pixels read into the buffer, resize buffer to allocate just buf_end pixels
                bin_buf_holder.back().resize(buf_end);
            }

            num_pix_in_map += bin_buf_holder.back()[buf_end - 1].pix_pos - bin_buf_holder.back()[0].pix_pos + bin_buf_holder.back()[buf_end - 1].num_bin_pixels;
            map_size += buf_end;
            if (end_of_pix_reached || this->read_job_completed) { // we have read up to the end of the map so nothing to read now or
                // reading process may have been interrupted so we do not actually have data ready
                break;
            }
            else {
                num_first_bin = last_tmp_bin;
            }

        }
        // convert memory map build in the form of the chunked list into the vector form.
        num_pix_in_map = this->_flatten_memory_map(bin_buf_holder, map_size, bin_number);

        if (end_of_pix_reached && !this->map_capacity_isknown) {
            this->map_capacity_isknown = true;
            this->_numPixInMap = this->prebuf_pix_num + num_pix_in_map;
        }
        return check_expand_pix_map(bin_number, num_pix_to_fit, end_of_pix_reached);

    }

}

/**/
void pix_mem_map::read_bins_job() {

    std::unique_lock<std::mutex> lock(this->exchange_lock);
    while (!this->read_job_completed) {
        this->read_bins_needed.wait(lock, [this]() {return (!this->nbins_read) || this->read_job_completed; });
        {
            std::lock_guard<std::mutex> read_lock(this->bin_read_lock);// lock read operation as thread can be released from more then one place

            if (this->read_job_completed) {
                this->nbins_read = true;
                this->bins_ready.notify_one(); // just in case
                return;
            }

            if (this->n_first_rbuf_bin < this->_nTotalBins) {
                this->thread_read_to_end = this->_read_bins(this->n_first_rbuf_bin, this->thread_nbin_buffer, this->rbuf_nbin_end, this->rbuf_end);
            }
            else {
                this->rbuf_nbin_end = this->_nTotalBins;
                this->rbuf_end = 0;
                this->thread_nbin_buffer[0] = bin_info(); // contains zeros
            }
            this->nbins_read = true;

        }
        this->bins_ready.notify_one();
    }
}

/**/
void pix_mem_map::finish_read_bin_job() {
    if (!this->use_multithreading || this->read_job_completed) {
        return;
    }
    if (!read_bins_job_holder.joinable()) {
        return;
    }
    {
        // lock read operation as thread can be released from more then one place
        std::lock_guard<std::mutex> read_lock(this->bin_read_lock);
        // set up job completion tag
        this->read_job_completed = true;
        // finish incomplete read job if it has not been finished naturally

        this->nbins_read = false;
    }
    this->read_bins_needed.notify_one();

    read_bins_job_holder.join();
}

