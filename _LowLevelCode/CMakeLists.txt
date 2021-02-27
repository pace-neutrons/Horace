set(Herbert_DLL_DIR "${Herbert_ROOT}/herbert_core/DLL")

# Add external directory first - this means we can get the location required
# runtime executables/libraries are copied to
add_subdirectory("external")
add_subdirectory("cpp")
