#[=======================================================================[.rst:
FindHerbert
-----------

Looks for the Herbert Matlab software package.

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Herbert_ROOT``
The directory within Herbert that contains ``herbert_init.m``

``Herbert_ON_TEMPLATE``
The path to the template file for herbert_on - usually in Herbert/admin

``Herbert_WORKER_TEMPLATE``
The path to the template file for worker_v2 - usually in Herbert/admin

#]=======================================================================]
if(Herbert_FOUND)
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

# Always call this find_path as it make Herbert_ROOT editable in the CMake GUI
find_path(Herbert_ROOT
    NAMES "herbert_init.m"
    PATHS ${DIRS_TO_SEARCH}
    DOC "The Herbert root directory - the directory containing herbert_init.m"
)

# Deals with the case where Herbert_ROOT is given on the command line but to
# somewhere incorrect
if(NOT EXISTS "${Herbert_ROOT}/herbert_init.m")
    message(FATAL_ERROR
        "Could not find herbert_init.m inside Herbert_ROOT: '${Herbert_ROOT}'")
endif()

find_file(Herbert_ON_TEMPLATE
    NAMES "herbert_on.m.template"
    PATHS ${Herbert_ROOT} ${Herbert_ROOT}/admin ${Herbert_ROOT}/../admin
    NO_DEFAULT_PATH
)
mark_as_advanced(Herbert_ON_TEMPLATE)

find_file(Herbert_WORKER_TEMPLATE
    NAMES "worker_v2.m.template"
    PATHS ${Herbert_ROOT} ${Herbert_ROOT}/admin ${Herbert_ROOT}/../admin
    NO_DEFAULT_PATH
)
mark_as_advanced(Herbert_WORKER_TEMPLATE)

find_path(Herbert_CMAKE_DIR
    NAMES ".cmake-find"
    PATHS ${Herbert_ROOT}/cmake ${Herbert_ROOT}/../cmake
    NO_DEFAULT_PATH
)
mark_as_advanced(Herbert_CMAKE_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Herbert DEFAULT_MSG
    Herbert_ROOT
    Herbert_CMAKE_DIR
)

if(Herbert_FOUND)
    # Add Herbert's general CMake scripts to CMake path
    list(APPEND CMAKE_MODULE_PATH
        "${Herbert_CMAKE_DIR}/external"
        "${Herbert_CMAKE_DIR}/shared"
    )
endif()
