#include "utility/version.h"

#include <gtest/gtest.h>

#include <regex>

TEST(TestVersion, HERBERT_VERSION_macro_returns_valid_version_string) {
  const std::string regex_string{"[0-9]\\.[0-9]\\.[0-9](\\.[0-9a-z]+|)"};
  auto match = std::regex_match(HERBERT_VERSION, std::regex(regex_string));
  ASSERT_TRUE(match) << HERBERT_VERSION << " did not match regex " << regex_string;
}
