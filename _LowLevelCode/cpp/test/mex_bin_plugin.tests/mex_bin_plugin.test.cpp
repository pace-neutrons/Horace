#include "mex_bin_plugin/mex_bin_plugin.hpp"
#include "utility/environment.h"

#include <gtest/gtest.h>

#include <iostream>
#include <string>

using namespace Horace::Utility;

TEST(TestMexBinPlugin, write_bin_data) {
  const std::string horace_root{
      Environment::get_env_variable(Environment::HORACE_ROOT, ".")};
  std::string binary_file{horace_root + "/_test/binary_write.bin"};
  std::vector<char> test_data(10, 'a'); 
  sqw_pix_writer my_writer;
  fileParameters file_info;
  file_info.fileName = binary_file;
  file_info.nbin_start_pos = 1;
  file_info.pix_start_pos = 0;
  file_info.total_NfileBins = 0;
  file_info.total_nPixels = 1000;

  size_t n_bins2proces(0);

  my_writer.init(file_info,n_bins2proces); // initialize writer class to write data
  my_writer.write_pixels(&test_data[0], 10);
  //std::iostream test_stream();

  //auto file_descriptor{get_ASCII_header(spe_file, data_stream)};
  //ASSERT_EQ(file_descriptor.Type, fileTypes::iSPE_type);
}
