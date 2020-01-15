#include "combine_sqw/combine_sqw.h"
#include "combine_sqw/nsqw_pix_reader.h"
#include "combine_sqw/pix_mem_map.h"
#include "combine_sqw/sqw_pix_writer.h"
#include "utility/environment.h"

#include <gtest/gtest.h>

#include <vector>

using namespace Horace::Utility;

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
    std::string HORACE_ROOT {
        Environment::get_env_variable(Environment::HORACE_ROOT, ".")};
    test_file_name = HORACE_ROOT + "/_test/test_symmetrisation/w3d_sqw.sqw";
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
std::size_t TestCombineSQW::num_bin_in_file, TestCombineSQW::bin_pos_in_file,
    TestCombineSQW::pix_pos_in_file;

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

TEST_F(TestCombineSQW, Get_NPix_For_Bins) {
    // test_get_npix_for_bins
    pix_mem_map pix_map;

    pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 0, false);

    // number of pixels in file is unknown
    ASSERT_EQ(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

    size_t pix_start, npix;
    pix_map.get_npix_for_bin(0, pix_start, npix);
    ASSERT_EQ(0, pix_start);
    ASSERT_EQ(sample_npix[0], npix);

    pix_map.get_npix_for_bin(114, pix_start, npix);
    ASSERT_EQ(sample_npix[114], npix);
    ASSERT_EQ(sample_pix_pos[114], pix_start);

    pix_map.get_npix_for_bin(511, pix_start, npix);
    ASSERT_EQ(sample_npix[511], npix);
    ASSERT_EQ(sample_pix_pos[511], pix_start);

    pix_map.get_npix_for_bin(600, pix_start, npix);
    ASSERT_EQ(sample_npix[600], npix);
    ASSERT_EQ(sample_pix_pos[600], pix_start);

    pix_map.get_npix_for_bin(2400, pix_start, npix);
    ASSERT_EQ(sample_npix[2400], npix);
    ASSERT_EQ(sample_pix_pos[2400], pix_start);

    // number of pixels in file is unknown
    ASSERT_EQ(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());
    pix_map.get_npix_for_bin(2, pix_start, npix);

    ASSERT_EQ(sample_npix[2], npix);
    ASSERT_EQ(sample_pix_pos[2], pix_start);

    pix_map.get_npix_for_bin(num_bin_in_file - 2, pix_start, npix);
    ASSERT_EQ(sample_npix[num_bin_in_file - 2], 0);
    ASSERT_EQ(sample_pix_pos[num_bin_in_file - 2], pix_start);

    // number of pixels in file is known
    ASSERT_NE(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

    ASSERT_EQ(pix_map.num_pix_in_file(), sample_pix_pos[num_bin_in_file - 1] + sample_npix[num_bin_in_file - 1]);
}

TEST_F(TestCombineSQW, Fully_Expand_Pix_Map_From_Start) {
    pix_mem_map pix_map;

    pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 512, false);

    bool end_pix_reached;
    size_t num_pix = pix_map.check_expand_pix_map(4, 512, end_pix_reached);
    ASSERT_FALSE(end_pix_reached);
    ASSERT_EQ(512, num_pix);

    // Read whole map in memory requesting map for much bigger number of npixels then the real npix number in the file.
    num_pix = pix_map.check_expand_pix_map(0, 2 * 1164180, end_pix_reached);
    // the file contains
    ASSERT_EQ(sample_pix_pos[num_bin_in_file - 1] + sample_npix[num_bin_in_file - 1], num_pix);
    ASSERT_TRUE(end_pix_reached);
    // check whole map is loaded in memory
    size_t first_mem_bin, last_mem_bin, n_tot_bins;
    pix_map.get_map_param(first_mem_bin, last_mem_bin, n_tot_bins);
    ASSERT_EQ(first_mem_bin, 0);
    ASSERT_EQ(last_mem_bin, n_tot_bins);
    ASSERT_EQ(last_mem_bin, num_bin_in_file);

    for (size_t i = 0; i < num_bin_in_file; i++) {
        size_t pix_start, npix;
        pix_map.get_npix_for_bin(i, pix_start, npix);
        ASSERT_EQ(pix_start, sample_pix_pos[i]);
        ASSERT_EQ(npix, sample_npix[i]);
    }
    ASSERT_EQ(pix_map.num_pix_in_file(), num_pix);
}

