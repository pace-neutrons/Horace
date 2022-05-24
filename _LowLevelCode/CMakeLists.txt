set(Horace_DLL_DIR "${Horace_ROOT}/horace_core/DLL")

# Add external directory first - this means we can get the location required
# runtime executables/libraries are copied to
add_subdirectory("external")
add_subdirectory("cpp")
