set(FILE_NAMES
    "bin_boundaries_from_descriptor"
    "get_cut_fortran"
    "get_slice_fortran"
    "get_spe_fortran"
    "integrate_1d_points"
    "integrate_2d_x_points"
    "integrate_2d_y_points"
    "integrate_3d_x_points"
    "integrate_3d_y_points"
    "integrate_3d_z_points"
    "put_cut_fortran"
    "put_slice_fortran"
    "put_spe_fortran"
    "rebin_1d_hist"
    "rebin_2d_x_hist"
    "rebin_2d_y_hist"
    "rebin_3d_x_hist"
    "rebin_3d_y_hist"
    "rebin_3d_z_hist"
)

foreach(_file_name ${FILE_NAMES})
    string(REPLACE "_fortran" "" _base_name ${_file_name})
    set(_mex_name "${_base_name}_mex")
    matlab_add_mex(
        NAME "${_mex_name}"
        SRC "${_file_name}.F"
    )
    target_link_libraries("${_mex_name}" "${HERBERT_FORTRAN_LIB}")
endforeach()
