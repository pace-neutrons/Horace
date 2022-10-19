# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import datetime


# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------
project = 'Horace'
copyright = f'2006-{datetime.date.today().year}, STFC RAL'
authors = ['A. Buts','T.G. Perring','N. Battam','H. Saunders','M.D. Le','C. Marooney','J. Wilkins', 'R.A. Ewings', 'J. van Duijn', 'I. Bustinduy', 'G. Tucker', 'R. Fair']

author = ', '.join(sorted(authors,key=lambda x: x.split()[-1])) # Authors by surname


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    "sphinxcontrib.matlab",
    "sphinx.ext.autosectionlabel",
    "sphinx.ext.autodoc",
    "sphinx.ext.autosummary",
    "sphinx.ext.napoleon",
    "sphinx.ext.intersphinx",
]

source_suffix = {
    '.rst': 'restructuredtext',
    '.txt': 'restructuredtext',
    '.md': 'markdown',
}

highlight_language = "matlab"

autosectionlabel_prefix_document = True

autosummary_generate = True

napoleon_use_ivar = True
napoleon_use_param = False
napoleon_use_admonition_for_notes = True

matlab_src_dir = os.path.abspath(os.path.join(os.path.abspath('.'), "../../../horace_core"))
matlab_keep_package_prefix = False
primary_domain = 'mat'

intersphinx_mapping = {
    'euphonic': ('https://euphonic.readthedocs.io/en/stable/', None),
}

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']
html_last_updated_fmt = "%c"
html_logo = "../../150px-Quintus_Horatius_Flaccus.jpg"
