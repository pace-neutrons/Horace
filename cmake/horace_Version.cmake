set(Horace_FULL_VERSION "${PROJECT_VERSION}")

if(Horace_RELEASE_TYPE STREQUAL "nightly")
    string(TIMESTAMP _date "%Y%m%d")
    set(Horace_FULL_VERSION "${Horace_FULL_VERSION}-${_date}")
endif()

macro(get_release_value)
    set(_release_key ${ARGV0})
    execute_process(
        COMMAND cat "/etc/os-release"
        COMMAND grep "-e" "^${_release_key}="
        RESULT_VARIABLE _res
        OUTPUT_VARIABLE ${ARGV1}
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX REPLACE
        "${_release_key}=\\\"?\(.+\)\\\"?"
        "\\1"
        ${ARGV1}
        ${${ARGV1}}
    )
    string(REPLACE " " "." ${ARGV1} ${${ARGV1}})
    string(REPLACE "\"" "" ${ARGV1} ${${ARGV1}})
endmacro()

if(UNIX)
    # Get distribution name from /etc/os-release
    get_release_value("ID" _id)
    get_release_value("VERSION_ID" _version_id)
    set(Horace_PLATFORM "${_id}.${_version_id}")
elseif(WIN32)
    set(Horace_PLATFORM "win64")
endif()
set(Horace_FULL_VERSION "${Horace_FULL_VERSION}-${Horace_PLATFORM}")

if(NOT "${Horace_RELEASE_TYPE}" STREQUAL "release")
    find_package(Git QUIET)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-list --abbrev-commit --no-merges -n 1 HEAD
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        RESULT_VARIABLE _res
        OUTPUT_VARIABLE GIT_REVISION_SHA
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(Horace_FULL_VERSION "${Horace_FULL_VERSION}-${GIT_REVISION_SHA}")
endif()

message(STATUS "Horace_FULL_VERSION: ${Horace_FULL_VERSION}")
