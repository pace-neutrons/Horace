#pragma once

#include <gtest/gtest.h>

#include <array>

class TestRecomputePixSums : public ::testing::Test {
protected:
  static constexpr int NUM_PIX_COLS{9};
  static constexpr std::size_t distr_size{4};
  static constexpr std::array<double, distr_size> npix{{1, 8, 4, 9}};
  static std::size_t num_pix;
  static std::vector<double> pix_data;

  static void SetUpTestSuite();
};

std::size_t TestRecomputePixSums::num_pix;
std::vector<double> TestRecomputePixSums::pix_data;
