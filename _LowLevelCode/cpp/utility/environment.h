#pragma once

#include <string>

namespace Herbert {
namespace Utility {
namespace Environment {
// The HERBERT_ROOT environment variable key
const std::string HERBERT_ROOT{"HERBERT_ROOT"};
// Get an environment variable
std::string get_env_variable(const std::string &key,
                             const std::string &default_value = "");

} // namespace Environment
} // namespace Utility
} // namespace Herbert
