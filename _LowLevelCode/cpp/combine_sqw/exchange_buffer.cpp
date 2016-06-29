#include "exchange_buffer.h"

exchange_buffer::exchange_buffer(size_t b_size, size_t num_bins_2_process, size_t num_log_ticks) :
    do_logging(false),
    buf_size(b_size*PIX_SIZE),
    n_read_pixels(0), n_bins_processed(0),
    num_bins_to_process(num_bins_2_process),
    interrupted(false), write_allowed(false),
    write_job_completed(false),
    break_step(1), num_log_messages(num_log_ticks), break_point(0), n_read_pix_total(0)
{
    break_step = num_bins_to_process / num_log_messages;
    break_point = break_step;
    c_start = std::clock();
    time(&t_start);
    t_prev = t_start;


};


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
    this->write_lock.lock();
    this->write_allowed = false;

    n_bins_processed = this->n_bins_processed;
    if (this->n_read_pixels > 0) {
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

    this->n_read_pixels = 0;
    this->write_lock.unlock();
}
/* Verifies if logging is due and send messages to logging thread to report progress.
Also verifies if operations should be terminated as user pressed CTRL-C */
void exchange_buffer::check_logging() {
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
        if (!this->do_logging) {
            this->do_logging = true;
            this->logging_ready.notify_one();
        }

    }

}
/* Sets internal variables of exchange buffer to state, indicating end of operations*/
void exchange_buffer::set_write_job_completed() {
    this->write_job_completed = true;
    if (!this->do_logging) {
        this->do_logging = true;
        // release possible logging
        this->logging_ready.notify_one();
    }
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
            << (c_end - c_start) / CLOCKS_PER_SEC << " sec";

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