TEST_F(TestCombineSQW, Check_Expand_Pix_Map) {
    pix_mem_map pix_map;

    pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 512, false);

    bool end_pix_reached;
    size_t num_pix0 = pix_map.check_expand_pix_map(511, 512, end_pix_reached);
    ASSERT_FALSE(end_pix_reached);
    ASSERT_EQ(510, num_pix0);

    size_t pix_pos, npix;
    pix_map.get_npix_for_bin(511, pix_pos, npix);
    ASSERT_EQ(sample_pix_pos[511], pix_pos);
    ASSERT_EQ(sample_npix[511], npix);

    // Read whole map in memory requesting map for much bigger number of npixels then the real npix number in the file.
    size_t num_pix = pix_map.check_expand_pix_map(512, 2 * 1164180, end_pix_reached);
    // the file contains
    ASSERT_EQ(sample_pix_pos[num_bin_in_file - 1] + sample_npix[num_bin_in_file - 1] - pix_pos - npix, num_pix);
    ASSERT_TRUE(end_pix_reached);

    for (size_t i = 512; i < num_bin_in_file; i++) {
        size_t pix_start, npix;
        pix_map.get_npix_for_bin(i, pix_start, npix);
        ASSERT_EQ(pix_start, sample_pix_pos[i]);
        ASSERT_EQ(npix, sample_npix[i]);

    }
    ASSERT_EQ(pix_map.num_pix_in_file(), num_pix + pix_pos + npix);

    num_pix = pix_map.check_expand_pix_map(512, 512, end_pix_reached);
    ASSERT_FALSE(end_pix_reached);
    ASSERT_EQ(512, num_pix);

    num_pix = pix_map.check_expand_pix_map(4, 512, end_pix_reached);
    ASSERT_FALSE(end_pix_reached);
    ASSERT_EQ(512, num_pix);

    pix_map.get_npix_for_bin(512 + 4, pix_pos, npix);
    ASSERT_EQ(sample_pix_pos[512 + 4], pix_pos);
    ASSERT_EQ(sample_npix[512 + 4], npix);
}

TEST_F(TestCombineSQW, Normal_Expand_Mode) {
    pix_mem_map pix_map;

    pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 512, false);
    size_t pix_pos, npix;
    pix_map.get_npix_for_bin(0, pix_pos, npix);
    ASSERT_EQ(sample_pix_pos[0], pix_pos);
    ASSERT_EQ(sample_npix[0], npix);

    bool end_pix_reached;

    size_t bin_num(0), pix_buf_size(512), num_pix, ic(0);
    while (bin_num < num_bin_in_file - pix_buf_size) {
        bin_num += pix_buf_size;
        pix_map.get_npix_for_bin(bin_num, pix_pos, npix);
        size_t n_pix = pix_map.num_pix_described(bin_num);
        if (n_pix < pix_buf_size) {
            num_pix = pix_map.check_expand_pix_map(bin_num, pix_buf_size, end_pix_reached);
        }
        ASSERT_EQ(sample_pix_pos[bin_num], pix_pos);
        ASSERT_EQ(sample_npix[bin_num], npix);
        ic++;
    }
}

TEST_F(TestCombineSQW, Thread_Job) {
    pix_map_tester pix_map;
    pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 0, true);
    size_t first_th_bin,last_tr_bin,buf_end;

    pix_map.thread_query_data(first_th_bin, last_tr_bin, buf_end);
    ASSERT_EQ(first_th_bin,0);
    ASSERT_EQ(last_tr_bin, 1024);
    ASSERT_EQ(buf_end,1024);

    pix_map.thread_request_to_read(1600);
    pix_map.thread_query_data(first_th_bin, last_tr_bin, buf_end);
    ASSERT_EQ(first_th_bin, 1600);
    ASSERT_EQ(last_tr_bin, 1600+1024);
    ASSERT_EQ(buf_end, 1024);

    std::vector<pix_mem_map::bin_info> buf;
    pix_map.thread_get_data(first_th_bin, buf,last_tr_bin, buf_end);

    pix_map.thread_query_data(first_th_bin, last_tr_bin, buf_end);
    ASSERT_EQ(first_th_bin, 1024+1600);
    ASSERT_EQ(last_tr_bin, 1600 + 2048);
    ASSERT_EQ(buf_end, 1024);
}

