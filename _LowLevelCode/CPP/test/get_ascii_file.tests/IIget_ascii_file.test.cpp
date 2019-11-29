#include "get_ascii_file/get_ascii_file.h"
#include "utility/environment.h"

#include <gtest/gtest.h>

#include <iostream>
#include <string>

using namespace Herbert::Utility;

TEST(TestGetAsciiFile, get_ASCII_header_identifies_spe_header_type) {
  const std::string herbert_root{
      Environment::get_env_variable(Environment::HERBERT_ROOT, ".")};
  std::string spe_file{herbert_root + "/_test/common_data/MAP10001.spe"};
  std::ifstream data_stream;
  auto file_descriptor{get_ASCII_header(spe_file, data_stream)};
  ASSERT_EQ(file_descriptor.Type, fileTypes::iSPE_type);
}
