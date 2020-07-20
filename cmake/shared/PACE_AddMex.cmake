#[=======================================================================[.rst:
pace_add_mex
-------

Build a Matlab mex library. Most arguments are passed to the `matlab_pace_add_mex`
function defined in the `FindMatlab.cmake` script bundled with CMake. Due to
this, the `FindMatlab.cmake` script must be called before this script is this
function is defined.

::

    pace_add_mex(
        NAME <name>
        [EXECUTABLE | MODULE | SHARED]
        SRC src1 [src2 ...]
        [OUTPUT_NAME output_name]
        [DOCUMENTATION file.txt]
        [LINK_TO target1 target2 ...]
        [...]
    )

Arguments
^^^^^^^^^

From the FindMatlab.cmake script:

``NAME``
name of the target.
``SRC``
list of source files.
``LINK_TO``
a list of additional link dependencies.  The target links to ``libmex``
by default. If ``Matlab_MX_LIBRARY`` is defined, it also
links to ``libmx``.
``OUTPUT_NAME``
if given, overrides the default name. The default name is
the name of the target without any prefix and
with ``Matlab_MEX_EXTENSION`` suffix.
``DOCUMENTATION``
if given, the file ``file.txt`` will be considered as
being the documentation file for the MEX file. This file is copied into
the same folder without any processing, with the same name as the final
mex file, and with extension `.m`. In that case, typing ``help <name>``
in Matlab prints the documentation contained in this file.
``MODULE`` or ``SHARED`` may be given to specify the type of library to be
created. ``EXECUTABLE`` may be given to create an executable instead of
a library. If no type is given explicitly, the type is ``SHARED``.

#]=======================================================================]
function(pace_add_mex)

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
        set(TYPE "EXECUTABLE")
    elseif(${${prefix}_MODULE})
        set(TYPE "MODULE")
    elseif(${${prefix}_SHARED})
        set(TYPE "SHARED")
    endif()

    matlab_add_mex(
        NAME "${${prefix}_NAME}"
        "${TYPE}"
        SRC "${${prefix}_SRC}"
        OUTPUT_NAME "${${prefix}_OUTPUT_NAME}"
        DOCUMENTATION "${${prefix}_DOCUMENTATION}"
        LINK_TO "${${prefix}_LINK_TO}"
    )
    set_target_properties("${${prefix}_NAME}"
        PROPERTIES
            # Appending the $<0:> generator expression outputs the mex file to
            # the *_DLL_DIRECTORY, omitting Release/Debug sub-folders
            RUNTIME_OUTPUT_DIRECTORY "${${PROJECT_NAME}_DLL_DIRECTORY}$<0:>"
            LIBRARY_OUTPUT_DIRECTORY "${${PROJECT_NAME}_DLL_DIRECTORY}$<0:>"
        )
endfunction()
