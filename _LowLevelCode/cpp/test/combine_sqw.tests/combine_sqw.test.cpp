#include "combine_sqw/combine_sqw.h"
#include "combine_sqw/nsqw_pix_reader.h"
#include "combine_sqw/sqw_pix_writer.h"
#include "test/combine_sqw.tests/pix_map_tester.h"
#include "utility/environment.h"

#include <gtest/gtest.h>

#include <vector>

using namespace Horace::Utility;

const std::string HORACE_ROOT{
    Environment::get_env_variable(Environment::HORACE_ROOT, ".")};
const std::string TEST_FILE_NAME{HORACE_ROOT +
                                 "/_test/test_symmetrisation/w3d_sqw.sqw"};

const std::size_t NUM_BINS_IN_FILE{472392};
const std::size_t BIN_POS_IN_FILE{5194471};
const std::size_t PIX_POS_IN_FILE{8973651};
const std::size_t NUM_PIXELS{1164180};
const int NUM_PIXBLOCK_COLS{9};

class TestCombineSQW : public ::testing::Test {

protected:
  static std::vector<uint64_t> sample_npix;
  static std::vector<uint64_t> sample_pix_pos;
  static std::vector<float> pixels;

  // Called once, before the first test is executed.
  static void SetUpTestSuite() {
    std::ifstream data_file_bin(TEST_FILE_NAME,
                                std::ios::in | std::ios::binary);
    if (!data_file_bin.is_open()) {
      throw std::runtime_error("Can not open test data file");
    }
    try {
      // Read npix data
      data_file_bin.seekg(BIN_POS_IN_FILE);
      data_file_bin.read(reinterpret_cast<char *>(sample_npix.data()),
                         NUM_BINS_IN_FILE * sizeof(sample_npix[0]));
      // Fill the sample_pix_pos vector
      for (std::size_t i = 1; i < sample_npix.size(); i++) {
        sample_pix_pos[i] = sample_pix_pos[i - 1] + sample_npix[i - 1];
      }

      // Read pixel data
      data_file_bin.seekg(PIX_POS_IN_FILE);
      data_file_bin.read(reinterpret_cast<char *>(pixels.data()),
                         NUM_PIXELS * NUM_PIXBLOCK_COLS * sizeof(pixels[0]));
    } catch (...) {
      data_file_bin.close();
      throw;
    }
  }
};

std::vector<uint64_t> TestCombineSQW::sample_npix(NUM_BINS_IN_FILE, 0);
std::vector<uint64_t> TestCombineSQW::sample_pix_pos(NUM_BINS_IN_FILE, 0);
std::vector<float> TestCombineSQW::pixels(NUM_PIXELS *NUM_PIXBLOCK_COLS, 0);

TEST_F(TestCombineSQW,
       read_bins_extracts_correct_bin_data_from_file_reading_from_start) {
  PixMapTester pix_map;
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE, 128, false);

  std::vector<pix_mem_map::bin_info> buffer(256);
  std::size_t bin_end, buf_end;
  pix_map.read_bins(0, buffer, bin_end, buf_end);

  EXPECT_EQ(256, bin_end);
  EXPECT_EQ(256, buf_end);
  for (std::size_t i = 1; i < buffer.size(); i++) {
    EXPECT_EQ(sample_npix[i], buffer[i].num_bin_pixels);
  }
  for (std::size_t i = 1; i < buffer.size(); i++) {
    EXPECT_EQ(buffer[i].pix_pos,
              buffer[i - 1].pix_pos + buffer[i - 1].num_bin_pixels);
  }
}

TEST_F(TestCombineSQW,
       read_bins_extracts_correct_bin_data_from_file_reading_from_given_index) {
  PixMapTester pix_map;
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE, 0, false);

  std::vector<pix_mem_map::bin_info> buffer(1);
  std::size_t bin_end, buf_end;
  pix_map.read_bins(0, buffer, bin_end, buf_end);
  EXPECT_EQ(1, bin_end);
  EXPECT_EQ(1, buf_end);
  EXPECT_EQ(sample_npix[0], buffer[0].num_bin_pixels);

  pix_map.read_bins(125, buffer, bin_end, buf_end);
  EXPECT_EQ(sample_npix[125], buffer[0].num_bin_pixels);
  EXPECT_EQ(126, bin_end);
  EXPECT_EQ(1, buf_end);

  pix_map.read_bins(115, buffer, bin_end, buf_end);
  EXPECT_EQ(sample_npix[115], buffer[0].num_bin_pixels);
  EXPECT_EQ(116, bin_end);
  EXPECT_EQ(1, buf_end);

  pix_map.read_bins(5, buffer, bin_end, buf_end);
  EXPECT_EQ(sample_npix[5], buffer[0].num_bin_pixels);
}

