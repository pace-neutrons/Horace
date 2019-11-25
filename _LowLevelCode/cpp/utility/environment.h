#include <string>

namespace Horace {
namespace Utility {
namespace Environment {
// Get an environment variable
std::string get_env_variable(const std::string &key);
// The HORACE_ROOT environment variable
const std::string HORACE_ROOT{get_env_variable("HORACE_ROOT")};

}  // namespace Environment
}  // namespace Utility
}  // namespace Horace
