set(MATLAB_VERSIONS_MAPPING
    "R2021b=9.11"
    "R2021a=9.10"
    "R2020b=9.9"
    "R2020a=9.8"
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

#[=======================================================================[.rst:
.. command:: matlab_root_dir_changed

  Returns ``TRUE`` if ``Matlab_ROOT_DIR`` differs from the previous run
#]=======================================================================]
macro(matlab_root_dir_changed _output)
    if("${_CACHED_Matlab_ROOT_DIR}" STREQUAL "${Matlab_ROOT_DIR}")
        set(${_output} FALSE)
    else()
        set(${_output} TRUE)
    endif()
endmacro()

#[=======================================================================[.rst:
.. command:: matlab_release_changed

  Returns ``TRUE`` if ``Matlab_RELEASE`` differs from the previous run
#]=======================================================================]
macro(matlab_release_changed _output)
    if("${_CACHED_Matlab_RELEASE}" STREQUAL "${Matlab_RELEASE}")
        set(${_output} FALSE)
    else()
        set(${_output} TRUE)
    endif()
endmacro()

#[=======================================================================[.rst:
.. command:: matlab_find_package

    Decides whether or not a specific version of Matlab is required and calls
    find_package to either find the specific version or any version. An error
    is raised if a specifically requested version is not found.

    The input variable ``Matlab_RELEASE`` requests a specific release of Matlab,
    so we must:
        a) get the version from the given release e.g. R2018b -> 9.5
        b) call ``find_package(Matlab EXACT <version number>)``
    If ``Matlab_RELEASE`` is not, and was never, defined, then we do not care
    which version of Matlab we build against.

    The input varible ``Matlab_ROOT_DIR`` is passed to the FindMatlab script
    to find Matlab at a specific path. If this variable is changed by a user,
    and ``Matlab_RELEASE`` is not, ``Matlab_RELEASE`` will be overwritten. This
    is so users do not need to clear their cache to move the version of Matlab
    they want to use.

    To decide if Matlab_RELEASE or Matlab_ROOT_DIR has changed since the previous
    configure, save the previous values in internal cache variables ``_CACHED_*``.

    Throws ``FATAL_ERROR`` if Matlab cannot be found.
#]=======================================================================]
macro(matlab_find_package)
    matlab_root_dir_changed(_root_changed)
    matlab_release_changed(_matlab_release_changed)
    if(_root_changed AND NOT _matlab_release_changed)
        # If Matlab_ROOT_DIR has been changed but not Matlab_RELEASE, then a user
        # has inputted a ROOT_DIR and we should prioritise that change. So discard
        # the previous Matlab_RELEASE variable.
        unset(Matlab_RELEASE CACHE)
    elseif(_matlab_release_changed AND NOT _root_changed)
        # Conversely, if Matlab_RELEASE has been changed but not Matlab_ROOT_DIR,
        # a user has changed the desired release and we prioritise that.
        unset(Matlab_ROOT_DIR CACHE)
    endif()

    if("${Matlab_RELEASE}" STREQUAL "")  # specific version not required
        find_package(Matlab COMPONENTS MAIN_PROGRAM MEX_COMPILER)
    else()
        matlab_get_version_from_release_name("${Matlab_RELEASE}" _version)
        find_package(Matlab EXACT ${_version} COMPONENTS MAIN_PROGRAM MEX_COMPILER)
    endif()

    # Set local cached versions of variables so changes on next run can be tracked
    set(_CACHED_Matlab_RELEASE "${Matlab_RELEASE}" CACHE INTERNAL "")
    set(_CACHED_Matlab_ROOT_DIR "${Matlab_ROOT_DIR}" CACHE INTERNAL "")

    if(${Matlab_FOUND}) # `Matlab_FOUND` defined by `find_package(Matlab)`
        # Get the release of the Matlab that's been found
        matlab_get_release_at_path("${Matlab_ROOT_DIR}" _found_release)
        # Set the release as a cache variable to allow editing in the GUI
        set(Matlab_RELEASE "${_found_release}" CACHE STRING
            "The release of Matlab to find e.g. R2018b" FORCE)
    else()
        unset(_CACHED_Matlab_RELEASE CACHE)
        unset(_CACHED_Matlab_ROOT_DIR CACHE)
        unset(Matlab_VERSION_STRING_INTERNAL CACHE)
        message(FATAL_ERROR "Matlab '${Matlab_RELEASE}' not found at '${Matlab_ROOT_DIR}'.")
    endif()
endmacro()
