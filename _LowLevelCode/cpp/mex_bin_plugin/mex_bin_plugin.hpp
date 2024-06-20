#pragma once
#include <iostream>
#include <sstream>
#include <fstream>
#include <iomanip>
#include <map>
#include <vector>
#include <mex.h>
#include <matrix.h>

#include <condition_variable>
#include <ctime>
#include <thread>
#include <mex.h>
#include <matrix.h>
#include <limits>



class fileParameters {
public:
	std::string fileName;
	size_t nbin_start_pos; // the initial file position where nbin array is located in the file
	uint64_t pix_start_pos;   // the initial file position where the pixel array is located in file
	int    file_id;       // the number which used to identify pixels, obtained from this particular file
	size_t total_NfileBins; // the number of bins in this file (has to be the same for all files)
	size_t total_nPixels;

	//fileParameters( int mxArray *pFileParam);
	fileParameters() :fileName(""), nbin_start_pos(0), pix_start_pos(0),
		file_id(0), total_NfileBins(0), total_nPixels(std::numeric_limits<size_t>::max()) {}
private:
	static const std::map<std::string, int> fileParamNames;
};


//-----------------------------------------------------------------------------------------------------------------
/* Class responsible for writing block of pixels on HDD */
class sqw_pix_writer {
public:
    sqw_pix_writer() :
        last_pix_written(0), pix_array_position(0),
        num_bins_to_process(0) {}

    void init(const fileParameters &fpar, const size_t nBins2Process);
    void write_pixels(const char * const buffer, const size_t n_pix_to_write);
    void run_write_pix_job();
    void operator()() {
        this->run_write_pix_job();
    }
    ~sqw_pix_writer();
	
	

private:
    //exchange_buffer &Buff;

    std::string filename;

    std::ofstream h_out_sqw;
    size_t last_pix_written;
    size_t pix_array_position;
    size_t nbin_position;
    size_t num_bins_to_process;

	std::vector<float> pix_buffer{};
    //
    static const size_t PIX_BLOCK_SIZE_BYTES = 36; //9 * 4; // size of the pixel block in bytes


};

class exchange_buffer{
public:
	

	// write buffer synchronization
	void wait_for_reader_data();
	char* const  get_write_buffer(size_t& nPixels, size_t& n_bin_processed);
	void unlock_write_buffer();
	// read buffer synchronization
	float* const get_read_buffer(const size_t buf_size = 0);
	// lock write buffer from modifications by other threads too but unlocks read buffer
	void send_read_buffer_to_writer(const size_t nPixels, const size_t nBinsProcessed);


	void set_interrupted(const std::string& err_message) {
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
	bool interrupted, write_job_completed;
	// logging and timing:
	size_t break_step, num_log_messages, break_point, n_read_pix_total;
	std::clock_t c_start;
	time_t t_start, t_prev;

	// thread synchronization
	bool write_allowed;
	std::condition_variable data_ready;
	std::mutex data_ready_lock;
	bool writer_ready;
	std::condition_variable data_written;
	std::mutex data_written_lock;
	std::mutex write_lock;

	std::vector<float> read_buf;
	std::vector<float> write_buf;

	static const size_t PIX_SIZE = 9; // size of the pixel in pixel data units (float)
};