TEST_F(TestCombineSQW, Read_NBins) {
  PixMapTester pix_map;
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE, 0, false);

  std::size_t bin_end, buf_end;
  std::vector<pix_mem_map::bin_info> buffer(128);
  pix_map.read_bins(0, buffer, bin_end, buf_end);

  EXPECT_EQ(128, bin_end);
  EXPECT_EQ(128, buf_end);
  EXPECT_EQ(sample_npix[125], buffer[125].num_bin_pixels);
  EXPECT_EQ(sample_npix[115], buffer[115].num_bin_pixels);
  EXPECT_EQ(sample_npix[114], buffer[114].num_bin_pixels);
  EXPECT_EQ(sample_npix[0], buffer[0].num_bin_pixels);
  EXPECT_EQ(sample_npix[1], buffer[1].num_bin_pixels);
  EXPECT_EQ(sample_npix[5], buffer[5].num_bin_pixels);

  for (std::size_t i = 1; i < buffer.size(); i++) {
    EXPECT_EQ(buffer[i].pix_pos,
              buffer[i - 1].pix_pos + buffer[i - 1].num_bin_pixels);
  }

  pix_map.read_bins(NUM_BINS_IN_FILE - 2, buffer, bin_end, buf_end);
  EXPECT_EQ(NUM_BINS_IN_FILE, bin_end);
  EXPECT_EQ(2, buf_end);
}

TEST_F(TestCombineSQW, Get_NPix_For_Bins) {
  // test_get_npix_for_bins
  pix_mem_map pix_map;

  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE, 0, false);

  // number of pixels in file is unknown
  EXPECT_EQ(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

  std::size_t pix_start, npix;
  pix_map.get_npix_for_bin(0, pix_start, npix);
  EXPECT_EQ(0, pix_start);
  EXPECT_EQ(sample_npix[0], npix);

  pix_map.get_npix_for_bin(114, pix_start, npix);
  EXPECT_EQ(sample_npix[114], npix);
  EXPECT_EQ(sample_pix_pos[114], pix_start);

  pix_map.get_npix_for_bin(511, pix_start, npix);
  EXPECT_EQ(sample_npix[511], npix);
  EXPECT_EQ(sample_pix_pos[511], pix_start);

  pix_map.get_npix_for_bin(600, pix_start, npix);
  EXPECT_EQ(sample_npix[600], npix);
  EXPECT_EQ(sample_pix_pos[600], pix_start);

  pix_map.get_npix_for_bin(2400, pix_start, npix);
  EXPECT_EQ(sample_npix[2400], npix);
  EXPECT_EQ(sample_pix_pos[2400], pix_start);

  // number of pixels in file is unknown
  EXPECT_EQ(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());
  pix_map.get_npix_for_bin(2, pix_start, npix);

  EXPECT_EQ(sample_npix[2], npix);
  EXPECT_EQ(sample_pix_pos[2], pix_start);

  pix_map.get_npix_for_bin(NUM_BINS_IN_FILE - 2, pix_start, npix);
  EXPECT_EQ(sample_npix[NUM_BINS_IN_FILE - 2], 0);
  EXPECT_EQ(sample_pix_pos[NUM_BINS_IN_FILE - 2], pix_start);

  // number of pixels in file is known
  ASSERT_NE(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

  EXPECT_EQ(pix_map.num_pix_in_file(), sample_pix_pos[NUM_BINS_IN_FILE - 1] +
                                           sample_npix[NUM_BINS_IN_FILE - 1]);
}

TEST_F(TestCombineSQW, Fully_Expand_Pix_Map_From_Start) {
  pix_mem_map pix_map;
  const std::size_t pix_buffer_size{512};
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE,
               pix_buffer_size, false);

  bool end_pix_reached;
  std::size_t num_pix =
      pix_map.check_expand_pix_map(4, pix_buffer_size, end_pix_reached);
  ASSERT_FALSE(end_pix_reached);
  EXPECT_EQ(pix_buffer_size, num_pix);

  // Read whole map in memory requesting map for much bigger number of npixels
  // then the real npix number in the file.
  num_pix = pix_map.check_expand_pix_map(0, 2 * NUM_PIXELS, end_pix_reached);
  // the file contains
  EXPECT_EQ(sample_pix_pos[NUM_BINS_IN_FILE - 1] +
                sample_npix[NUM_BINS_IN_FILE - 1],
            num_pix);
  ASSERT_TRUE(end_pix_reached);
  // check whole map is loaded in memory
  std::size_t first_mem_bin, last_mem_bin, n_tot_bins;
  pix_map.get_map_param(first_mem_bin, last_mem_bin, n_tot_bins);
  EXPECT_EQ(first_mem_bin, 0);
  EXPECT_EQ(last_mem_bin, n_tot_bins);
  EXPECT_EQ(last_mem_bin, NUM_BINS_IN_FILE);

  for (std::size_t i = 0; i < NUM_BINS_IN_FILE; i++) {
    std::size_t pix_start, npix;
    pix_map.get_npix_for_bin(i, pix_start, npix);
    EXPECT_EQ(pix_start, sample_pix_pos[i]);
    EXPECT_EQ(npix, sample_npix[i]);
  }
  EXPECT_EQ(pix_map.num_pix_in_file(), num_pix);
}

