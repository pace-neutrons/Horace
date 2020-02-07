set(MATLAB_VERSIONS_MAPPING
    "R2019b=9.7"
    "R2019a=9.6"
    "R2018b=9.5"
    "R2018a=9.4"
    "R2017b=9.3"
    "R2017a=9.2"
    "R2016b=9.1"
    "R2016a=9.0"
    "R2015b=8.6"
    "R2015a=8.5"
    "R2014b=8.4"
    "R2014a=8.3"
    "R2013b=8.2"
    "R2013a=8.1"
    "R2012b=8.0"
    "R2012a=7.14"
    "R2011b=7.13"
    "R2011a=7.12"
    "R2010b=7.11"

    ${MATLAB_ADDITIONAL_VERSIONS}
)

#[=======================================================================[.rst:
.. command:: matlab_get_version_from_release_name

  Returns the version of Matlab (17.58) from a release name (R2017k)
#]=======================================================================]
macro(matlab_get_version_from_release_name release_name version_name)
    string(REGEX MATCHALL "${release_name}=([0-9]+\\.?[0-9]*)"
        _matched
        ${MATLAB_VERSIONS_MAPPING}
    )
    set(${version_name} "")
    if(NOT _matched STREQUAL "")
        set(${version_name} ${CMAKE_MATCH_1})
    else()
        message(WARNING "[MATLAB] The release name ${release_name} is not registered")
    endif()
    unset(_matched)
endmacro()

#[=======================================================================[.rst:
.. command:: matlab_get_release_at_path

  Returns the release name (R2017k) of Matlab (17.58) given its root directory
#]=======================================================================]
macro(matlab_get_release_at_path _root_dir _release)
    if(EXISTS "${_root_dir}/VersionInfo.xml")
        file(READ "${_root_dir}/VersionInfo.xml" _version_info)
        string(REGEX REPLACE
            ".*<release>(R[0-9]+[ab])</release>.*" "\\1"
            ${_release} "${_version_info}")
    else()
        execute_process(
            COMMAND matlab "-help"
            WORKING_DIRECTORY "${_root_dir}/bin"
            OUTPUT_VARIABLE _help_contents)
        string(REGEX REPLACE ".*Version: ([0-9]\\.[0-9]).*" "\\1"
            _version "${_help_contents}")
        string(REGEX REPLACE
            ".*(R[0-9]+[ab])=${_version}.*" "\\1"
            ${_release} "${MATLAB_VERSIONS_MAPPING}")
    endif()
endmacro()

macro(root_dir_changed _output)
    if("${_CACHED_MATLAB_ROOT_DIR}" STREQUAL "${Matlab_ROOT_DIR}")
        set(${_output} FALSE)
    else()
        set(${_output} TRUE)
    endif()
endmacro()

macro(release_changed _output)
    if("${_CACHED_Matlab_RELEASE}" STREQUAL "${Matlab_RELEASE}")
        set(${_output} FALSE)
    else()
        set(${_output} TRUE)
    endif()
endmacro()
