# Documentation

This document will outline the process surrounding the documentation currently housed in the `horace-docs` repository. 
It assumes a basic knowledge of reStructured text (reST) format (https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html)
especially the subset of the sphinx-doc toolset (https://www.sphinx-doc.org/en/master/)

## Documentation style guide

TBD

## Building Docs

### Requirements
The documentation requires the following to be installed:
* Python (3.5+)
* Sphinx
* Sphinx RTD theme

On Linux (Optional):
* Make

### Building Locally
Once you have cloned the documentation repository (https://github.com/pace-neutrons/horace-docs)

    git clone https://github.com/pace-neutrons/horace-docs.git

#### Windows
With a command terminal in the root folder of the horace-docs project run:
    
    make.bat html

#### Linux
With `make` installed simply run:

    make html
    
If you do not have `make` installed, run:

    sphinx-build -M html "docs" "build" 

## Adding new documents
### Create new `.rst`

The first job to add a new document is to create it. 

* The file should be added into the `docs` folder, preferably with the `.rst` suffix. 
   * For ease of reference and consistency, the filename of the document should be the title with spaces replaced by underscores. 
* It should be written using the sphinx-doc style, including interfile references through:

    ```
    :ref:`link-label <link_file:link_location>`
    ```
    
 * External references are written in the usual reST format:

    ```
    `link-label <https://link-to-elsewhere>`
    ```

### Update index

The main file in the docs folder is `index.rst` which consists of two major parts. 

#### The TOCTree

The TOC tree describes all child rst files to be loaded for the purpose of references. It also provides the the details for the links sidebar. 

To include a document and include it in the side bar, simply add the new filename (without file extension) to the toctree. 

To include a document for reference, but not in the sidebar add the element to the TOCTree via:

    [NULL] <file-name>

#### Main contents list

The contents list is a manual table of contents linking to main documentation which will appear on the main page. Any contributions which wish to be listed in the main table of contents should appear here.

## Deploying documentation

TBD
