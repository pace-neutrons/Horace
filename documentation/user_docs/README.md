# Offline Documentation

## Building Docs

### Requirements
The documentation requires the following to be installed:
* Python (3.5+)
* Sphinx
* Sphinx RTD theme

On Linux (Optional):
* Make

### Building Locally
To build the docs locally:

* Windows

  With a command terminal in the root folder of the horace-docs project run:

      make.bat html

* Linux (With Make)

  With `make` installed simply run:

      make html

* Linux (No Make)

  If you do not have `make` installed, run:

      sphinx-build -M html "docs" "build"


Built documents will be put in the `/build/html` folder, the main file is the `index.html` file.

## Online documentation
The latest stable Horace documentation is also available from:

https://pace-neutrons.github.io/Horace/stable

where `/stable` can be omitted. The latest development version of the 
documentation can be obtained by replacing `stable` with `unstable`.

`Horace` and `Horace/stable` both immediately redirect to the path of the 
latest stable version, which is currently:

https://pace-neutrons.github.io/Horace/v3.6.3/ 

Older versions are available; to see these, enter the Horace repo at the 
top level and switch to branch `gh-pages`.

Details on the use of this branch to store release documentation can be
found in `adr/0002-use-github-for-documentation.md`.
