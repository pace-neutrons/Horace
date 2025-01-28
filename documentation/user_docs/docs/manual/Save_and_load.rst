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


Constructing ``sqw`` object from filename
=========================================

Calling ``sqw`` constructor with the name of binary sqw file is equivalent to invoking ``read_sqw`` function.

.. code-block:: matlab

   output = sqw(sqw_filename);


##############################################################
Saving sqw objects from memory and creating filebacked objects
##############################################################

save
====

There are two ways of saving ``sqw`` or ``dnd`` objects in files to disk.

First -- use MATLAB ``save`` command, which would 
save objects from memory into MATLAB ``.mat`` files:

.. code-block:: matlab

    save('filename','variable_name');
    
The benefit of this way of storing data is the possibility of storing multiple objects in a single ``sqw`` file. 

Note that the method works for objects in memory so if you use it to save filebacked ``sqw`` objects you will probably obtain
unexpected results, as main part of filebacked ``sqw`` object is not located in memory. 

Second one -- store object in binary Horace ``.sqw`` file format.
The command for this is:

.. code-block:: matlab

   save(object, filename);
   
This method saves single object into Horace binary file, but if you have filebacked ``sqw`` object, the method would correctly
write this object so it will be possible to restore the object later. If your filebacked object is backed by temporary file, the object will not be saved as the major part of this object is already located in file. The file contents will be synchronized with the data in memory and temporary file will be renamed to the name, you have provided as input for the ``save`` command.

You of course may use ``save`` command to create Horace binary ``.sqw`` files from objects in memory.

See :ref:`manual/Cutting_data_of_interest_from_SQW_files_and_objects:File- and memory-backed cuts` to read a bit more about filebacked and memory based cuts and :ref:`manual/Changing_Horace_settings:Horace Config` for the information on how to configure size of memory based object.

Create filebacked objects from data on disk
===========================================

If your ``sqw`` file is big enough (see :ref:`mem_chunk_size and fb_scale_factor from "hor_config" class <manual/Changing_Horace_settings:Horace Config>` for numerical meaning of "big enough", the command:

.. code-block:: matlab

    fb_obj = sqw('filename');

will create filebacked object ``fb_obj``. You can operate with filebacked object exactly as with memory based object, but many operations which involve operations with pixels will be slower. Alternatively, you may create filebacked object regardless of its size using command:

.. code-block:: matlab

    fb_obj = read_sqw('filename','-filebacked');

Note, that this command invoked without `-filebacked` is equivalent to ``sqw('filename')`` and 

.. code-block:: matlab

    mb_obj = read_sqw('filename','-force_pix_location');

will try to load ``sqw`` object in memory regardless of its size on disk, so will fail if the object is to big to fit the memory.

The filebacked objects created this way, unlike filebacked objects created as the result of the operations with filebacked objects or large ``cut`` operations, are backed by permanent files which would not be deleted if the object in memory is deleted.