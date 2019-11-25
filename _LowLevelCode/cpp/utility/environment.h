#include <string>

namespace Horace {
namespace Utility {
namespace Environment {
// The HORACE_ROOT environment variable key
const std::string HORACE_ROOT{"HORACE_ROOT"};
// Get an environment variable
std::string get_env_variable(const std::string &key,
                             const std::string &default_value = "");

} // namespace Environment
} // namespace Utility
} // namespace Horace