TEST_F(TestCombineSQW, Check_Expand_Pix_Map) {
  pix_mem_map pix_map;
  const std::size_t pix_buffer_size{512};
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE,
               pix_buffer_size, false);

  bool end_pix_reached;
  const std::size_t final_pix_position{pix_buffer_size - 1};
  std::size_t num_pix0 = pix_map.check_expand_pix_map(
      final_pix_position, pix_buffer_size, end_pix_reached);
  ASSERT_FALSE(end_pix_reached);
  EXPECT_EQ(final_pix_position - 1, num_pix0);

  std::size_t pix_pos, npix;
  pix_map.get_npix_for_bin(final_pix_position, pix_pos, npix);
  EXPECT_EQ(sample_pix_pos[final_pix_position], pix_pos);
  EXPECT_EQ(sample_npix[final_pix_position], npix);

  // Read whole map in memory requesting map for much bigger number of npixels
  // then the real npix number in the file.
  std::size_t num_pix = pix_map.check_expand_pix_map(
      pix_buffer_size, 2 * NUM_PIXELS, end_pix_reached);
  // the file contains
  EXPECT_EQ(sample_pix_pos[NUM_BINS_IN_FILE - 1] +
                sample_npix[NUM_BINS_IN_FILE - 1] - pix_pos - npix,
            num_pix);
  ASSERT_TRUE(end_pix_reached);

  for (std::size_t i = pix_buffer_size; i < NUM_BINS_IN_FILE; i++) {
    std::size_t pix_start, npix;
    pix_map.get_npix_for_bin(i, pix_start, npix);
    EXPECT_EQ(pix_start, sample_pix_pos[i]);
    EXPECT_EQ(npix, sample_npix[i]);
  }
  EXPECT_EQ(pix_map.num_pix_in_file(), num_pix + pix_pos + npix);

  num_pix = pix_map.check_expand_pix_map(pix_buffer_size, pix_buffer_size,
                                         end_pix_reached);
  ASSERT_FALSE(end_pix_reached);
  EXPECT_EQ(pix_buffer_size, num_pix);

  num_pix = pix_map.check_expand_pix_map(4, pix_buffer_size, end_pix_reached);
  ASSERT_FALSE(end_pix_reached);
  EXPECT_EQ(pix_buffer_size, num_pix);

  pix_map.get_npix_for_bin(pix_buffer_size + 4, pix_pos, npix);
  EXPECT_EQ(sample_pix_pos[pix_buffer_size + 4], pix_pos);
  EXPECT_EQ(sample_npix[pix_buffer_size + 4], npix);
}

TEST_F(TestCombineSQW, Normal_Expand_Mode) {
  pix_mem_map pix_map;
  const std::size_t pix_buffer_size{512};
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE,
               pix_buffer_size, false);
  std::size_t pix_pos, npix;
  pix_map.get_npix_for_bin(0, pix_pos, npix);
  EXPECT_EQ(sample_pix_pos[0], pix_pos);
  EXPECT_EQ(sample_npix[0], npix);

  bool end_pix_reached;

  std::size_t bin_num(0), pix_buf_size(pix_buffer_size), ic(0);
  while (bin_num < NUM_BINS_IN_FILE - pix_buf_size) {
    bin_num += pix_buf_size;
    pix_map.get_npix_for_bin(bin_num, pix_pos, npix);
    std::size_t n_pix = pix_map.num_pix_described(bin_num);
    if (n_pix < pix_buf_size) {
      pix_map.check_expand_pix_map(bin_num, pix_buf_size, end_pix_reached);
    }
    EXPECT_EQ(sample_pix_pos[bin_num], pix_pos);
    EXPECT_EQ(sample_npix[bin_num], npix);
    ic++;
  }
}

TEST_F(TestCombineSQW, Thread_Job) {
  PixMapTester pix_map;
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE, 0, true);
  std::size_t first_th_bin, last_tr_bin, buf_end;

  pix_map.thread_query_data(first_th_bin, last_tr_bin, buf_end);
  EXPECT_EQ(first_th_bin, 0);
  EXPECT_EQ(last_tr_bin, 1024);
  EXPECT_EQ(buf_end, 1024);

  pix_map.thread_request_to_read(1600);
  pix_map.thread_query_data(first_th_bin, last_tr_bin, buf_end);
  EXPECT_EQ(first_th_bin, 1600);
  EXPECT_EQ(last_tr_bin, 1600 + 1024);
  EXPECT_EQ(buf_end, 1024);

  std::vector<pix_mem_map::bin_info> buf;
  pix_map.thread_get_data(first_th_bin, buf, last_tr_bin, buf_end);

  pix_map.thread_query_data(first_th_bin, last_tr_bin, buf_end);
  EXPECT_EQ(first_th_bin, 1024 + 1600);
  EXPECT_EQ(last_tr_bin, 1600 + 2048);
  EXPECT_EQ(buf_end, 1024);
}

