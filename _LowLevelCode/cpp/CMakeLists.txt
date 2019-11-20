set(
    MEX_FUNCTIONS
    "accumulate_cut_c"
    "bin_pixels_c"
    "calc_projections_c"
    "combine_sqw"
    "hdf_mex_reader"
    "mtimesx_horace"
    "recompute_bin_data"
    "sort_pixels_by_bins"
)

foreach(_mex_func ${MEX_FUNCTIONS})
    add_subdirectory("${_mex_func}")
endforeach(_mex_func)

if(${BUILD_TESTS})
    add_subdirectory(test)
endif()
