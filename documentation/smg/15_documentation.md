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
First, with a clone of the `Horace` repository:

* Cmake **(Recommended)**

  Use the appropriate build command to make the docs following standard CMake procedures (e.g. `make docs`). 
  
  This automatically determines OS specific commands and will check if the appropriate programs are available and writes the documentation to `documentation/user_docs/build/html` by default. It also performs cleanup of the documentation's temporary sidebar links.
  
* Manual
  
  With a command terminal in the manual documentation folder (`documentation/user_docs`) run:
    
      python sphinx-build -M html "docs" "build"


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

## Updating documentation

When producing a new version, the `conf.py` (in `documentation/user_docs/docs`) should have the version updated to match that of the version being built. The documentation should be built manually (as described [here](#building-docs))

## Deploying documentation

### Automatic procedure (recommended)
The documentation will be deployed automatically on a nightly build to the `unstable` page of the GitHub pages (`https://pace-neutrons.github.io/Horace/unstable`). 
On release, documentation will be deployed to the folder corresponding to the version number of the release and 
the `stable` page will be updated to redirect to the most recent (chronological) version of the documentation.

### Manual procedure
This should be used only in dire circumstances e.g. if forcing an update to old documentation or Jenkins failure, and not as the main method. 

The raw docs are stored on the `gh-pages` branch of the main Horace repository. 

First the project should be checked out to the version whose docs need to be updated. 

The docs should be built (see [here](#building-docs)) and the appropriate substitutions made (**N.B.** not necessary if built through CMake):

* Linux
  
  From within the built HTML directory (`documentation/user_docs/build/html`) run:
     
  `sed -r -i '/\[NULL\]/d' *html`
  
* Windows

  From Powershell within the root Horace dir (or set `-Path` appropriately) run:
     
  ```
  Foreach($f in Get-ChildItem -Path documentation/user_docs/build/html -Filter *.html) { \
     (Get-Content $f.FullName) | Where-Object {$_ -notmatch '\\[NULL\\]'} | Set-Content $f.FullName \    
           }
  ```
  
  These should then be copied outside the project to avoid any risk of changes from a repo checkout
  (recommend copying `documentation/user_docs/build/html` to a folder named for the version number)
  
  The next step is to checkout the `gh-pages` 
  (**N.B**, you may need to forcibly ignore changes to the repo from building the docs \[`git reset --hard` will do this, but care must be taken\]),
  then move the built documentation from outside the project to a folder of the appropriate version name in the project root directory. 
  
  If the documentation is the most recent version of the documentation (i.e. `stable`), within the `stable` folder, update `index.html` to redirect to the
  appropriate documentation version folder (the one which has been just copied). 
