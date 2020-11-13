# Documentation

This document will outline the process surrounding the documentation currently housed in the `horace-docs` repository. It assumes a basic knowledge of Restructured Text (ReST) format (https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html) especially the subset of the sphinx-doc toolset (https://www.sphinx-doc.org/en/master/)

## Documentation style guide


## Adding new documents
### Create new `.rst`

The first job to add a new document is to create it. 

* The file should be added into the `docs` folder, preferably with the `.rst` suffix. 
   * For ease the filename of the document should be the title with spaces replaced by underscores. 
* It should be written using the sphinx-doc style, including interfile references through:

    ```
    :ref:`link-label <link_file:link_location>`
    ```
    
 * External references are written in the usual ReST format:

    ```
    `link-label <https:\\link-to-elsewhere>`
    ```

### Update index

The main file in the docs folder is `index.rst` which consists of two major parts. 

#### The TOCTree

The TOC tree describes all child rst files to be loaded for the purpose of references. It also provides the the details for the links sidebar. 

To include a document and include it in the side bar, simply add the new filename (without file extension) to the toctree. 

To include a document for reference, but not in the sidebar

#### Main contents list

The contents list is a manual table of contents linking to main documentation which will appear on the main page. Any contributions which wish to be listed in the main table of contents should appear here.

## Deploying documentation

TBD
