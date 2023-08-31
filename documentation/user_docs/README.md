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
Horace documentation is also available from:

https://pace-neutrons.github.io/horace-docs

to get the latest version.

For this explicit version, see:

https://pace-neutrons.github.io/horace-docs/3.6.3/ 
