#include "combine_sqw/combine_sqw.h"
#include "combine_sqw/nsqw_pix_reader.h"
#include "combine_sqw/pix_mem_map.h"
#include "combine_sqw/sqw_pix_writer.h"

#include <gtest/gtest.h>

#include <vector>

class pix_map_tester : public pix_mem_map {
public:
  void read_bins(std::size_t num_bin,
                 std::vector<pix_mem_map::bin_info> &buffer,
                 std::size_t &bin_end, std::size_t &buf_end) {
    pix_mem_map::_read_bins(num_bin, buffer, bin_end, buf_end);
  }
  void read_bins_job() { pix_mem_map::read_bins_job(); }

  std::size_t get_first_thread_bin() const { return n_first_rbuf_bin; }
  std::size_t get_last_thread_bin() const { return rbuf_nbin_end; }
  std::size_t get_n_buf_pix() const { return rbuf_end; }
  void wait_for_read_completed() {
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

class TestCombineSQW : public ::testing::Test {

protected:
  static std::vector<uint64_t> sample_npix;
  static std::vector<uint64_t> sample_pix_pos;
  static std::vector<float> pixels;
  static std::string test_file_name;
  static std::size_t num_bin_in_file, bin_pos_in_file, pix_pos_in_file;

  // Called once, before the first test is executed.
  static void SetUpTestSuite() {
    test_file_name = "_test/test_symmetrisation/w3d_sqw.sqw";
    num_bin_in_file = 472392;
    bin_pos_in_file = 5194471;
    pix_pos_in_file = 8973651;
    sample_npix.resize(num_bin_in_file);
    sample_pix_pos.resize(num_bin_in_file, 0);
    pixels.resize(1164180 * 9, 0);
    std::ifstream data_file_bin;
    data_file_bin.open(test_file_name, std::ios::in | std::ios::binary);
    if (!data_file_bin.is_open()) {
      throw "Can not open test data file";
    }
    char *buf = reinterpret_cast<char *>(&sample_npix[0]);
    data_file_bin.seekg(bin_pos_in_file);
    data_file_bin.read(buf, num_bin_in_file * 8);
    for (std::size_t i = 1; i < sample_npix.size(); i++) {
      sample_pix_pos[i] = sample_pix_pos[i - 1] + sample_npix[i - 1];
    }
    data_file_bin.seekg(pix_pos_in_file);
    buf = reinterpret_cast<char *>(&pixels[0]);
    data_file_bin.read(buf, 1164180 * 9 * 8);

    data_file_bin.close();
  }
};

std::vector<uint64_t> TestCombineSQW::sample_npix;
std::vector<uint64_t> TestCombineSQW::sample_pix_pos;
std::vector<float> TestCombineSQW::pixels;
std::string TestCombineSQW::test_file_name;
std::size_t TestCombineSQW::num_bin_in_file, TestCombineSQW::bin_pos_in_file, TestCombineSQW::pix_pos_in_file;

TEST_F(TestCombineSQW, Read_NBins) {
  pix_map_tester pix_map;

  pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 128,
               false);
  std::vector<pix_mem_map::bin_info> buffer(256);

  std::size_t bin_end, buf_end;
  pix_map.read_bins(0, buffer, bin_end, buf_end);

  ASSERT_EQ(256, bin_end);
  ASSERT_EQ(256, buf_end);
  ASSERT_EQ(sample_npix[125], buffer[125].num_bin_pixels);
  ASSERT_EQ(sample_npix[115], buffer[115].num_bin_pixels);
  ASSERT_EQ(sample_npix[114], buffer[114].num_bin_pixels);
  ASSERT_EQ(sample_npix[0], buffer[0].num_bin_pixels);
  ASSERT_EQ(sample_npix[1], buffer[1].num_bin_pixels);
  ASSERT_EQ(sample_npix[5], buffer[5].num_bin_pixels);
  ASSERT_EQ(sample_npix[129], buffer[129].num_bin_pixels);

  for (std::size_t i = 1; i < buffer.size(); i++) {
    ASSERT_EQ(buffer[i].pix_pos,
              buffer[i - 1].pix_pos + buffer[i - 1].num_bin_pixels);
  }

  //--------------------------------------------------------------------------------------------
  pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 0,
               false);
  std::vector<pix_mem_map::bin_info> buffer1(1);

  pix_map.read_bins(0, buffer1, bin_end, buf_end);
  ASSERT_EQ(1, bin_end);
  ASSERT_EQ(1, buf_end);
  ASSERT_EQ(sample_npix[0], buffer[0].num_bin_pixels);

  pix_map.read_bins(125, buffer1, bin_end, buf_end);
  ASSERT_EQ(sample_npix[125], buffer1[0].num_bin_pixels);
  ASSERT_EQ(126, bin_end);
  ASSERT_EQ(1, buf_end);

  pix_map.read_bins(115, buffer1, bin_end, buf_end);
  ASSERT_EQ(sample_npix[115], buffer1[0].num_bin_pixels);
  ASSERT_EQ(116, bin_end);
  ASSERT_EQ(1, buf_end);

  pix_map.read_bins(5, buffer1, bin_end, buf_end);
  ASSERT_EQ(sample_npix[5], buffer1[0].num_bin_pixels);

  //--------------------------------------------------------------------------------------------

  pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 0,
               false);
  std::vector<pix_mem_map::bin_info> buffer2(128);

  pix_map.read_bins(0, buffer2, bin_end, buf_end);

  ASSERT_EQ(128, bin_end);
  ASSERT_EQ(128, buf_end);
  ASSERT_EQ(sample_npix[125], buffer2[125].num_bin_pixels);
  ASSERT_EQ(sample_npix[115], buffer2[115].num_bin_pixels);
  ASSERT_EQ(sample_npix[114], buffer2[114].num_bin_pixels);
  ASSERT_EQ(sample_npix[0], buffer2[0].num_bin_pixels);
  ASSERT_EQ(sample_npix[1], buffer2[1].num_bin_pixels);
  ASSERT_EQ(sample_npix[5], buffer2[5].num_bin_pixels);

  for (std::size_t i = 1; i < buffer2.size(); i++) {
    ASSERT_EQ(buffer2[i].pix_pos,
              buffer[i - 1].pix_pos + buffer[i - 1].num_bin_pixels);
  }

  pix_map.read_bins(num_bin_in_file - 2, buffer2, bin_end, buf_end);
  ASSERT_EQ(num_bin_in_file, bin_end);
  ASSERT_EQ(2, buf_end);
}
