set(CXX_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}")
include_directories("${CXX_SOURCE_DIR}")

set(
    MEX_FUNCTIONS
    "accumulate_cut_c"
    "bin_pixels_c"
    "calc_projections_c"
    "combine_sqw"
    "compute_pix_sums"
    "hdf_mex_reader"
    "mtimesx_horace"
    "sort_pixels_by_bins"
)

foreach(_mex_func ${MEX_FUNCTIONS})
    add_subdirectory("${_mex_func}")
endforeach(_mex_func)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
