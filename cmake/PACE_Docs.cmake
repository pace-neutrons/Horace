# Build documentation

set(DOCS_ROOT_DIR "${Horace_ROOT}/documentation/user_docs")
set(DOCS_SOURCE_DIR "${DOCS_ROOT_DIR}/docs")
set(DOCS_WORK_DIR "${DOCS_ROOT_DIR}/build" CACHE FILEPATH "Directory to put in-progress docs")
set(DOCS_OUTPUT_DIR "${DOCS_WORK_DIR}/html" CACHE FILEPATH "Directory containing built HTML documentation")
set(MANUAL_WORK_DIR "${DOCS_WORK_DIR}/latex" CACHE FILEPATH "Directory to build LaTeX sources")
set(MANUAL_OUTPUT_DIR "${DOCS_WORK_DIR}/latex" CACHE FILEPATH "Directory to put compiled LaTeX manual")

find_program(sphinx-build NAMES sphinx-build)
find_program(pdflatex NAMES pdflatex)
find_program(latexmk NAMES latexmk)
if (sphinx-build)
  add_custom_target(docs
    COMMENT "Building user documentation"
    BYPRODUCTS "${DOCS_OUTPUT_DIR}/*"
    COMMAND ${sphinx-build} -b html "${DOCS_SOURCE_DIR}" "${DOCS_OUTPUT_DIR}" ${SPHINX_OPTS}
                            -D "release=${${PROJECT_NAME}_SHORT_VERSION}"
                            -D "version=${${PROJECT_NAME}_SHORT_VERSION}"
    )

  if (WIN32)
    add_custom_command(TARGET docs POST_BUILD
      COMMAND powershell -ExecutionPolicy Bypass -command
                 "Foreach($f in Get-ChildItem -Path '${DOCS_OUTPUT_DIR}' -Filter *.html) {
                      (Get-Content $f.FullName) | Where-Object {$_ -notmatch '\\[NULL\\]'} | Set-Content $f.FullName
                  }"
      DEPENDS build-docs
      VERBATIM
      )
  else()
    add_custom_command(TARGET docs POST_BUILD
      COMMAND sed -i -r "/\[NULL\]/d" "${DOCS_OUTPUT_DIR}/*html"
      DEPENDS build-docs
      )
  endif()

  if (pdflatex AND latexmk)
    add_custom_command(OUTPUT horace.tex
      COMMAND ${sphinx-build} -b latex "${DOCS_SOURCE_DIR}" "${DOCS_WORK_DIR}" ${SPHINX_OPTS}
                              -D "release=${${PROJECT_NAME}_SHORT_VERSION}"
                              -D "version=${${PROJECT_NAME}_SHORT_VERSION}"
      WORKING_DIRECTORY "${DOCS_ROOT_DIR}"
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
      COMMENT "Manual requires latexmk and pdflatex to build"
      )
  endif()

else()
  add_custom_target(docs
    COMMENT "Docs require sphinx and sphinx-rtd-theme to build"
    )

  add_custom_target(manual
    COMMENT "Docs require sphinx and sphinx-rtd-theme to build"
    )
endif()