TEST_F(TestCombineSQW, Get_NPix_For_Bins_Threads) {
  pix_mem_map pix_map;

  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE, 0, true);

  // number of pixels in file is unknown
  EXPECT_EQ(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

  std::size_t pix_start, npix;
  pix_map.get_npix_for_bin(0, pix_start, npix);
  EXPECT_EQ(0, pix_start);
  EXPECT_EQ(sample_npix[0], npix);

  pix_map.get_npix_for_bin(114, pix_start, npix);
  EXPECT_EQ(sample_npix[114], npix);
  EXPECT_EQ(sample_pix_pos[114], pix_start);

  pix_map.get_npix_for_bin(511, pix_start, npix);
  EXPECT_EQ(sample_npix[511], npix);
  EXPECT_EQ(sample_pix_pos[511], pix_start);

  pix_map.get_npix_for_bin(600, pix_start, npix);
  EXPECT_EQ(sample_npix[600], npix);
  EXPECT_EQ(sample_pix_pos[600], pix_start);

  pix_map.get_npix_for_bin(2400, pix_start, npix);
  EXPECT_EQ(sample_npix[2400], npix);
  EXPECT_EQ(sample_pix_pos[2400], pix_start);

  // number of pixels in file is unknown
  EXPECT_EQ(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

  pix_map.get_npix_for_bin(2, pix_start, npix);
  EXPECT_EQ(sample_npix[2], npix);
  EXPECT_EQ(sample_pix_pos[2], pix_start);

  pix_map.get_npix_for_bin(NUM_BINS_IN_FILE - 2, pix_start, npix);
  EXPECT_EQ(sample_npix[NUM_BINS_IN_FILE - 2], 0);
  EXPECT_EQ(sample_pix_pos[NUM_BINS_IN_FILE - 2], pix_start);

  // number of pixels in file is known
  ASSERT_NE(std::numeric_limits<uint64_t>::max(), pix_map.num_pix_in_file());

  EXPECT_EQ(pix_map.num_pix_in_file(), sample_pix_pos[NUM_BINS_IN_FILE - 1] +
                                           sample_npix[NUM_BINS_IN_FILE - 1]);
}

TEST_F(TestCombineSQW, Fully_Expand_Pix_Map_From_Start_Threads) {
  pix_mem_map pix_map;
  const std::size_t pix_buffer_size{512};
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE,
               pix_buffer_size, true);

  bool end_pix_reached;
  std::size_t num_pix =
      pix_map.check_expand_pix_map(4, pix_buffer_size, end_pix_reached);
  ASSERT_FALSE(end_pix_reached);
  EXPECT_EQ(pix_buffer_size, num_pix);

  // Read whole map in memory requesting map for much bigger number of npixels
  // then the real npix number in the file.
  num_pix = pix_map.check_expand_pix_map(0, 2 * NUM_PIXELS, end_pix_reached);
  // the file contains
  EXPECT_EQ(sample_pix_pos[NUM_BINS_IN_FILE - 1] +
                sample_npix[NUM_BINS_IN_FILE - 1],
            num_pix);
  ASSERT_TRUE(end_pix_reached);
  // check whole map is loaded in memory
  std::size_t first_mem_bin, last_mem_bin, n_tot_bins;
  pix_map.get_map_param(first_mem_bin, last_mem_bin, n_tot_bins);
  EXPECT_EQ(first_mem_bin, 0);
  EXPECT_EQ(last_mem_bin, n_tot_bins);
  EXPECT_EQ(last_mem_bin, NUM_BINS_IN_FILE);

  for (std::size_t i = 0; i < NUM_BINS_IN_FILE; i++) {
    std::size_t pix_start, npix;
    pix_map.get_npix_for_bin(i, pix_start, npix);
    EXPECT_EQ(pix_start, sample_pix_pos[i]);
    EXPECT_EQ(npix, sample_npix[i]);
  }
  EXPECT_EQ(pix_map.num_pix_in_file(), num_pix);
}

