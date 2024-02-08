###############################################################
Loading ``sqw`` and ``dnd`` objects to memory
###############################################################

Majority of Horace algorithms accept the name of file containing binary ``sqw`` or ``dnd`` object
as the source of the data for operations. This is necessary as not every ``sqw`` object may fit to memory.
When an object can fit memory it is convenient to place it for speed and convenience operating with it. 
Horace provides two methods of placing sqw objects in memory: ``read`` or ``load`` operations and 
``sqw/dnd`` object construction. 

``load`` is standard operation, which allow loading ``sqw/dnd`` objects or arrays of such objects previously
saved from MATLAB to standard MATLAB ``.mat`` file using MATLAB ``save`` operation. The objects operated this way 
must fit memory.

``read`` is standard MATLAB command allowing users loading various data in memory. To allow operations with Horace
``.sqw`` files  without overloading standard ``read`` command, Horace introduces ``read_horace`` family of commands.

read_horace
===========

Reads ``sqw`` or ``dnd`` data from a file. The object type is determined from
the contents of the file.

.. code-block:: matlab

   output = read_horace(filename);

The returned variable is an ``sqw`` or ``dnd`` object.

read_sqw
========

Reads ``sqw`` data from a file.

.. code-block:: matlab

   output = read_sqw(filename);

The returned variable is an ``sqw`` object.

read_dnd
========

As `read_sqw`_, but reads ``dnd`` data saved to file. If the file contains a
full sqw dataset, then only the binned data will be read.

.. code-block:: matlab

   output = read_dnd(filename);

The returned variable is an ``dnd`` object.

##############################################################
Saving sqw objects from memory and creating filebacked objects
##############################################################

save
====

Saves the ``sqw`` or ``dnd`` object from the MATLAB workspace to the file
specified by ``filename``.

.. code-block:: matlab

   save(object, filename)