TEST_F(TestCombineSQW, Get_NPix_For_Bins_Threads) {
    pix_mem_map pix_map;

    pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 0, true);

    // number of pixels in file is unknown
    ASSERT_EQ(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

    size_t pix_start, npix;
    pix_map.get_npix_for_bin(0, pix_start, npix);
    ASSERT_EQ(0, pix_start);
    ASSERT_EQ(sample_npix[0], npix);

    pix_map.get_npix_for_bin(114, pix_start, npix);
    ASSERT_EQ(sample_npix[114], npix);
    ASSERT_EQ(sample_pix_pos[114], pix_start);

    pix_map.get_npix_for_bin(511, pix_start, npix);
    ASSERT_EQ(sample_npix[511], npix);
    ASSERT_EQ(sample_pix_pos[511], pix_start);

    pix_map.get_npix_for_bin(600, pix_start, npix);
    ASSERT_EQ(sample_npix[600], npix);
    ASSERT_EQ(sample_pix_pos[600], pix_start);

    pix_map.get_npix_for_bin(2400, pix_start, npix);
    ASSERT_EQ(sample_npix[2400], npix);
    ASSERT_EQ(sample_pix_pos[2400], pix_start);

    // number of pixels in file is unknown
    ASSERT_EQ(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

    pix_map.get_npix_for_bin(2, pix_start, npix);
    ASSERT_EQ(sample_npix[2], npix);
    ASSERT_EQ(sample_pix_pos[2], pix_start);

    pix_map.get_npix_for_bin(num_bin_in_file - 2, pix_start, npix);
    ASSERT_EQ(sample_npix[num_bin_in_file - 2], 0);
    ASSERT_EQ(sample_pix_pos[num_bin_in_file - 2], pix_start);

    // number of pixels in file is known
    ASSERT_NE(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

    ASSERT_EQ(pix_map.num_pix_in_file(), sample_pix_pos[num_bin_in_file - 1] + sample_npix[num_bin_in_file - 1]);
}

TEST_F(TestCombineSQW, Fully_Expand_Pix_Map_From_Start_Threads) {
    pix_mem_map pix_map;

    pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 512, true);

    bool end_pix_reached;
    size_t num_pix = pix_map.check_expand_pix_map(4, 512, end_pix_reached);
    ASSERT_FALSE(end_pix_reached);
    ASSERT_EQ(512, num_pix);

    // Read whole map in memory requesting map for much bigger number of npixels then the real npix number in the file.
    num_pix = pix_map.check_expand_pix_map(0, 2 * 1164180, end_pix_reached);
    // the file contains
    ASSERT_EQ(sample_pix_pos[num_bin_in_file - 1] + sample_npix[num_bin_in_file - 1], num_pix);
    ASSERT_TRUE(end_pix_reached);
    // check whole map is loaded in memory
    size_t first_mem_bin, last_mem_bin, n_tot_bins;
    pix_map.get_map_param(first_mem_bin, last_mem_bin, n_tot_bins);
    ASSERT_EQ(first_mem_bin,0);
    ASSERT_EQ(last_mem_bin, n_tot_bins);
    ASSERT_EQ(last_mem_bin, num_bin_in_file);

    for (size_t i = 0; i < num_bin_in_file; i++) {
        size_t pix_start, npix;
        pix_map.get_npix_for_bin(i, pix_start, npix);
        ASSERT_EQ(pix_start, sample_pix_pos[i]);
        ASSERT_EQ(npix, sample_npix[i]);

    }
    ASSERT_EQ(pix_map.num_pix_in_file(), num_pix);
}

TEST_F(TestCombineSQW, Check_Expand_Pix_Map_Threads) {
    pix_mem_map pix_map;
    pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 512, true);

    bool end_pix_reached;
    size_t num_pix1 = pix_map.check_expand_pix_map(511, 512, end_pix_reached);
    ASSERT_FALSE(end_pix_reached);
    ASSERT_EQ(510, num_pix1);

    size_t pix_pos, npix;
    pix_map.get_npix_for_bin(511, pix_pos, npix);
    ASSERT_EQ(sample_pix_pos[511], pix_pos);
    ASSERT_EQ(sample_npix[511], npix);

    // Read whole map in memory requesting map for much bigger number of npixels then the real npix number in the file.
    size_t num_pix = pix_map.check_expand_pix_map(512, 2 * 1164180, end_pix_reached);
    // the file contains
    ASSERT_EQ(sample_pix_pos[num_bin_in_file - 1] + sample_npix[num_bin_in_file - 1] - pix_pos - npix, num_pix);
    ASSERT_TRUE(end_pix_reached);

    for (size_t i = 512; i < num_bin_in_file; i++) {
        size_t pix_start, npix;
        pix_map.get_npix_for_bin(i, pix_start, npix);
        ASSERT_EQ(pix_start, sample_pix_pos[i]);
        ASSERT_EQ(npix, sample_npix[i]);
    }
    ASSERT_EQ(pix_map.num_pix_in_file(), num_pix + pix_pos + npix);

    num_pix = pix_map.check_expand_pix_map(512, 512, end_pix_reached);
    ASSERT_FALSE(end_pix_reached);
    ASSERT_EQ(512, num_pix);

    num_pix = pix_map.check_expand_pix_map(4, 512, end_pix_reached);
    ASSERT_FALSE(end_pix_reached);
    ASSERT_EQ(512, num_pix);

    pix_map.get_npix_for_bin(512 + 4, pix_pos, npix);
    ASSERT_EQ(sample_pix_pos[512 + 4], pix_pos);
    ASSERT_EQ(sample_npix[512 + 4], npix);
}

