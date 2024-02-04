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
Horace documentation is also available using this URL to get the latest stable version:

https://pace-neutrons.github.io/Horace
OR
https://pace-neutrons.github.io/Horace/stable

To refer to this version (at the date of writing) explicitly, use:

https://pace-neutrons.github.io/Horace/v3.6.3

To refer to the absolute latest development version including the most recent edits, use:

https://pace-neutrons.github.io/Horace/unstable

which may refer to a more recent version of Horace.
