set(
    MODULES
    "cpp_communicator"
    "get_ascii_file"
)

foreach(_module ${MODULES})
    add_subdirectory("${_module}")
endforeach()

if(${BUILD_TESTS})
    add_subdirectory("test")
endif()
