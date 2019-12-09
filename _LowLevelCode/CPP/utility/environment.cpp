#include "utility/environment.h"

namespace Herbert {
namespace Utility {
namespace Environment {
/*
 * Retrieve an environment variable from the system. If the variable is not
 * found return the argument `default_value`, if this argument is not given,
 * return an empty string.
 *
 * This function is necessary as `std::getenv` raises security warnings on
 * Windows. Also note, GCC does not implement `getenv_s`.
 *
 * @param key :: The key of the environment variable
 * @param default_value :: The return value for if the key is not found (default
 * is an empty string)
 */
std::string get_env_variable(const std::string &key,
                             const std::string &default_value /* = "" */) {
#ifdef _WIN32
  // Get the required size of the variable
  std::size_t requiredSize;
  getenv_s(&requiredSize, NULL, 0, key.data());
  if (requiredSize == 0) { // No env variable called 'key' exists
    return default_value;
  }
  // Extract the environment variable
  char *env_var = new char[requiredSize];
  getenv_s(&requiredSize, env_var, requiredSize, key.data());

  // Convert to std::string
  std::string env_var_string(env_var);
  delete[] env_var;
  return env_var_string;

#else
  char *env_var = std::getenv(key.data());
  if (!env_var) {
    return default_value;
  }
  return env_var;
#endif
}

} // namespace Environment
} // namespace Utility
} // namespace Herbert