TEST_F(TestCombineSQW, Check_Expand_Pix_Map_Threads) {
  pix_mem_map pix_map;
  const std::size_t pix_buffer_size{512};
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE,
               pix_buffer_size, true);

  bool end_pix_reached;
  std::size_t num_pix1 =
      pix_map.check_expand_pix_map(511, pix_buffer_size, end_pix_reached);
  ASSERT_FALSE(end_pix_reached);
  EXPECT_EQ(510, num_pix1);

  std::size_t pix_pos, npix;
  pix_map.get_npix_for_bin(511, pix_pos, npix);
  EXPECT_EQ(sample_pix_pos[511], pix_pos);
  EXPECT_EQ(sample_npix[511], npix);

  // Read whole map in memory requesting map for much bigger number of npixels
  // then the real npix number in the file.
  std::size_t num_pix = pix_map.check_expand_pix_map(
      pix_buffer_size, 2 * NUM_PIXELS, end_pix_reached);
  // the file contains
  EXPECT_EQ(sample_pix_pos[NUM_BINS_IN_FILE - 1] +
                sample_npix[NUM_BINS_IN_FILE - 1] - pix_pos - npix,
            num_pix);
  ASSERT_TRUE(end_pix_reached);

  for (std::size_t i = pix_buffer_size; i < NUM_BINS_IN_FILE; i++) {
    std::size_t pix_start, npix;
    pix_map.get_npix_for_bin(i, pix_start, npix);
    EXPECT_EQ(pix_start, sample_pix_pos[i]);
    EXPECT_EQ(npix, sample_npix[i]);
  }
  EXPECT_EQ(pix_map.num_pix_in_file(), num_pix + pix_pos + npix);

  num_pix = pix_map.check_expand_pix_map(pix_buffer_size, pix_buffer_size,
                                         end_pix_reached);
  ASSERT_FALSE(end_pix_reached);
  EXPECT_EQ(pix_buffer_size, num_pix);

  num_pix = pix_map.check_expand_pix_map(4, pix_buffer_size, end_pix_reached);
  ASSERT_FALSE(end_pix_reached);
  EXPECT_EQ(pix_buffer_size, num_pix);

  pix_map.get_npix_for_bin(pix_buffer_size + 4, pix_pos, npix);
  EXPECT_EQ(sample_pix_pos[pix_buffer_size + 4], pix_pos);
  EXPECT_EQ(sample_npix[pix_buffer_size + 4], npix);
}

TEST_F(TestCombineSQW, Normal_Expand_Mode_Threads) {
  pix_mem_map pix_map;
  const std::size_t pix_buffer_size{512};
  pix_map.init(TEST_FILE_NAME, BIN_POS_IN_FILE, NUM_BINS_IN_FILE,
               pix_buffer_size, true);

  std::size_t pix_pos, npix;
  pix_map.get_npix_for_bin(0, pix_pos, npix);
  EXPECT_EQ(sample_pix_pos[0], pix_pos);
  EXPECT_EQ(sample_npix[0], npix);

  bool end_pix_reached;

  std::size_t bin_num(0), pix_buf_size(pix_buffer_size), ic(0);
  while (bin_num < NUM_BINS_IN_FILE - pix_buf_size) {
    bin_num += pix_buf_size;
    pix_map.get_npix_for_bin(bin_num, pix_pos, npix);
    std::size_t n_pix = pix_map.num_pix_described(bin_num);
    if (n_pix < pix_buf_size) {
      pix_map.check_expand_pix_map(bin_num, pix_buf_size, end_pix_reached);
    }
    EXPECT_EQ(sample_pix_pos[bin_num], pix_pos);
    EXPECT_EQ(sample_npix[bin_num], npix);
    ic++;
  }
}

TEST_F(TestCombineSQW, SQW_Reader_Propagate_Pix) {
  sqw_reader reader;
  fileParameters file_par;
  file_par.fileName = TEST_FILE_NAME;
  file_par.file_id = 0;
  file_par.nbin_start_pos = BIN_POS_IN_FILE;
  file_par.pix_start_pos = PIX_POS_IN_FILE;
  file_par.total_NfileBins = NUM_BINS_IN_FILE;
  bool initialized(false);
  try {
    reader.init(file_par, false, 128);
    initialized = true;
  } catch (...) {
  }

  ASSERT_TRUE(initialized);

  std::size_t pix_start_num, num_bin_pix, start_buf_pos(0);
  std::vector<float> pix_buffer(NUM_PIXBLOCK_COLS * 1000);

  std::size_t bin_number{0};
  reader.get_pix_for_bin(bin_number, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, 0);
  EXPECT_EQ(num_bin_pix, 3);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i], pix_buffer[i]);
  }

  bin_number = 127;
  // pix buffer have not changed at all
  reader.get_pix_for_bin(bin_number, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, 338);
  EXPECT_EQ(num_bin_pix, 0);

  reader.get_pix_for_bin(bin_number - 1, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, 334);
  EXPECT_EQ(num_bin_pix, 4);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i], pix_buffer[i]);
  }

  start_buf_pos = 5;
  bin_number = NUM_BINS_IN_FILE - 860;
  reader.get_pix_for_bin(bin_number, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, sample_pix_pos[bin_number]);
  EXPECT_EQ(num_bin_pix, sample_npix[bin_number]);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i],
              pix_buffer[start_buf_pos * NUM_PIXBLOCK_COLS + i]);
  }

  reader.get_pix_for_bin(bin_number + 1, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, sample_pix_pos[bin_number + 1]);
  EXPECT_EQ(num_bin_pix, sample_npix[bin_number + 1]);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i],
              pix_buffer[start_buf_pos * NUM_PIXBLOCK_COLS + i]);
  }

  start_buf_pos = 2;
  reader.get_pix_for_bin(NUM_BINS_IN_FILE - 1, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, sample_pix_pos[NUM_BINS_IN_FILE - 1]);
  EXPECT_EQ(num_bin_pix, sample_npix[NUM_BINS_IN_FILE - 1]);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i],
              pix_buffer[start_buf_pos * NUM_PIXBLOCK_COLS + i]);
  }
}

