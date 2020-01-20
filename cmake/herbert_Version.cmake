set(Herbert_FULL_VERSION "${PROJECT_VERSION}")

if(Herbert_RELEASE_TYPE STREQUAL "nightly")
    string(TIMESTAMP _date "%Y%m%d")
    set(Herbert_FULL_VERSION "${Herbert_FULL_VERSION}-${_date}")
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
    set(Herbert_PLATFORM "${_id}.${_version_id}")
elseif(WIN32)
    set(Herbert_PLATFORM "win64")
endif()
set(Herbert_FULL_VERSION "${Herbert_FULL_VERSION}-${Herbert_PLATFORM}")

if(NOT "${Herbert_RELEASE_TYPE}" STREQUAL "release")
    find_package(Git QUIET)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-list --abbrev-commit --no-merges -n 1 HEAD
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        RESULT_VARIABLE _res
        OUTPUT_VARIABLE GIT_REVISION_SHA
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(Herbert_FULL_VERSION "${Herbert_FULL_VERSION}-${GIT_REVISION_SHA}")
endif()

message(STATUS "Herbert_FULL_VERSION: ${Herbert_FULL_VERSION}")
