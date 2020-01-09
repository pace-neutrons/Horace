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
    string(REPLACE "_fortran" "" _base_name "${_file_name}")
    set(_mex_name "${_base_name}_mex")
    set(_outfile_name "${_mex_name}.${Matlab_MEX_EXTENSION}")
    set(_outdir "${CMAKE_SOURCE_DIR}/herbert_core/DLL")
    set(_outfile "${_outdir}/${_outfile_name}")

    add_custom_command(
        OUTPUT ${_outfile}
        COMMAND ${Matlab_MEX_COMPILER}
            "${CMAKE_CURRENT_LIST_DIR}/${_file_name}.F"
            "$<TARGET_FILE:${HERBERT_FORTRAN_LIB}>"
            -outdir "${_outdir}"
            -output "${_mex_name}"
            -compatibleArrayDims
            FFLAGS='$$FFLAGS -ffixed-line-length-132'
        DEPENDS
            "${_file_name}.F"
            "$<TARGET_FILE:${HERBERT_FORTRAN_LIB}>"
        COMMENT "Building Fortran mex library ${_outfile_name}"
    )
    add_custom_target(${_mex_name} ALL DEPENDS ${_outfile})

endforeach()
