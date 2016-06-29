#include "sqw_reader.h"

//--------------------------------------------------------------------------------------------------------------------
//-----------  SQW READER (FOR SINGLE SQW FILE)  ---------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
sqw_reader::sqw_reader() :
    pix_map(),
    _nPixInFile(0),
    npix_in_buf_start(0), buf_pix_end(0),
    PIX_BUF_SIZE(1024), change_fileno(false), fileno(true),
    n_first_threadbuf_pix(0),
    use_multithreading_pix(false), pix_read(false), pix_read_job_completed(true)
{}

sqw_reader::~sqw_reader() {
    //mexPrintf("|MEX::COMBINE_SQW: in destructor for file N %d  |",this->fileDescr.file_id);
    //mexEvalString("pause(.002);");
     
    this->finish_read_job();
    h_data_file_pix.close();
}

//
void sqw_reader::init(const fileParameters &fpar, bool changefileno, bool fileno_provided, size_t pix_buf_size, int multithreading_settings) {
    
    bool bin_multithreading(false),pix_multithreading(false);
    switch (multithreading_settings) {
    case(-1,0):
        bin_multithreading = false;
        pix_multithreading = false;
        break;
    case(1):
        bin_multithreading = true;
        pix_multithreading = true;
        break;
    case(2):
        bin_multithreading = true;
        pix_multithreading = false;
        break;
    case(3):
        bin_multithreading = false;
        pix_multithreading = true;
        break;
    default:
        mexErrMsgTxt("Input multithreading parameter should be 0 (no multithreading) 1 (multithreading)"
            ", 2 (debug mode, only bin thread used for reading ) or 3 (debug mode , use pix read thread, and disable bin reading)");
    }

    this->fileDescr = fpar;
    if (h_data_file_pix.is_open()) {
        h_data_file_pix.close();
    }
    if (this->use_multithreading_pix && !this->pix_read_job_completed){
        this->finish_read_job();
    }


    _nPixInFile = 0;
    npix_in_buf_start = 0;
    buf_pix_end = 0;

    this->pix_map.init(fpar.fileName, fpar.nbin_start_pos, fpar.total_NfileBins, pix_buf_size, bin_multithreading);

    if (pix_buf_size != 0) {
        this->PIX_BUF_SIZE = pix_buf_size;
        this->pix_buffer.resize(PIX_BUF_SIZE*PIX_SIZE);
        this->use_streambuf_direct = false;
        // set up unbuffered IO.
        h_data_file_pix.rdbuf()->pubsetbuf(0, 0);
        //
    }
    else {
        this->use_streambuf_direct = true;
       // in this case pixels are directly read to the target buffer, so no multithreading is possible
        pix_multithreading = false;
        this->use_multithreading_pix = false;
    }


    h_data_file_pix.open(this->fileDescr.fileName, std::ios::in | std::ios::binary);
    if (!h_data_file_pix.is_open()) {
        std::string error("Can not open file: ");
        error += this->fileDescr.fileName;
        mexErrMsgTxt(error.c_str());
    }

    this->change_fileno = changefileno;
    this->fileno = fileno_provided;

    // read number of pixels defined in the file
    std::streamoff pix_pos = this->fileDescr.pix_start_pos - 8;
    auto pbuf = h_data_file_pix.rdbuf();
    pbuf->pubseekpos(pix_pos);
    char *buffer = reinterpret_cast<char *>(&_nPixInFile);
    pbuf->sgetn(buffer, 8);
    if (this->_nPixInFile == 0) {
        return; // file does not have pixels. 
    }


    if (pix_multithreading) {
        this->use_multithreading_pix = true;
        this->pix_read_job_completed = false;
        this->thread_pix_buffer.resize(PIX_BUF_SIZE*PIX_SIZE);
        this->n_first_threadbuf_pix = 0;
        this->num_treadbuf_pix = 0;

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
*                      within pix_info array
*/
void sqw_reader::get_pix_for_bin(size_t bin_number, float *const pix_info, size_t buf_position,
    size_t &pix_start_num, size_t &num_bin_pix, bool position_is_defined) {

    size_t out_buf_start = buf_position*PIX_SIZE;

    if (!position_is_defined) {
        this->pix_map.get_npix_for_bin(bin_number, pix_start_num, num_bin_pix);
    }
    if (num_bin_pix == 0) return;

    if (pix_start_num < this->npix_in_buf_start || pix_start_num + num_bin_pix > this->buf_pix_end) {
        this->_update_cash(bin_number, pix_start_num, num_bin_pix, pix_info + out_buf_start);
    }
    if (!this->use_streambuf_direct) { // copy data from buffer to the destination
        size_t in_buf_start = (pix_start_num - this->npix_in_buf_start)*PIX_SIZE;
        for (size_t i = 0; i < num_bin_pix*PIX_SIZE; i++) {
            pix_info[out_buf_start + i] = this->pix_buffer[in_buf_start + i];
        }
    }
}
/*
 read pixels information, corresponding to the bin with the number requested

 either fill the buffer (read data into it) or at least read the number specified (depending on the use_streambuf_direct switch)
*/
void sqw_reader::_update_cash(size_t bin_number, size_t pix_start_num, size_t num_pix_in_bin, float *const pix_info) {

    //check if we have loaded enough bin information to read enough
    //pixels and return enough pixels to fill - in buffer.Expand or
    // shrink if necessary
    // if we are here, nbin buffer is intact and pixel buffer is
    // invalidated
    size_t num_pix_to_read;
    if (use_streambuf_direct) {
        num_pix_to_read = num_pix_in_bin;
    }
    else {
        size_t pix_buf_size;
        bool end_of_pixmap_reached;
        //check_binInfo_loaded_(bin_number, true, pix_start_num);
        if (this->use_streambuf_direct) {
            pix_buf_size = num_pix_in_bin;
        }
        else {
            pix_buf_size = this->pix_buffer.size() / PIX_SIZE;
        }
        num_pix_to_read = this->pix_map.check_expand_pix_map(bin_number, pix_buf_size, end_of_pixmap_reached);
    }
    size_t num_pix_in_buffer;
    if (this->use_multithreading_pix) {
        if (num_pix_to_read*PIX_SIZE > this->thread_pix_buffer.size()) {
            std::lock_guard<std::mutex> read_lock(this->pix_read_lock);
            thread_pix_buffer.resize(num_pix_to_read*PIX_SIZE);
        }
        size_t first_thbuf_pix, last_thbuf_pix, n_thrbuf_pix;
        bool job_completed = this->_get_thread_pix_param(first_thbuf_pix, last_thbuf_pix, n_thrbuf_pix);
        if (job_completed) {
            return;
        }
        if (pix_start_num>= first_thbuf_pix && pix_start_num+ num_pix_in_bin<last_thbuf_pix) {
            size_t next_thr_pix_to_read = pix_start_num+ num_pix_to_read;
            this->_get_thread_data(pix_start_num, num_pix_in_buffer,pix_buffer, next_thr_pix_to_read);
            // buffer always read to full capacity but we drop incomplete bin
            num_pix_in_buffer = num_pix_to_read;
        }else { // Cash missed. instruct thread to get next portion of data but read proper data piece manually.
            if (num_pix_in_bin*PIX_SIZE > pix_buffer.size()) {
                std::lock_guard<std::mutex> read_lock(this->pix_read_lock);
                pix_buffer.resize((num_pix_in_bin+1)*PIX_SIZE);
            }
            size_t next_pix_to_read = pix_start_num + num_pix_in_bin;
            size_t wrong_start_num,wrong_pix_in_buf;
            this->_get_thread_data(wrong_start_num, wrong_pix_in_buf, pix_buffer, next_pix_to_read);
            //
            std::lock_guard<std::mutex> read_lock(this->pix_read_lock);
            this->_read_pix(pix_start_num, &pix_buffer[0], num_pix_in_bin);
            num_pix_in_buffer = num_pix_in_bin;
        }

    }
    else {
        if (use_streambuf_direct) {
            this->_read_pix(pix_start_num, pix_info, num_pix_to_read);
            num_pix_in_buffer = num_pix_to_read;
        }
        else {
            if (this->pix_buffer.size() < num_pix_to_read*PIX_SIZE) {
                this->pix_buffer.resize(num_pix_to_read*PIX_SIZE);
            }
            this->_read_pix(pix_start_num, &pix_buffer[0], num_pix_to_read);
            num_pix_in_buffer = num_pix_to_read;
        }

    }
    this->npix_in_buf_start = pix_start_num;
    this->buf_pix_end = this->npix_in_buf_start + num_pix_in_buffer;

}
bool sqw_reader::_get_thread_pix_param(size_t &first_thbuf_pix, size_t &last_thbuf_pix, size_t &n_buf_pix){

    std::unique_lock<std::mutex> lock(this->pix_exchange_lock);
    this->pix_ready.wait(lock, [this]() {return this->pix_read; });

    std::lock_guard<std::mutex> read_lock(this->pix_read_lock);
    if (this->pix_read_job_completed) {
        this->pix_read = false;
        n_buf_pix = 0;
        first_thbuf_pix = 0;
        last_thbuf_pix = 0;
        this->read_pix_needed.notify_one();
        return true;
    }

    first_thbuf_pix = this->n_first_threadbuf_pix;
    n_buf_pix = this->num_treadbuf_pix;
    last_thbuf_pix = first_thbuf_pix + n_buf_pix;
    return false;


}
/* Get thread data and instruct thread to read next part of the pixel information*/
void sqw_reader::_get_thread_data(size_t &first_buf_pix, size_t &n_pix_in_buf, std::vector<float> &pixbuf, size_t next_pix_to_read) {
    //
    std::unique_lock<std::mutex> lock(this->pix_exchange_lock);
    this->pix_ready.wait(lock, [this]() {return this->pix_read; });
    {
        std::lock_guard<std::mutex> read_lock(this->pix_read_lock);
        if (this->pix_read_job_completed) {
            this->pix_read = false;
            this->read_pix_needed.notify_one();
            return;
        }
        bool buf_size_changed(false);
        if (pixbuf.size() != this->thread_pix_buffer.size()) {
            buf_size_changed = true;
        }

        first_buf_pix = this->n_first_threadbuf_pix;
        n_pix_in_buf  = this->num_treadbuf_pix;
        this->thread_pix_buffer.swap(pixbuf);
        this->n_first_threadbuf_pix = next_pix_to_read;
        this->pix_read = false;

        if (buf_size_changed) {
            size_t nex_size = this->thread_pix_buffer.size();
            this->PIX_BUF_SIZE = nex_size / PIX_SIZE;
            pixbuf.resize(nex_size);
        }
    }
    this->read_pix_needed.notify_one();


}
//

void sqw_reader::read_pixels_job() {

    std::unique_lock<std::mutex> lock(this->pix_exchange_lock);

    while (!this->pix_read_job_completed) {
        this->read_pix_needed.wait(lock, [this]() {return (!this->pix_read) || this->pix_read_job_completed; });
        {
            std::lock_guard<std::mutex> read_lock(this->pix_read_lock);

            if (this->pix_read_job_completed) {
                this->pix_read = true;
                this->pix_ready.notify_one();
                return;
            }

            size_t n_pix_to_read = thread_pix_buffer.size()/PIX_SIZE;
            if (this->n_first_threadbuf_pix + n_pix_to_read >= this->_nPixInFile) {
                n_pix_to_read = this->_nPixInFile - this->n_first_threadbuf_pix;
            }

            if (n_pix_to_read > 0) {
                this->_read_pix(this->n_first_threadbuf_pix, &thread_pix_buffer[0], n_pix_to_read);
            }
            this->num_treadbuf_pix = n_pix_to_read;
            this->pix_read = true;
        }
        this->pix_ready.notify_one();
    }

}
//
void sqw_reader::finish_read_job() {
    //mexPrintf("|MEX::COMBINE_SQW: in finish read job for file N %d  |",this->fileDescr.file_id);
    //mexEvalString("pause(.002);");
    
    this->pix_map.finish_read_bin_job();
    //mexPrintf(" completed pix map job|");
    //mexEvalString("pause(.002);");
    

    if (!this->use_multithreading_pix || this->pix_read_job_completed) {
        return;
    }
    if (!read_pix_job_holder.joinable()) {
        return;
    }

    {
        std::lock_guard<std::mutex> read_lock(this->pix_read_lock);

        this->pix_read_job_completed = true;
        // finish incomplete read job if it has not been finished naturally
        this->pix_read = false;
    }
    this->read_pix_needed.notify_one();
    read_pix_job_holder.join();
    //mexPrintf(" completed pix read job|\n",this->fileDescr.file_id);
    //mexEvalString("pause(.002);");

}


/* Read specified number of pixels into the pixel buffer provided */
void sqw_reader::_read_pix(size_t pix_start_num, float *const pix_buffer, size_t &num_pix_to_read) {


    if (pix_start_num + num_pix_to_read > this->_nPixInFile) {
        if (pix_start_num > this->_nPixInFile) {
            mexErrMsgTxt("SQW_READER::_read_pix =>Trying to read pixel outside of the pixel range");
        }
        num_pix_to_read = this->_nPixInFile - pix_start_num;
    }

    std::streamoff pix_pos = this->fileDescr.pix_start_pos + pix_start_num*PIX_SIZE_BYTES;
    auto pbuf = h_data_file_pix.rdbuf();
    pbuf->pubseekpos(pix_pos);

    //
    char * buffer = reinterpret_cast<char *>(pix_buffer);
    std::streamoff length = num_pix_to_read*PIX_SIZE_BYTES;
    //pbuf->pubsetbuf(buffer, length);
    pbuf->sgetn(buffer, length);


    if (this->change_fileno) {
        for (size_t i = 0; i < num_pix_to_read; i++) {
            if (fileno) {
                *(pix_buffer + 4 + i * 9) = float(this->fileDescr.file_id);
            }
            else {
                *(pix_buffer + 4 + i * 9) += float(this->fileDescr.file_id);
            }
        }

    }

}