TEST_F(TestCombineSQW, Normal_Expand_Mode_Threads) {
    pix_mem_map pix_map;
    pix_map.init(this->test_file_name, bin_pos_in_file, num_bin_in_file, 512, true);

    size_t pix_pos, npix;
    pix_map.get_npix_for_bin(0, pix_pos, npix);
    ASSERT_EQ(sample_pix_pos[0], pix_pos);
    ASSERT_EQ(sample_npix[0], npix);

    bool end_pix_reached;

    size_t bin_num(0), pix_buf_size(512), num_pix, ic(0);
    while (bin_num < num_bin_in_file - pix_buf_size) {
        bin_num += pix_buf_size;
        pix_map.get_npix_for_bin(bin_num, pix_pos, npix);
        size_t n_pix = pix_map.num_pix_described(bin_num);
        if (n_pix < pix_buf_size) {
            num_pix = pix_map.check_expand_pix_map(bin_num, pix_buf_size, end_pix_reached);
        }
        ASSERT_EQ(sample_pix_pos[bin_num], pix_pos);
        ASSERT_EQ(sample_npix[bin_num], npix);
        ic++;
    }
}

TEST_F(TestCombineSQW, SQW_Reader_Propagate_Pix) {
    sqw_reader reader;
    fileParameters file_par;
    file_par.fileName = test_file_name;
    file_par.file_id = 0;
    file_par.nbin_start_pos = bin_pos_in_file;
    file_par.pix_start_pos = pix_pos_in_file;
    file_par.total_NfileBins = num_bin_in_file;
    bool initialized(false);
    try {
        reader.init(file_par, false, false, 128);
        initialized = true;
    }
    catch (...) {}

    ASSERT_TRUE(initialized);

    size_t pix_start_num, num_bin_pix,start_buf_pos(0);
    std::vector<float> pix_buffer(9*1000);
    float *pPix_info = &pix_buffer[0];

    reader.get_pix_for_bin(0,pPix_info, start_buf_pos,pix_start_num,num_bin_pix,false);
    ASSERT_EQ(pix_start_num,0);
    ASSERT_EQ(num_bin_pix, 3);
    for(size_t i=0;i<num_bin_pix *9;i++){
        ASSERT_EQ(pixels[pix_start_num*9+i], pix_buffer[i]);
    }
    // pix buffer have not changed at all
    reader.get_pix_for_bin(127, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, 338);
    ASSERT_EQ(num_bin_pix, 0);

    reader.get_pix_for_bin(126, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, 334);
    ASSERT_EQ(num_bin_pix, 4);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num*9+i], pix_buffer[i]);
    }

    start_buf_pos = 5;
    reader.get_pix_for_bin(num_bin_in_file-860, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, sample_pix_pos[num_bin_in_file - 860]);
    ASSERT_EQ(num_bin_pix, sample_npix[num_bin_in_file - 860]);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[start_buf_pos*9 + i]);
    }

    reader.get_pix_for_bin(num_bin_in_file - 860+1, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, sample_pix_pos[num_bin_in_file - 860+1]);
    ASSERT_EQ(num_bin_pix, sample_npix[num_bin_in_file - 860+1]);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[start_buf_pos * 9 + i]);
    }

    start_buf_pos = 2;
    reader.get_pix_for_bin(num_bin_in_file - 1, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, sample_pix_pos[num_bin_in_file - 1]);
    ASSERT_EQ(num_bin_pix, sample_npix[num_bin_in_file - 1]);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[start_buf_pos * 9 + i]);
    }
}

