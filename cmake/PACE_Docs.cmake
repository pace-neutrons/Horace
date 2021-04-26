#[=======================================================================[.rst:
PACE_Docs
-----------------

Build Horace user documentation as either HTML pages or a LaTeX manual

Variables required by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``${Horace_ROOT}``
This is provided by the main CMakeLists.txt

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Horace_DOCS_WORK_DIR``
Root work directory, docs will be built in ``${Horace_DOCS_WORK_DIR}/(html|latex)``

``Horace_DOCS_PACK_OUTPUT``
Output filename (including extension) for compressed docs file
e.g. ``${CMAKE_CURRENT_BINARY_DIR}/docs.zip``

``Horace_MANUAL_OUTPUT_DIR``
Output directory where compiled LaTeX PDF is placed

Targets defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``docs``
Build a HTML webpage variant of the user documentation in ``Horace_DOCS_OUTPUT_DIR``

``docs-pack``
Build HTML docs and compress

``manual``
Build a LaTeX PDF manual of the user documentation

#]=======================================================================]

set(Horace_DOCS_ROOT_DIR "${Horace_ROOT}/documentation/user_docs")
set(Horace_DOCS_SOURCE_DIR "${Horace_DOCS_ROOT_DIR}/docs")
set(Horace_DOCS_WORK_DIR "${Horace_DOCS_ROOT_DIR}/build" CACHE FILEPATH "Directory to build docs")
set(Horace_DOCS_OUTPUT_DIR "${Horace_DOCS_WORK_DIR}/html")
set(Horace_MANUAL_WORK_DIR "${Horace_DOCS_WORK_DIR}/latex")
set(Horace_MANUAL_OUTPUT_DIR "${Horace_DOCS_WORK_DIR}/latex" CACHE FILEPATH "Directory to put compiled LaTeX manual")
if (WIN32)
    set(Horace_DOCS_PACK_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/docs.zip" CACHE FILEPATH "File to store packed HTML documentation")
else()
    set(Horace_DOCS_PACK_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/docs.tar.gz" CACHE FILEPATH "File to store packed HTML documentation")
endif()

find_program(sphinx-build NAMES sphinx-build HINTS "$ENV{APPDATA}/python/python39/site-packages")
find_program(pdflatex NAMES pdflatex)
find_program(latexmk NAMES latexmk)

message(STATUS ${sphinx-build})
message(STATUS ${pdflatex})
message(STATUS ${latexmk})

if (sphinx-build)
  add_custom_target(docs
    COMMENT "Building HTML user documentation"
    BYPRODUCTS "${Horace_DOCS_OUTPUT_DIR}/*"
    COMMAND ${sphinx-build} -b html "${Horace_DOCS_SOURCE_DIR}" "${Horace_DOCS_OUTPUT_DIR}" ${SPHINX_OPTS}
                            -D "release=${${PROJECT_NAME}_SHORT_VERSION}"
                            -D "version=${${PROJECT_NAME}_SHORT_VERSION}"
    )

  if (WIN32)

    add_custom_command(TARGET docs POST_BUILD
      COMMAND powershell -ExecutionPolicy Bypass -command
                 "Foreach($f in Get-ChildItem -Path '${Horace_DOCS_OUTPUT_DIR}' -Filter *.html) { \
                      (Get-Content $f.FullName) | Where-Object {$_ -notmatch '\\[NULL\\]'} | Set-Content $f.FullName \
                  }"
      DEPENDS build-docs
      VERBATIM
      )


    add_custom_target(docs-pack
      COMMENT "Zipping HTML documentation to ${Horace_DOCS_PACK_OUTPUT}"
      COMMAND powershell -ExecutionPolicy Bypass -command
                "Compress-Archive -Path \"${Horace_DOCS_OUTPUT_DIR}/*\" -DestinationPath \"${Horace_DOCS_PACK_OUTPUT}\""
      DEPENDS docs
      )

  else()
    add_custom_command(TARGET docs POST_BUILD
      COMMAND sed -i -r "/\[NULL\]/d" "${Horace_DOCS_OUTPUT_DIR}/*html"
      DEPENDS build-docs
      )

    add_custom_target(docs-pack
      COMMENT "Tarring HTML documentation to ${Horace_DOCS_PACK_OUTPUT}"
      COMMAND tar -czf "${Horace_DOCS_PACK_OUTPUT}" "*"
      WORKING_DIRECTORY "${Horace_DOCS_OUTPUT_DIR}"
      DEPENDS docs
      )

  endif()

  if (pdflatex AND latexmk)
    add_custom_command(OUTPUT horace.tex
      COMMAND ${sphinx-build} -b latex "${Horace_DOCS_SOURCE_DIR}" "${Horace_MANUAL_WORK_DIR}" ${SPHINX_OPTS}
                              -D "release=${${PROJECT_NAME}_SHORT_VERSION}"
                              -D "version=${${PROJECT_NAME}_SHORT_VERSION}"
      WORKING_DIRECTORY "${Horace_DOCS_ROOT_DIR}"
      )

    add_custom_command(OUTPUT horace.pdf
      COMMAND latexmk -pdf -ps- -dvi- -silent -f -r "${Horace_MANUAL_WORK_DIR}/latexmkrc" "${Horace_MANUAL_WORK_DIR}/horace.tex"
      # Copy finished manual to output dir
      COMMAND cmake -E rename "${Horace_MANUAL_WORK_DIR}/horace.pdf" "${Horace_MANUAL_OUTPUT_DIR}/horace.pdf"
      DEPENDS horace.tex
      BYPRODUCTS "${Horace_MANUAL_OUTPUT_DIR}/horace.pdf"
      WORKING_DIRECTORY "${Horace_MANUAL_WORK_DIR}"
      )

    add_custom_target(manual
      COMMENT "Building user manual - Will produce error 12 until docs fixed"
      DEPENDS horace.pdf
      )

  else()
    add_custom_target(manual
      COMMENT "LaTeX manual requires latexmk and pdflatex to build"
      )
  endif()

else()
  add_custom_target(docs
    COMMENT "HTML Docs require sphinx and sphinx-rtd-theme to build"
    )

  add_custom_target(docs-pack
    COMMENT "HTML Docs require sphinx and sphinx-rtd-theme to build"
    )

  add_custom_target(manual
    COMMENT "LaTeX manual require sphinx and sphinx-rtd-theme to build"
    )
endif()
