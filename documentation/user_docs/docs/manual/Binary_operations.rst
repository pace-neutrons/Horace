#################
Binary operations
#################

Introduction
============

Binary operations between two objects can be applied in a variety of ways in
Horace. You can either use the symbolic form (``+``, ``-`` , ``*``, ``/``,
``\``), or you can use the explicit function names (``plus, minus, mtimes,
mrdivide``, ``mldivide``, etc.).

Main Horace data objects (main from this chapter point of view) have binary operations defined between them
excluding some special cases below.
Here we call "main" the objects which are related to results of experiment and contain arrays of data
obtained from experiment. These objects in order of their priority are:
 
.. code-block:: matlab

    'sqw','PixelDataBase','DnDBase','IX_dataset','sigvar','numbers and arrays of numbers'

"Priority" here means that the operation between two different priority objects produces the object of higher priority.
The priority of operations is defined by the amount of information stored in objects. We can 
identify three types of information used in operations. 

First is image information defined by ``signal`` and ``variance`` arrays (e.g. ``s`` and ``e`` arrays of ``dnd`` objects).

Second is ``PixelData`` information containing information about every or almost every "neutron event" occurring
in experiment (e.g. ``signal``, ``variance``, ``u1`` and other contents of ``PixelDataBase`` classes). 

Third is the "complexity" of the data, i.e. ``dnd`` object contain signal, variance and number of pixels contributing 
into each image cell, so its priority in operations is higher then ``IX_dataset`` which contain only ``signal`` and ``variance``.


.. note::
   The binary operations are undefined between the objects which contain only pixels and only image information  
   e.g. operation between ``PixelDataMemory`` (pixels) and ``dnd`` object (image) is undefined. 

``sqw`` objects contain both pixels and image information and this information is consistent. 
(See `Binary operations manager`_ on more about this)  As top priority Horace object,
``sqw`` object may participate in operations with any other primary Horace object.

For two objects to be able to participate in binary operation their image size and shape and ``pixel`` size (number of elements)
must be equal. Other possibility is that some information (pixel or image) is missing. 
Scalar number is the only exception from this rule, as operation with this is applied to every element of object's data.

.. note::
   When you perform operation between numeric arrays and ``sqw`` object, the array modifies image first. 
   This means that shape and size of the array have to be consistent with shape and size of image. 
   When operation with array is performed, pixels in ``sqw`` object are modified to maintain consistency with
   modified image. Similar rules are applicable for operations between ``sqw`` object and other objects containing
   image i.e. ``dnd``,``IX_dataset`` and ``sigvar`` objects.

The more information an object has, the higher priority it has in operation,
e.g. if you want to add ``sqw`` (Pixel + image information) and ``IX_dataset`` information, 
the result would be ``sqw`` object as it has both pixel and image information. The resulting ``sqw`` object 
pixel information is calculated from the images resulting in operation to maintain image-pixels consistency. 
Alternatively, the result of ``sqw`` and ``PixelData`` operation would be ``sqw`` object with image calculated 
from pixels changed by operation.

Often used and most useful binary operations are described in more details below.

sqw objects
===========

Let us take for our example the addition operator ``+``. Our initial ``sqw``
object is called ``w2`` and has an attached ``pix`` array.

.. note::

   In the case of ``sqw`` objects, binary operations transform the ``signal``
   and ``variance`` elements of the pixel data.
..
   .. note::

      You can have an ``sqw`` object without the pix array by converting a
      ``dnd`` to ``sqw``, though this is inadvisable as a lot of important information 
	  about experiment specific to ``sqw`` object remains empty as the result of this
	  operation.

Single sqw object
-----------------

You operate on ``w2`` with the following types:

- ``w2_sqw`` is an ``sqw`` object with a pix array of identical size to the pix
  array of ``w2``.

  ::

     wout = w2 - w2_sqw;

.. note::

   A common use for this is when a background dataset has been created that maps
   exactly onto the real dataset, and needs to be subtracted.

- ``w2_dnd`` is a ``dnd`` object commensurate with ``w2.data``

  ::

     wout = w2 + w2_dnd;


- ``num`` is a numeric array of the same size as the ``w2.pix.signal`` array of ``w2``.

  ::

     wout = w2 + num;

- ``scalar`` is a single number to apply to all of the data in ``w2``.

  ::

     wout = w2 + scalar;

..
   - ``w2_sqw_dnd_type`` is an sqw of dnd type (i.e. no it has pix array) whose
     plot axes overlap exactly with those of ``w1``. An example is taking a 1d
     cut along the energy axis from two different regions of reciprocal space,
     and then adding or subtracting one from the other. In this case the output
     will be a sqw object of dnd type, since the pixel information has lost its
     connection with the signal and error that are plottable.

     :: wout = w2 + w2_sqw_dnd_type;

.. note:

Array of sqw objects
--------------------

