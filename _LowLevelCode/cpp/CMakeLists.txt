set(CXX_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}")

set(MODULES
    "cpp_communicator"
    "get_ascii_file"
    "serialiser"
)
foreach(_module ${MODULES})
    add_subdirectory("${_module}")
endforeach()

if(BUILD_TESTING)
    add_subdirectory("test")
endif()