TEST_F(TestCombineSQW, SQW_Reader_NoBuf_Mode) {
  sqw_reader reader;
  fileParameters file_par;
  file_par.fileName = TEST_FILE_NAME;
  file_par.file_id = 0;
  file_par.nbin_start_pos = BIN_POS_IN_FILE;
  file_par.pix_start_pos = PIX_POS_IN_FILE;
  file_par.total_NfileBins = NUM_BINS_IN_FILE;
  bool initialized(false);
  try {
    reader.init(file_par, false, false, 0);
    initialized = true;
  } catch (...) {
  }

  ASSERT_TRUE(initialized);

  std::size_t pix_start_num, num_bin_pix, start_buf_pos(0);
  std::vector<float> pix_buffer(NUM_PIXBLOCK_COLS * 1000);

  std::size_t bin_number{0};
  reader.get_pix_for_bin(bin_number, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, 0);
  EXPECT_EQ(num_bin_pix, 3);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i], pix_buffer[i]);
  }
  // pix buffer have not changed at all
  bin_number = 127;
  reader.get_pix_for_bin(bin_number, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, 338);
  EXPECT_EQ(num_bin_pix, 0);

  reader.get_pix_for_bin(bin_number - 1, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, 334);
  EXPECT_EQ(num_bin_pix, 4);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i], pix_buffer[i]);
  }
  start_buf_pos = 5;
  bin_number = NUM_BINS_IN_FILE - 860;
  reader.get_pix_for_bin(bin_number, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, sample_pix_pos[bin_number]);
  EXPECT_EQ(num_bin_pix, sample_npix[bin_number]);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i],
              pix_buffer[start_buf_pos * NUM_PIXBLOCK_COLS + i]);
  }

  reader.get_pix_for_bin(bin_number + 1, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, sample_pix_pos[bin_number + 1]);
  EXPECT_EQ(num_bin_pix, sample_npix[bin_number + 1]);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i],
              pix_buffer[start_buf_pos * NUM_PIXBLOCK_COLS + i]);
  }

  start_buf_pos = 2;
  reader.get_pix_for_bin(NUM_BINS_IN_FILE - 1, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, sample_pix_pos[NUM_BINS_IN_FILE - 1]);
  EXPECT_EQ(num_bin_pix, sample_npix[NUM_BINS_IN_FILE - 1]);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i],
              pix_buffer[start_buf_pos * NUM_PIXBLOCK_COLS + i]);
  }
}