TEST_F(TestCombineSQW, SQW_Reader_NoBuf_Mode) {
    sqw_reader reader;
    fileParameters file_par;
    file_par.fileName = test_file_name;
    file_par.file_id = 0;
    file_par.nbin_start_pos = bin_pos_in_file;
    file_par.pix_start_pos = pix_pos_in_file;
    file_par.total_NfileBins = num_bin_in_file;
    bool initialized(false);
    try {
        reader.init(file_par, false, false, 0);
        initialized = true;
    }
    catch (...) {}

    ASSERT_TRUE(initialized);

    size_t pix_start_num, num_bin_pix, start_buf_pos(0);
    std::vector<float> pix_buffer(9 * 1000);
    float *pPix_info = &pix_buffer[0];

    reader.get_pix_for_bin(0, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, 0);
    ASSERT_EQ(num_bin_pix, 3);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[i]);
    }
    // pix buffer have not changed at all
    reader.get_pix_for_bin(127, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, 338);
    ASSERT_EQ(num_bin_pix, 0);

    reader.get_pix_for_bin(126, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, 334);
    ASSERT_EQ(num_bin_pix, 4);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[i]);
    }
    start_buf_pos = 5;
    reader.get_pix_for_bin(num_bin_in_file - 860, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, sample_pix_pos[num_bin_in_file - 860]);
    ASSERT_EQ(num_bin_pix, sample_npix[num_bin_in_file - 860]);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[start_buf_pos * 9 + i]);
    }

    reader.get_pix_for_bin(num_bin_in_file - 860 + 1, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, sample_pix_pos[num_bin_in_file - 860 + 1]);
    ASSERT_EQ(num_bin_pix, sample_npix[num_bin_in_file - 860 + 1]);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[start_buf_pos * 9 + i]);
    }

    start_buf_pos = 2;
    reader.get_pix_for_bin(num_bin_in_file - 1, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, sample_pix_pos[num_bin_in_file - 1]);
    ASSERT_EQ(num_bin_pix, sample_npix[num_bin_in_file - 1]);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[start_buf_pos * 9 + i]);
    }
}