You can use the same binary operation syntax as for single sqw objects, with the
following conditions

- ``w2_sqw`` is either a scalar ``sqw`` object of commensurate size to all of
  the sqw objects in the array, or an array of ``sqw`` objects with each object
  of commensurate size to its corresponding element of ``w2``.

..
   - ``w2_sqw_dnd`` is as above, i.e. an array of dnd-type sqw objects whose
   plot axes match element by element those of the array ``w2``.

- ``w2_dnd`` same rules as for sqw of dnd type above.

- ``num`` is a numeric array following the size rules above.

- ``scalar`` the same scalar is subtracted from every pix array in the array of
  sqw objects.

dnd objects
===========

Let us again take for our example the addition operator ``+``, with our initial
``dnd`` object called ``w2`` .

.. note::

   In the case of ``dnd`` objects, binary operations transform the ``s`` and
   ``e`` matrices


Single dnd object
-----------------

You can add values to ``w2`` in the following ways:

- ``w2_sqw`` is an ``sqw`` object with a ``dnd`` (in ``data``) of identical size to
  ``w2``.

  ::

     wout = w2 + w2_sqw;

- ``w2_dnd`` is a ``dnd`` object commensurate with ``w2``.

  ::

     wout = w2 + w2_dnd;


- ``num`` is a numeric array of the same size as the arrays of ``w1``.

  ::

     wout = w2 + num;

- ``scalar`` is a single number to apply to all of the data in ``w2``.

  ::

     wout = w2 + scalar;


Array of dnd objects
--------------------

Similar to arrays of sqw objects.

As for sqw objects, arrays have to be the same size as the array of dnd objects
with respectively commensurate array sizes, or a scalar object as the same size
of each.



Tips and Tricks
===============

List of operations and their equivalent code
--------------------------------------------

The arithmetic operations above correspond to equivalent MATLAB functions. For reference,
the corresponding functions are:

::

   w1 + w2 --> plus(w1,w2);
   w1 - w2 --> minus(w1,w2);
   w1 * w2 --> mtimes(w1,w2);
   w1 / w2 --> mrdivide(w1,w2);
   w1 \ w2 --> mldivide(w1,w2);
   w1 ^ w2 --> mpower(w1,w2);


.. warning::

   The matrix operations ``*``, ``/``, ``\`` and ``^`` (``mtimes``,
   ``mrdivide``, ``mldivide`` and ``mpower``) are performed
   element-by-element. So the equivalent MATLAB routines would be ``.*``,
   ``./``, ``.\`` and ``.^`` respectively.

..

.. warning::

	Binary operations between Horace objects, unlike arithmetic operations are not fully invertible.
	If you do ``w_out = w1+w2`` and ``w1_out = w_out-w2`` ``w1_out ~= w1``. 
	
	Actually ``w1.data.s==w1_out.data.s`` and ``w1.pix.signal==w1_out.pix.signal`` but
	errors are accumulated in each operation so:
	
	``w1.data.e<w1_out.data.e`` and ``w1.pix.variance<w1_out.pix.variance``

Binary operations manager
--------------------------------------------

``sqw`` objects contain both pixels and image information and this information is consistent, i.e. 
image is calculated from pixels and pixels are sorted within ``PixelData`` array in such a way that the block of
pixels contributed into image bin(cell) is located in specific position of ``PixelData`` array and this position can be
identified from image. The position :math:`i_1` of the first pixel contributing into image bin(cell) number :math:`n` is defined by
formula: :math:`i_1 = cumsum(sqw.data.npix(1:n-1))+1` and the last by: :math:`i_{end} = i_1+sqw.data.npix(n)-1` where 
:math:`sqw.data.npix` refers to ``npix`` array of ``dnd`` object. Particular pixels positions between :math:`i_1` and :math:`i_{end}`
are random. 

When you perform binary operation between two objects containing pixels, the pixels have to be sorted within the bin to ensure
the operation is performed between correspondent pixels. In many cases, user may be sure that the operation is performed between two 
objects with pixels ordered in the same way. For example, you calculate foreground and background on the same ``sqw`` object and now want 
to add them together. In this case, you may decrease time of your ``plus`` operation by avoiding sorting pixels within the bins as follows:

.. code-block:: matlab

	my_cut = read_sqw(file_with_sqw);
	w_fg   = sqw_eval(my_cut,@my_foreground,foreground_parameters);
	w_bg   = sqw_eval(my_cut,@my_background,background_parameters);	
	w_sum  = binary_op_manager(w_fg,w_bg,@plus,true);
	
Last parameter of ``binary_op_manager`` set to ``true`` disables sorting pixels in bins while performing binary operations.

.. warning::

	Use this option carefully. If you do binary operation between two objects with pixels sorted differently, the first result would look correct. 
	Unfortunately, any future operations on the result of such operation may produce completely unexpected results.