TEST_F(TestCombineSQW, SQW_Reader_Propagate_Pix_Threads) {
  sqw_reader reader;
  fileParameters file_par;
  file_par.fileName = TEST_FILE_NAME;
  file_par.file_id = 0;
  file_par.nbin_start_pos = BIN_POS_IN_FILE;
  file_par.pix_start_pos = PIX_POS_IN_FILE;
  file_par.total_NfileBins = NUM_BINS_IN_FILE;
  bool initialized(false);
  try {
    reader.init(file_par, false, 128, 1);
    initialized = true;
  } catch (...) {
  }

  ASSERT_TRUE(initialized);

  std::size_t pix_start_num, num_bin_pix, start_buf_pos(0);
  std::vector<float> pix_buffer(NUM_PIXBLOCK_COLS * 1000);

  std::size_t bin_number{0};
  reader.get_pix_for_bin(0, pix_buffer.data(), start_buf_pos, pix_start_num,
                         num_bin_pix, false);
  EXPECT_EQ(pix_start_num, 0);
  EXPECT_EQ(num_bin_pix, 3);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i], pix_buffer[i]);
  }
  // pix buffer have not changed at all
  bin_number = 127;
  reader.get_pix_for_bin(127, pix_buffer.data(), start_buf_pos, pix_start_num,
                         num_bin_pix, false);
  EXPECT_EQ(pix_start_num, 338);
  EXPECT_EQ(num_bin_pix, 0);

  reader.get_pix_for_bin(126, pix_buffer.data(), start_buf_pos, pix_start_num,
                         num_bin_pix, false);
  EXPECT_EQ(pix_start_num, 334);
  EXPECT_EQ(num_bin_pix, 4);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i], pix_buffer[i]);
  }
  start_buf_pos = 5;
  bin_number = NUM_BINS_IN_FILE - 860;
  reader.get_pix_for_bin(bin_number, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, sample_pix_pos[bin_number]);
  EXPECT_EQ(num_bin_pix, sample_npix[bin_number]);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i],
              pix_buffer[start_buf_pos * NUM_PIXBLOCK_COLS + i]);
  }
  reader.get_pix_for_bin(bin_number + 1, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, sample_pix_pos[bin_number + 1]);
  EXPECT_EQ(num_bin_pix, sample_npix[bin_number + 1]);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i],
              pix_buffer[start_buf_pos * NUM_PIXBLOCK_COLS + i]);
  }

  start_buf_pos = 2;
  reader.get_pix_for_bin(NUM_BINS_IN_FILE - 1, pix_buffer.data(), start_buf_pos,
                         pix_start_num, num_bin_pix, false);
  EXPECT_EQ(pix_start_num, sample_pix_pos[NUM_BINS_IN_FILE - 1]);
  EXPECT_EQ(num_bin_pix, sample_npix[NUM_BINS_IN_FILE - 1]);
  for (std::size_t i = 0; i < num_bin_pix * NUM_PIXBLOCK_COLS; i++) {
    EXPECT_EQ(pixels[pix_start_num * NUM_PIXBLOCK_COLS + i],
              pix_buffer[start_buf_pos * NUM_PIXBLOCK_COLS + i]);
  }
}

TEST_F(TestCombineSQW, SQW_Reader_Read_All) {
  sqw_reader reader;
  fileParameters file_par;
  file_par.fileName = TEST_FILE_NAME;
  file_par.file_id = 0;
  file_par.nbin_start_pos = BIN_POS_IN_FILE;
  file_par.pix_start_pos = PIX_POS_IN_FILE;
  file_par.total_NfileBins = NUM_BINS_IN_FILE;
  std::vector<float> pix_buffer(this->pixels.size());
  std::size_t start_buf_pos(0), pix_start_num, num_bin_pix;
  // --------------------------------------------------------------------------------------------
  reader.init(file_par, false, 0);

  auto t_start = std::chrono::steady_clock::now();
  start_buf_pos = 0;
  for (std::size_t i = 0; i < NUM_BINS_IN_FILE; i++) {
    reader.get_pix_for_bin(i, pix_buffer.data(), start_buf_pos, pix_start_num,
                           num_bin_pix, false);
    start_buf_pos += num_bin_pix;
  }
  auto t_end = std::chrono::duration_cast<std::chrono::milliseconds>(
                   std::chrono::steady_clock::now() - t_start)
                   .count();
  std::cout << "\n Time to run single thread with system buffer: " << t_end
            << "ms\n";

  for (std::size_t i = 0; i < pix_buffer.size(); i++) {
    EXPECT_EQ(pix_buffer[i], pixels[i]);
    pix_buffer[i] = 0;
  }
  // --------------------------------------------------------------------------------------------
  reader.init(file_par, false, 1024);

  t_start = std::chrono::steady_clock::now();
  start_buf_pos = 0;
  for (std::size_t i = 0; i < NUM_BINS_IN_FILE; i++) {
    reader.get_pix_for_bin(i, pix_buffer.data(), start_buf_pos, pix_start_num,
                           num_bin_pix, false);
    start_buf_pos += num_bin_pix;
  }
  t_end = std::chrono::duration_cast<std::chrono::milliseconds>(
              std::chrono::steady_clock::now() - t_start)
              .count();
  std::cout << "\n Time to run single thread with 1024 words buffer: " << t_end
            << "ms\n";

  for (std::size_t i = 0; i < pix_buffer.size(); i++) {
    EXPECT_EQ(pix_buffer[i], pixels[i]);
    pix_buffer[i] = 0;
  }

  // --------------------------------------------------------------------------------------------
  reader.init(file_par, false, 512, 1);

  t_start = std::chrono::steady_clock::now();
  start_buf_pos = 0;
  for (std::size_t i = 0; i < NUM_BINS_IN_FILE; i++) {
    reader.get_pix_for_bin(i, pix_buffer.data(), start_buf_pos, pix_start_num,
                           num_bin_pix, false);
    start_buf_pos += num_bin_pix;
  }
  t_end = std::chrono::duration_cast<std::chrono::milliseconds>(
              std::chrono::steady_clock::now() - t_start)
              .count();
  std::cout << "\n Time to run threads: " << t_end << "ms\n";

  for (std::size_t i = 0; i < pix_buffer.size(); i++) {
    EXPECT_EQ(pix_buffer[i], pixels[i]);
    pix_buffer[i] = 0;
  }

  //--------------------------------------------------------------------------------------------
  reader.init(file_par, false, false, 0);

  t_start = std::chrono::steady_clock::now();
  start_buf_pos = 0;
  for (std::size_t i = 0; i < NUM_BINS_IN_FILE; i++) {
    reader.get_pix_for_bin(i, pix_buffer.data(), start_buf_pos, pix_start_num,
                           num_bin_pix, false);
    start_buf_pos += num_bin_pix;
  }
  t_end = std::chrono::duration_cast<std::chrono::milliseconds>(
              std::chrono::steady_clock::now() - t_start)
              .count();
  std::cout << "\n Time to run single thread with system buffer: " << t_end
            << "ms\n";
}

