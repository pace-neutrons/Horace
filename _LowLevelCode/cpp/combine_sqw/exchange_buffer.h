#ifndef H_EXCHANGE_BUFFER
#define H_EXCHANGE_BUFFER

#include <vector>
#include <ctime>
#include <thread>
#include <condition_variable>
// Matlab includes
#include <mex.h>
#include <matrix.h>


#include <sstream>
#include <iomanip>


//-----------------------------------------------------------------------------------------------------------------
/* Class provides unblocking read/write buffer and logging operations for asynchronous read and write operations on 3 threads */
class exchange_buffer {
public:
    // read buffer
    char *const  get_write_buffer(size_t &nPixels, size_t &n_bin_processed);
    float *const get_read_buffer(const size_t buf_size = 0);
    // lock write buffer from modifications by other threads too but unlocks read buffer
    void set_and_lock_write_buffer(const size_t nPixels, const size_t nBinsProcessed);
    void unlock_write_buffer();

    void set_interrupted(const std::string &err_message) {
        interrupted = true;
        this->error_message = err_message;
    }
    bool is_interrupted()const { return interrupted; }
    bool is_write_job_completed()const { return write_job_completed; }
    void set_write_job_completed();

    exchange_buffer(size_t b_size, size_t num_bins_2_process, size_t num_log_ticks);
    //
    void set_write_allowed() {
        // Release write job in case it waits for read completed
        std::lock_guard<std::mutex> lock(this->write_lock);
        this->write_allowed = true;
        this->data_ready.notify_one();
    }
    //
    void check_logging();
    void print_log_meassage(int log_level);
    void print_final_log_mess(int log_level)const;

    size_t pix_buf_size()const {
        return(buf_size / PIX_SIZE);
    }
    // logging semaphore
    bool do_logging;
    std::condition_variable logging_ready;
    // error message used in case if program is interrupted;
    std::string error_message;
private:
    size_t buf_size;
    size_t n_read_pixels, n_bins_processed, num_bins_to_process;
    bool interrupted, write_allowed, write_job_completed;
    // logging and timing:
    size_t break_step, num_log_messages, break_point, n_read_pix_total;
    std::clock_t c_start;
    time_t t_start, t_prev;


    std::condition_variable data_ready;
    std::mutex exchange_lock;
    std::mutex write_lock;


    std::vector<float> read_buf;
    std::vector<float> write_buf;

    static const size_t PIX_SIZE = 9; // size of the pixel in pixel data units (float)

};
#endif