TEST_F(TestCombineSQW, SQW_Reader_Propagate_Pix_Threads) {
    sqw_reader reader;
    fileParameters file_par;
    file_par.fileName = test_file_name;
    file_par.file_id = 0;
    file_par.nbin_start_pos = bin_pos_in_file;
    file_par.pix_start_pos = pix_pos_in_file;
    file_par.total_NfileBins = num_bin_in_file;
    bool initialized(false);
    try {
        reader.init(file_par, false, false, 128,1);
        initialized = true;
    }
    catch (...) {}

    ASSERT_TRUE(initialized);

    size_t pix_start_num, num_bin_pix, start_buf_pos(0);
    std::vector<float> pix_buffer(9 * 1000);
    float *pPix_info = &pix_buffer[0];

    reader.get_pix_for_bin(0, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, 0);
    ASSERT_EQ(num_bin_pix, 3);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[i]);
    }
    // pix buffer have not changed at all
    reader.get_pix_for_bin(127, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, 338);
    ASSERT_EQ(num_bin_pix, 0);

    reader.get_pix_for_bin(126, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, 334);
    ASSERT_EQ(num_bin_pix, 4);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[i]);
    }
    start_buf_pos = 5;
    reader.get_pix_for_bin(num_bin_in_file - 860, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, sample_pix_pos[num_bin_in_file - 860]);
    ASSERT_EQ(num_bin_pix, sample_npix[num_bin_in_file - 860]);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[start_buf_pos * 9 + i]);
    }
    reader.get_pix_for_bin(num_bin_in_file - 860 + 1, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, sample_pix_pos[num_bin_in_file - 860 + 1]);
    ASSERT_EQ(num_bin_pix, sample_npix[num_bin_in_file - 860 + 1]);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[start_buf_pos * 9 + i]);
    }

    start_buf_pos = 2;
    reader.get_pix_for_bin(num_bin_in_file - 1, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
    ASSERT_EQ(pix_start_num, sample_pix_pos[num_bin_in_file - 1]);
    ASSERT_EQ(num_bin_pix, sample_npix[num_bin_in_file - 1]);
    for (size_t i = 0; i<num_bin_pix * 9; i++) {
        ASSERT_EQ(pixels[pix_start_num * 9 + i], pix_buffer[start_buf_pos * 9 + i]);
    }
}

TEST_F(TestCombineSQW, SQW_Reader_Read_All) {
    sqw_reader reader;
    fileParameters file_par;
    file_par.fileName = test_file_name;
    file_par.file_id = 0;
    file_par.nbin_start_pos = bin_pos_in_file;
    file_par.pix_start_pos = pix_pos_in_file;
    file_par.total_NfileBins = num_bin_in_file;
    std::vector<float> pix_buffer;
    pix_buffer.resize(this->pixels.size());
    float *pPix_info = &pix_buffer[0];

    size_t start_buf_pos(0), pix_start_num, num_bin_pix;
    //--------------------------------------------------------------------------------------------
    reader.init(file_par, false, false, 0);
    //
    auto t_start = std::chrono::steady_clock::now();
    start_buf_pos = 0;
    for (size_t i = 0; i < this->num_bin_in_file; i++) {
        reader.get_pix_for_bin(i, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
        start_buf_pos += num_bin_pix;
    }
    auto t_end = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now() - t_start).count();
    std::cout << "\n Time to run single thread with system buffer: " << t_end << "ms\n";

    for (size_t i = 0; i < pix_buffer.size(); i++) {
        ASSERT_EQ(pix_buffer[i], pixels[i]);
        pix_buffer[i] = 0;
    }
    //--------------------------------------------------------------------------------------------
    //
    reader.init(file_par, false, false, 1024);
    //
    t_start = std::chrono::steady_clock::now();
    start_buf_pos = 0;
    for (size_t i = 0; i < this->num_bin_in_file; i++) {
        reader.get_pix_for_bin(i, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
        start_buf_pos += num_bin_pix;
    }
    t_end = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now() - t_start).count();
    std::cout << "\n Time to run single thread with 1024 words buffer: " << t_end << "ms\n";


    for (size_t i = 0; i < pix_buffer.size(); i++) {
        ASSERT_EQ(pix_buffer[i], pixels[i]);
        pix_buffer[i] = 0;
    }

    //--------------------------------------------------------------------------------------------
    reader.init(file_par, false, false, 512, 1);

    t_start = std::chrono::steady_clock::now();
    start_buf_pos = 0;
    for (size_t i = 0; i < this->num_bin_in_file; i++) {
        reader.get_pix_for_bin(i, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
        start_buf_pos += num_bin_pix;
    }
    t_end = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now() - t_start).count();
    std::cout << "\n Time to run threads: " << t_end << "ms\n";

    for (size_t i = 0; i < pix_buffer.size(); i++) {
        ASSERT_EQ(pix_buffer[i], pixels[i]);
        pix_buffer[i] = 0;
    }

    //--------------------------------------------------------------------------------------------
    reader.init(file_par, false, false, 0);
    //
    t_start = std::chrono::steady_clock::now();
    start_buf_pos = 0;
    for (size_t i = 0; i < this->num_bin_in_file; i++) {
        reader.get_pix_for_bin(i, pPix_info, start_buf_pos, pix_start_num, num_bin_pix, false);
        start_buf_pos += num_bin_pix;
    }
    t_end = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now() - t_start).count();
    std::cout << "\n Time to run single thread with system buffer: " << t_end << "ms\n";
}