TEST_F(TestCombineSQW, MXSQW_Reader_Propagate_Pix_Multi) {
  std::vector<sqw_reader> reader_noThread(1);

  fileParameters file_par;
  file_par.fileName = TEST_FILE_NAME;
  file_par.file_id = 0;
  file_par.nbin_start_pos = BIN_POS_IN_FILE;
  file_par.pix_start_pos = PIX_POS_IN_FILE;
  file_par.total_NfileBins = NUM_BINS_IN_FILE;
  bool initialized(false);
  try {
    //(fileParam[i], change_fileno, fileno_provided, read_buf_size,
    // read_files_multitreaded);
    reader_noThread[0].init(file_par, false, 64, 0);
    initialized = true;
  } catch (...) {
  }

  ASSERT_TRUE(initialized);

  ProgParameters ProgSettings;
  ProgSettings.log_level = 2;
  ProgSettings.nBin2read = 0;
  ProgSettings.num_log_ticks = 100;
  ProgSettings.pixBufferSize = 1164180;
  ProgSettings.totNumBins = NUM_BINS_IN_FILE;

  exchange_buffer Buffer(ProgSettings.pixBufferSize, file_par.total_NfileBins,
                         ProgSettings.num_log_ticks);
  nsqw_pix_reader Reader(ProgSettings, reader_noThread, Buffer);

  std::vector<uint64_t> nbin_Buffer_noThreads(ProgSettings.totNumBins, -1);
  uint64_t *nbinBuf = &nbin_Buffer_noThreads[0];

  std::size_t n_buf_pixels, n_bins_processed(0);
  Reader.read_and_combine_pixBuf_from_files(n_buf_pixels, n_bins_processed, nbinBuf);

  EXPECT_EQ(n_buf_pixels, ProgSettings.pixBufferSize);
  EXPECT_EQ(n_bins_processed + 1, ProgSettings.totNumBins);

  std::size_t nReadPixels, n_bin_max;
  const float *buf = reinterpret_cast<const float *>(
      Buffer.get_write_buffer(nReadPixels, n_bin_max));
  Buffer.unlock_write_buffer();
  EXPECT_EQ(nReadPixels, ProgSettings.pixBufferSize);
  //---------------------------------------------------------------------
  std::vector<sqw_reader> reader_threads(1);
  initialized = false;
  try {
    //(fileParam[i], change_fileno, fileno_provided, read_buf_size,
    // read_files_multitreaded);
    reader_threads[0].init(file_par, false, 64, 1);
    initialized = true;
  } catch (...) {
  }
  ASSERT_TRUE(initialized);

  nsqw_pix_reader ReaderThr(ProgSettings, reader_threads, Buffer);

  std::vector<uint64_t> nbin_Buffer_Threads(ProgSettings.totNumBins, -1);
  uint64_t *nbinBufThr = &nbin_Buffer_Threads[0];

  n_bins_processed = 0;
  ReaderThr.read_and_combine_pixBuf_from_files(n_buf_pixels, n_bins_processed, nbinBufThr);

  EXPECT_EQ(n_buf_pixels, ProgSettings.pixBufferSize);
  EXPECT_EQ(n_bins_processed + 1, ProgSettings.totNumBins);

  const float *buf1 = reinterpret_cast<const float *>(
      Buffer.get_write_buffer(nReadPixels, n_bin_max));
  Buffer.unlock_write_buffer();
  EXPECT_EQ(nReadPixels, ProgSettings.pixBufferSize);

  for (std::size_t i = 0; i < n_bins_processed + 1; i += 10) {
    EXPECT_EQ(nbin_Buffer_Threads[i], nbin_Buffer_noThreads[i]) << "bin N" << i;
  }
  for (std::size_t i = 0; i < n_buf_pixels; i += 100) {
    std::size_t n_pix = i / NUM_PIXBLOCK_COLS;
    EXPECT_EQ(buf[i], buf1[i]) << "pix N" << n_pix;
  }
}
