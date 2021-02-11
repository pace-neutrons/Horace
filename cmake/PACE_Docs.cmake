# Build documentation

set(DOCS_DIR "${Horace_ROOT}/documentation/user_docs" CACHE STRING "Directory containing user documentation")

find_program(sphinx-build NAMES sphinx-build)
find_program(pdflatex NAMES pdflatex)
find_program(latexmk NAMES latexmk)
if (sphinx-build)
  if (UNIX)
    add_custom_target(denullify-docs
      COMMAND sed -i -r "/\[NULL\]/d" "${DOCS_DIR}/build/html/*html"
      DEPENDS build-docs
      )
  else()
    add_custom_target(denullify-docs
      COMMAND Foreach($f in Get-ChildItem -Path '${DOCS_DIR}/build/html' -Filter *.html) {(Get-Content $f.FullName) | Where-Object {$_ -notmatch '\[NULL\]'} | Set-Content $F.FullName}
      DEPENDS build-docs
      VERBATIM
      )
  endif()

  add_custom_target(build-docs
    COMMENT "Building user documentation"
    BYPRODUCTS "${DOCS_DIR}/html/*"
    COMMAND ${sphinx-build} -b html "${DOCS_DIR}/docs" "${DOCS_DIR}/build/html" ${SPHINX_OPTS} -D "release=${${PROJECT_NAME}_SHORT_VERSION}" -D "version=${${PROJECT_NAME}_SHORT_VERSION}"
    )

  add_custom_target(docs
    DEPENDS build-docs
    DEPENDS denullify-docs
    )

  if (pdflatex AND latexmk)
    add_custom_command(OUTPUT horace.tex
      COMMAND ${sphinx-build} -b latex "${DOCS_DIR}/docs" "${DOCS_DIR}/build/latex" ${SPHINX_OPTS} -D "release=${${PROJECT_NAME}_SHORT_VERSION}" -D "version=${${PROJECT_NAME}_SHORT_VERSION}"
      WORKING_DIRECTORY "${DOCS_DIR}"
      )

    add_custom_command(OUTPUT horace.pdf
      # Necessary to ignore return code
      COMMAND latexmk -pdf -ps- -dvi- -silent -f -r "${DOCS_DIR}/build/latex/latexmkrc" "${DOCS_DIR}/build/latex/horace.tex"
      DEPENDS horace.tex
      BYPRODUCTS "${DOCS_DIR}/build/latex"
      WORKING_DIRECTORY "${DOCS_DIR}/build/latex"
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
