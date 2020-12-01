# Documentation

This document will outline the process surrounding the documentation currently housed in the `documentation/user_docs` folder and 
available separately as a download with release from (URL TBD)
It assumes a basic knowledge of reStructuredText (reST) format (https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html)
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
First, with a clone of the `Horace` repository, go to the `documentation/user_docs` folder.

* Windows
  
  With a command terminal in the root folder of the horace-docs project run:
    
      make.bat html

* Linux (With Make)

  With `make` installed simply run:

      make html
    
* Linux (No Make)

  If you do not have `make` installed, run:

      sphinx-build -M html "docs" "build"


Built documents will be put in the `/build/html` folder, the main file is the `index.rst` file.

#### Differences between a local and online build

Currently any local build will not strip the `[NULL]` lines from the documentation sidebar, this will be updated in a later release.

## Adding new documents
### Create new `.rst`

The first job to add a new document is to create it. 

* The file should be added into the `docs` folder within `documentation/user_docs`, preferably with the `.rst` suffix. 
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

#### The TOC Tree

The TOC (table of contents) tree describes all child reST files to be loaded for the purpose of references.
It also provides the the details for the links sidebar . 

To include a document and include it in the side bar, simply add the new filename (without file extension) to the toctree. 

To include a document for reference, but not in the sidebar add the element to the TOCTree via:

    [NULL] <file-name>

More info can be found https://www.sphinx-doc.org/en/master/usage/restructuredtext/directives.html?highlight=toctree#table-of-contents

#### Main contents list

The contents list is a manual table of contents linking to main documentation which will appear on the main page. Any contributions which wish to be listed in the main table of contents should appear here.

## Deploying documentation

The documentation will be deployed automatically on a nightly build to the `latest` page of the GitHub pages. 
On release, documentation will be deployed to the folder corresponding to the version number of the relase and redirected to by the `stable` page of the GitHub pages
