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

https://pace-neutrons.github.io/Horace/

At the moment, this is equivalent to the current version, which is:

https://pace-neutrons.github.io/Horace/v3.6.3/ 

which will be automatically moved to if the version number is omitted as in the previous example.
