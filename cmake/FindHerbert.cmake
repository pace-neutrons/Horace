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

find_path(Herbert_ROOT
    NAMES "herbert_init.m"
    PATHS ${DIRS_TO_SEARCH}
    DOC "The Herbert root directory - the directory containing herbert_init.m"
)

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

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Herbert DEFAULT_MSG Herbert_ROOT)
