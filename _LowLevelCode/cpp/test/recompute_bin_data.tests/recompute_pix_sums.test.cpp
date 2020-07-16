#include "test/recompute_bin_data.tests/recompute_pix_sums.test.h"
#include "recompute_bin_data/recompute_pix_sums.h"

#include <gmock/gmock.h>

#include <numeric>

void TestRecomputePixSums::SetUpTestSuite() {
  // Generate some pixel data. All signals = 1 and all variance = 2
  distr_size = 4;      // number of bins
  npix = {1, 8, 4, 9}; // number of pixels contributing to each bin
  num_pix =
      static_cast<std::size_t>(std::accumulate(npix.begin(), npix.end(), 0.0));
  pix_data.resize(num_pix * NUM_PIX_COLS);
  const std::size_t signal_idx{7}, variance_idx{8};
  for (std::size_t pix_idx = 0; pix_idx < num_pix; pix_idx++) {
    pix_data[pix_idx * NUM_PIX_COLS + signal_idx] = 1;
    pix_data[pix_idx * NUM_PIX_COLS + variance_idx] = 2;
  }
}

TEST_F(TestRecomputePixSums, test_correct_sum_returned_with_1_thread) {
  std::vector<double> signal_sum(distr_size);
  std::vector<double> variance_sum(distr_size);
  const int n_threads{1};

  recompute_pix_sums(signal_sum.data(), variance_sum.data(), distr_size,
                     npix.data(), pix_data.data(), num_pix, n_threads);

  ASSERT_THAT(signal_sum, ::testing::ElementsAre(1, 8, 4, 9));
  ASSERT_THAT(variance_sum, ::testing::ElementsAre(2, 16, 8, 18));
}

TEST_F(TestRecomputePixSums, test_correct_sum_returned_with_4_threads) {
  std::vector<double> signal_sum(distr_size);
  std::vector<double> variance_sum(distr_size);
  const int n_threads{4};

  recompute_pix_sums(signal_sum.data(), variance_sum.data(), distr_size,
                     npix.data(), pix_data.data(), num_pix, n_threads);

  ASSERT_THAT(signal_sum, ::testing::ElementsAre(1, 8, 4, 9));
  ASSERT_THAT(variance_sum, ::testing::ElementsAre(2, 16, 8, 18));
}
