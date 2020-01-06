function(herbert_add_mex)

    # Parse the arguments
    set(prefix "MEX")
    set(noValues "EXECUTABLE" "MODULE" "SHARED")
    set(singleValues "NAME" "OUTPUT_NAME" "DOCUMENTATION")
    set(multiValues "SRC" "LINK_TO")
    cmake_parse_arguments(
        "${prefix}"
        "${noValues}"
        "${singleValues}"
        "${multiValues}"
        ${ARGN}
    )

    if(${${prefix}_EXECUTABLE})
        set(TYPE EXECUTABLE)
    elseif(${${prefix}_MODULE})
        set(TYPE MODULE)
    elseif(${${prefix}_MODULE})
        set(TYPE SHARED)
    endif()

    set(HERBERT_DLL_DIR "${CMAKE_SOURCE_DIR}/herbert_core/DLL")

    matlab_add_mex(
        NAME "${${prefix}_NAME}"
        "${TYPE}"
        SRC "${${prefix}_SRC}"
        OUTPUT_NAME "${${prefix}_OUTPUT_NAME}"
        DOCUMENTATION "${${prefix}_DOCUMENTATION}"
        LINK_TO "${${prefix}_LINK_TO}"
    )

    set(_target_file "$<TARGET_FILE:${${prefix}_NAME}>")
    set(_dest_file "${HERBERT_DLL_DIR}/$<TARGET_FILE_NAME:${${prefix}_NAME}>")
    add_custom_command(TARGET "${${prefix}_NAME}"
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "${_target_file}" "${_dest_file}"
        COMMENT "Copying ${${prefix}_NAME}.${Matlab_MEX_EXTENSION} into ${HERBERT_DLL_DIR}"
    )

endfunction()