TEST_F(TestCombineSQW, MXSQW_Reader_Propagate_Pix_Multi) {
    std::vector<sqw_reader> reader_noThread(1);

    fileParameters file_par;
    file_par.fileName = test_file_name;
    file_par.file_id = 0;
    file_par.nbin_start_pos = bin_pos_in_file;
    file_par.pix_start_pos  = pix_pos_in_file;
    file_par.total_NfileBins = num_bin_in_file;
    bool initialized(false);
    try {
        //(fileParam[i], change_fileno, fileno_provided, read_buf_size, read_files_multitreaded);
        reader_noThread[0].init(file_par, false, false, 64, 0);
        initialized = true;
    }
    catch (...) {
    }

    ASSERT_TRUE(initialized);

    ProgParameters ProgSettings;
    ProgSettings.log_level = 2;
    ProgSettings.nBin2read = 0;
    ProgSettings.num_log_ticks = 100;
    ProgSettings.pixBufferSize = 1164180;
    ProgSettings.totNumBins = num_bin_in_file;

    exchange_buffer Buffer(ProgSettings.pixBufferSize, file_par.total_NfileBins, ProgSettings.num_log_ticks);
    nsqw_pix_reader Reader(ProgSettings, reader_noThread, Buffer);

    std::vector<uint64_t> nbin_Buffer_noThreads(ProgSettings.totNumBins,-1);
    uint64_t *nbinBuf = &nbin_Buffer_noThreads[0];

    size_t n_buf_pixels, n_bins_processed(0);
    Reader.read_pix_info(n_buf_pixels, n_bins_processed, nbinBuf);

    ASSERT_EQ(n_buf_pixels, ProgSettings.pixBufferSize);
    ASSERT_EQ(n_bins_processed+1, ProgSettings.totNumBins);

    size_t nReadPixels, n_bin_max;
    const float * buf = reinterpret_cast<const float *>(Buffer.get_write_buffer(nReadPixels, n_bin_max));
    Buffer.unlock_write_buffer();
    ASSERT_EQ(nReadPixels, ProgSettings.pixBufferSize);
    //---------------------------------------------------------------------
    std::vector<sqw_reader> reader_threads(1);
    initialized=false;
    try {
        //(fileParam[i], change_fileno, fileno_provided, read_buf_size, read_files_multitreaded);
        reader_threads[0].init(file_par, false, false, 64, 1);
        initialized = true;
    }
    catch (...) {
    }
    ASSERT_TRUE(initialized);

    nsqw_pix_reader ReaderThr(ProgSettings, reader_threads, Buffer);

    std::vector<uint64_t> nbin_Buffer_Threads(ProgSettings.totNumBins,-1);
    uint64_t *nbinBufThr  = &nbin_Buffer_Threads[0];

    n_bins_processed = 0;
    ReaderThr.read_pix_info(n_buf_pixels, n_bins_processed, nbinBufThr);

    ASSERT_EQ(n_buf_pixels, ProgSettings.pixBufferSize);
    ASSERT_EQ(n_bins_processed + 1, ProgSettings.totNumBins);

    const float * buf1 = reinterpret_cast<const float *>(Buffer.get_write_buffer(nReadPixels, n_bin_max));
    Buffer.unlock_write_buffer();
    ASSERT_EQ(nReadPixels, ProgSettings.pixBufferSize);

    for (size_t i = 0; i < n_bins_processed + 1; i+=10) {
        ASSERT_EQ(nbin_Buffer_Threads[i], nbin_Buffer_noThreads[i]) << "bin N" << i;
    }
    for (size_t i = 0; i < n_buf_pixels; i+=100) {
        size_t n_pix = i/9;
        ASSERT_EQ(buf[i], buf1[i]) << "pix N" << n_pix;
    }
}

TEST_F(TestCombineSQW, Failing_Test) {
	ASSERT_EQ(1,0);
}
