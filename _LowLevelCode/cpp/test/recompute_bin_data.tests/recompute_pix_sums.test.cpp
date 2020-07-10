#include "recompute_bin_data/recompute_pix_sums.h"

#include <gmock/gmock.h>
#include <gtest/gtest.h>


#include <array>
#include <numeric>

TEST(TestRecomputePixSums, test_correct_sum_returned_with_1_thread) {
  const int NUM_PIX_COLS{9};
  const std::size_t distr_size{4};
  const std::array<double, distr_size> npix{{1, 8, 4, 9}};
  const int n_threads{1};

  // Generate some pixel data. All signals = 1 and all variance = 2
  const auto num_pix =
      static_cast<std::size_t>(std::accumulate(npix.begin(), npix.end(), 0.0));
  std::vector<double> pix_data(num_pix * NUM_PIX_COLS);
  const std::size_t signal_idx{7}, variance_idx{8};
  for (std::size_t pix_idx = 0; pix_idx < num_pix; pix_idx++) {
    pix_data[pix_idx * NUM_PIX_COLS + signal_idx] = 1;
    pix_data[pix_idx * NUM_PIX_COLS + variance_idx] = 2;
  }

  std::vector<double> signal_sum(distr_size);
  std::vector<double> variance_sum(distr_size);

  recompute_pix_sums(signal_sum.data(), variance_sum.data(), distr_size,
                     npix.data(), pix_data.data(), num_pix, 1);

  ASSERT_THAT(signal_sum, ::testing::ElementsAre(1, 8, 4, 9));
  ASSERT_THAT(variance_sum, ::testing::ElementsAre(2, 16, 8, 18));
}
