set(COMPONENTS
  "c_deserialize"
  "c_serialize"
  "c_serial_size"
)

foreach(_component ${COMPONENTS})
  pace_add_mex(
    NAME "${_component}"
    SRC "${_component}.cpp" "cpp_serialize.hpp"
    )
  target_include_directories("${_component}"
    PRIVATE "${CXX_SOURCE_DIR}"
    PRIVATE "${MPI_CXX_INCLUDE_PATH}")
  target_link_libraries("${_component}" "${MPI_CXX_LIBRARIES}")
endforeach()
