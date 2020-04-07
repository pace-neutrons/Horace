#include "utility/version.h"

#include <gtest/gtest.h>

#include <regex>

TEST(TestVersion, Herbert_VERSION_returns_valid_version_string) {
  const std::string regex_string{"[0-9]\\.[0-9]\\.[0-9](\\.[0-9a-z]+|)"};
  auto match = std::regex_match(Herbert::VERSION, std::regex(regex_string));
  ASSERT_TRUE(match) << Herbert::VERSION << " did not match regex " << regex_string;
}
