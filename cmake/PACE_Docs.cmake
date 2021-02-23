# Build documentation

set(Horace_DOCS_ROOT_DIR "${Horace_ROOT}/documentation/user_docs")
set(Horace_DOCS_SOURCE_DIR "${Horace_DOCS_ROOT_DIR}/docs")
set(Horace_DOCS_WORK_DIR "${Horace_DOCS_ROOT_DIR}/build" CACHE FILEPATH "Directory to put in-progress docs")
set(Horace_DOCS_OUTPUT_DIR "${Horace_DOCS_WORK_DIR}/html" CACHE FILEPATH "Directory containing built HTML documentation")
set(MANUAL_WORK_DIR "${Horace_DOCS_WORK_DIR}/latex" CACHE FILEPATH "Directory to build LaTeX sources")
set(MANUAL_OUTPUT_DIR "${Horace_DOCS_WORK_DIR}/latex" CACHE FILEPATH "Directory to put compiled LaTeX manual")

find_program(sphinx-build NAMES sphinx-build)
find_program(pdflatex NAMES pdflatex)
find_program(latexmk NAMES latexmk)

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

    set(Horace_DOCS_PACK_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/docs.zip" CACHE FILEPATH "Directory containing built HTML documentation")

    add_custom_target(docs-pack
      COMMENT "Zipping HTML documentation to ${Horace_DOCS_PACK_OUTPUT}"
      COMMAND powershell -ExecutionPolicy Bypass -command
                "Compress-Archive -Path \"${Horace_DOCS_OUTPUT_DIR}/*\" -DestinationPath \"${Horace_DOCS_PACK_DIR}\""
      DEPENDS docs
      )

  else()
    add_custom_command(TARGET docs POST_BUILD
      COMMAND sed -i -r "/\[NULL\]/d" "${Horace_DOCS_OUTPUT_DIR}/*html"
      DEPENDS build-docs
      )

    set(Horace_DOCS_PACK_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/docs.tar.gz" CACHE FILEPATH "Directory containing built HTML documentation")

    add_custom_target(docs-pack
      COMMENT "Tarring HTML documentation to ${Horace_DOCS_PACK_OUTPUT}"
      COMMAND tar -czf "${Horace_DOCS_PACK_OUTPUT}" "*"
      WORKING_DIRECTORY "${Horace_DOCS_OUTPUT_DIR}"
      DEPENDS docs
      )

  endif()

  if (pdflatex AND latexmk)
    add_custom_command(OUTPUT horace.tex
      COMMAND ${sphinx-build} -b latex "${Horace_DOCS_SOURCE_DIR}" "${MANUAL_WORK_DIR}" ${SPHINX_OPTS}
                              -D "release=${${PROJECT_NAME}_SHORT_VERSION}"
                              -D "version=${${PROJECT_NAME}_SHORT_VERSION}"
      WORKING_DIRECTORY "${Horace_DOCS_ROOT_DIR}"
      )

    add_custom_command(OUTPUT horace.pdf
      COMMAND latexmk -pdf -ps- -dvi- -silent -f -r "${MANUAL_WORK_DIR}/latexmkrc" "${MANUAL_WORK_DIR}/horace.tex"
      # Copy finished manual to output dir
      COMMAND cmake -E rename "${MANUAL_WORK_DIR}/horace.pdf" "${MANUAL_OUTPUT_DIR}/horace.pdf"
      DEPENDS horace.tex
      BYPRODUCTS "${MANUAL_OUTPUT_DIR}/horace.pdf"
      WORKING_DIRECTORY "${MANUAL_WORK_DIR}"
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
