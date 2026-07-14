##########
Horace GUI
##########

The Horace Graphical User Interface (GUI) is available as an alternative to using the command line. It is included in the latest distributions of Horace and we welcome comments from users regarding how it could be improved (please email `Horace Help <mailto:HoraceHelp@rl.ac.uk>`__ with feedback).

Please note that the bottom 3 buttons, combine, rebin and symmetrise; are linked to new functions which are still being tested. Therefore if you use either of these 3 options we cannot guarantee that the output will be correct in all circumstances!


Using the GUI
=============

To open the GUI simply type in the Matlab command window:

::

   >> horace


The following figure should then appear:

.. image:: ../images/GUI_main_window.png
   :width: 500px
   :alt: Main GUI window


In particular note the white messages area in the bottom left corner. In this box (or similar in pop-ups) a message is displayed whenever you perform an operation. If the operation worked the the message will be "Success!". Otherwise a message explaining what was wrong will be displayed.

There are three main tabs that one can toggle between.

Generate SQW file tab
*********************

The first is a tab which guides you through creation of an sqw file

.. image:: ../images/Gen_sqw_completed.png
   :width: 500px
   :alt: SQW file creation completed


Data on file tab
****************

The next is to cut data from an sqw file that has already been made:

.. image:: ../images/Data_on_file.png
   :width: 500px
   :alt: Cutting data from a file on disk


Data in memory tab
******************

The main GUI window is for dealing with data that have already been cut from file, and are now sitting in your computer's memory:

.. image:: ../images/Data_in_mem.png
   :width: 500px
   :alt: Cutting data from a file on disk


Within this tab there are multiple tabs which you can toggle between to run the various operations in Horace, such as plotting, taking cuts from cuts, symmetrising, binary operations, etc, etc.

Symmetrisation
**************
..
   TODO: Find image

.. image:: ../images/Symmetrise.png
   :width: 500px
   :alt: The symmetrisation tab


Binary Operations
*****************


.. image:: ../images/Binary_ops.png
   :width: 500px
   :alt: The binary operations tab


Unary Operations
****************

.. image:: ../images/unary_ops.png
   :width: 500px
   :alt: The unary operations tab
