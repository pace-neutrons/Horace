#pragma once

#include <gtest/gtest.h>

#include <array>

class TestRecomputePixSums : public ::testing::Test {
protected:
  static constexpr int NUM_PIX_COLS{9};
  static std::size_t distr_size;
  static std::vector<double> npix;
  static std::size_t num_pix;
  static std::vector<double> pix_data;

  static void SetUpTestSuite();
};

std::size_t TestRecomputePixSums::distr_size;
std::size_t TestRecomputePixSums::num_pix;
std::vector<double> TestRecomputePixSums::pix_data;
std::vector<double> TestRecomputePixSums::npix;
