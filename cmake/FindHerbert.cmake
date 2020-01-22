if(Herbert_ROOT)
    # Already in cache, be silent
    set(Herbert_FIND_QUIETLY TRUE)
endif()

set(DIRS_TO_SEARCH
    ENV{HERBERT_ROOT}
    ENV{HERBERT_ROOT}/herbert_core
    ${CMAKE_SOURCE_DIR}/Herbert
    ${CMAKE_SOURCE_DIR}/Herbert/herbert_core
    ${CMAKE_SOURCE_DIR}/../Herbert/
    ${CMAKE_SOURCE_DIR}/../Herbert/herbert_core
    /usr/local/mprogs/Herbert
    /usr/local/mprogs/Herbert/herbert_core
    /usr/local/Herbert
    /usr/local/Herbert/herbert_core
    ENV{ProgramFiles}/Herbert
    ENV{ProgramFiles}/Herbert/herbert_core
)

if(NOT Herbert_ROOT)
    find_path(Herbert_ROOT
        NAMES "herbert_init.m"
        PATHS ${DIRS_TO_SEARCH}
        DOC "The Herbert root directory - the directory containing herbert_init.m."
    )
elseif(NOT EXISTS "${Herbert_ROOT}/herbert_init.m")
    message(WARNING "Herbert_ROOT - ${Herbert_ROOT} does not contain herbert_init.m")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Herbert DEFAULT_MSG Herbert_ROOT)
