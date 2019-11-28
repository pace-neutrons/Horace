#include "get_ascii_file/get_ascii_file.h"

#include <gtest/gtest.h>

#include <iostream>
#include <string>

TEST(TestGetAsciiFile, get_ASCII_header_identifies_spe_header_type) {
  std::string spe_file{"_test/common_data/MAP10001.spe"};
  std::ifstream data_stream;
  auto file_descriptor{get_ASCII_header(spe_file, data_stream)};
  ASSERT_EQ(file_descriptor.Type, fileTypes::iSPE_type);
}
