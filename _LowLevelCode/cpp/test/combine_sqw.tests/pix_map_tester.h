#include "combine_sqw/pix_mem_map.h"

class PixMapTester : public pix_mem_map {
public:
  void read_bins(std::size_t starting_bin_num,
                 std::vector<pix_mem_map::bin_info> &buffer,
                 std::size_t &bin_end, std::size_t &buf_end) {
    pix_mem_map::_read_bins(starting_bin_num, buffer, bin_end, buf_end);
  };

  void read_bins_job() { pix_mem_map::read_bins_job(); }

  std::size_t get_first_thread_bin() const { return n_first_rbuf_bin; }
  std::size_t get_last_thread_bin() const { return rbuf_nbin_end; }
  std::size_t get_n_buf_pix() const { return rbuf_end; }

  void wait_for_read_to_complete() {
    std::unique_lock<std::mutex> data_ready(this->exchange_lock);
    this->bins_ready.wait(data_ready, [this]() { return this->nbins_read; });
  }

  bool thread_get_data(std::size_t &num_bin, std::vector<bin_info> &inbuf,
                       std::size_t &bin_end, std::size_t &buf_end) {
    return pix_mem_map::_thread_get_data(num_bin, inbuf, bin_end, buf_end);
  }
  void thread_query_data(std::size_t &num_first_bin, std::size_t &num_last_bin,
                         std::size_t &buf_end) {
    pix_mem_map::_thread_query_data(num_first_bin, num_last_bin, buf_end);
  }
  void thread_request_to_read(std::size_t start_bin) {
    pix_mem_map::_thread_request_to_read(start_bin);
  }
};
