#[=======================================================================[.rst:
horace_FindCLangTidy
-----------------

Finds and configures the clang-tidy executable to run static analysis on the CPP code.

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``CMAKE_CXX_CLANG_TIDY``
configured clang-tidy command with selected checks

``CLANG_TIDY_EXE``
the path to clang-tidy executable

``CLANG_TIDY_FIX``
switch to automatically resolve the identified issues (use with caution)

#]=======================================================================]

# Add clang-tidy if available
option(CLANG_TIDY_FIX "Perform fixes for Clang-Tidy" OFF)
find_program(
        CLANG_TIDY_EXE
        NAMES "clang-tidy"
        DOC "Path to clang-tidy executable"
)

if(CLANG_TIDY_EXE)
    set(CLANG_TIDY_CHECKS
            "-*,cppcoreguidelines-*,clang-analyzer-*,bugprone-*,llvm-*,modernize-*,mpi-*,portability-*,readability-*"
            )
    if(CLANG_TIDY_FIX)
        set(CMAKE_CXX_CLANG_TIDY
                ${CLANG_TIDY_EXE};
                -checks=${CLANG_TIDY_CHECKS};
                -fix;
        )
    else()
        set(CMAKE_CXX_CLANG_TIDY
                ${CLANG_TIDY_EXE};
                -checks=${CLANG_TIDY_CHECKS};
        )
    endif()
endif()