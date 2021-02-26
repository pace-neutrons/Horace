#[=======================================================================[.rst:
FindHerbert
-----------

Looks for the Herbert Matlab software package.

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Herbert_CORE``
The directory within Herbert that contains ``herbert_init.m``

``Herbert_ROOT``
The root directory of Herbert allows the user to overload the search paths 
   for admin files if they are not in the ``Herbert_CORE`` variable. 
   Does not usually need to be manually set. 

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
    ${Horace_ROOT}/Herbert
    ${Horace_ROOT}/../Herbert/
    /usr/local/mprogs/Herbert
    /usr/local/Herbert
    ENV{ProgramFiles}/Herbert
)

# If given defined Herbert root as arg.
if (Herbert_ROOT)
  set(DIRS_TO_SEARCH ${DIRS_TO_SEARCH} ${Herbert_ROOT})
endif()

# Always call this find_path as it make Herbert_CORE editable in the CMake GUI
find_path(Herbert_CORE
    NAMES "herbert_init.m"
    PATHS ${DIRS_TO_SEARCH}
    PATH_SUFFIXES "herbert_core"
    DOC "The Herbert core directory - the directory containing herbert_init.m"
)

# Deals with the case where Herbert_CORE is given on the command line but to
# somewhere incorrect
if(Herbert_CORE AND NOT EXISTS "${Herbert_CORE}/herbert_init.m")
    message(FATAL_ERROR
        "Could not find herbert_init.m inside Herbert_CORE: '${Herbert_CORE}'")
endif()

if (NOT Herbert_ROOT)
  # Root is one dir above core
  set(Herbert_ROOT "${Herbert_CORE}/.." CACHE PATH "Directory containing Herbert. Sets default search paths for admin, etc. Be careful when overriding.")
else()
  # If given through CLI
  set(Herbert_ROOT "${Herbert_ROOT}" CACHE PATH "Directory containing Herbert. Sets default search paths for admin, etc. Be careful when overriding.")
endif()
mark_as_advanced(Herbert_ROOT)

find_file(Herbert_ON_TEMPLATE
    NAMES "herbert_on.m.template"
    PATHS ${Herbert_CORE} ${Herbert_CORE}/admin ${Herbert_ROOT}/admin
    NO_DEFAULT_PATH
)
mark_as_advanced(Herbert_ON_TEMPLATE)


find_path(Herbert_CMAKE_DIR
    NAMES ".cmake-find"
    PATHS ${Herbert_CORE}/cmake ${Herbert_ROOT}/cmake
    NO_DEFAULT_PATH
)
mark_as_advanced(Herbert_CMAKE_DIR)


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Herbert DEFAULT_MSG
    Herbert_ROOT
    Herbert_CORE
    Herbert_CMAKE_DIR
)

if(Herbert_FOUND)
    # Add Herbert's general CMake scripts to CMake path
    list(APPEND CMAKE_MODULE_PATH
        "${Herbert_CMAKE_DIR}/external"
        "${Herbert_CMAKE_DIR}/shared"
    )
endif()
