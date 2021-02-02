#################
Binary operations
#################

Binary operations between two objects can be handled in a variety of ways in Horace. You can either use the Matlab symbols +, - , \*, / and \\\, or you can use the explicit function names ``plus, minus, mtimes, mrdivide`` and ``mldivide``.

There are several options for the input parameters to binary operations


sqw objects
-----------

Let us take for our example the addition operator '+', and our initial single sqw object is called ``w1`` and has the 'pix' array retained (note this is an important point - you can have an sqw object without the pix array by converting a dnd object to sqw. In that case the result is referred to as an sqw object of dnd type. In our example ``w1`` has a pix array, so is referred to as an sqw of sqw type).

Single sqw object
=================

You can add to w1 in the following way

::

   wout = w1 + w2_sqw
   wout = w1 + w2_sqw_dnd_type
   wout = w1 + w2_dnd
   wout = w1 + scalar


The conditions for these operations are as follows:

- ``w2_sqw`` is an sqw of sqw type, with a pix array of identical size to the pix array of ``w1``. There is only really one circumstance in which doing a binary operation of this type makes sense - when a background dataset has been created that maps exactly onto the real dataset, and needs to be subtracted.

- ``w2_sqw_dnd_type`` is an sqw of dnd type (i.e. no it has pix array) whose plot axes overlap exactly with those of ``w1``. An example is taking a 1d cut along the energy axis from two different regions of reciprocal space, and then adding or subtracting one from the other. In this case the output will be a sqw object of dnd type, since the pixel information has lost its connection with the signal and error that are plottable.

- ``w2_dnd`` as above, but ``w2_dnd`` is a dnd object rather than an sqw of dnd type. Similarly to the above, the output is an sqw object of dnd type.

- ``scalar`` is a single number, e.g. if you want to add 4.782 to all of the data in ``w1``. The output stays as a full sqw of sqw type (with pix array).


Array of sqw objects
====================

You can use the same binary operation syntax as for single sqw objects, with the following conditions

- ``w2_sqw`` is either an array of sqw of sqw type objects with the pix array of each element matching the pix array of each element of ``w1``. Or a single sqw object if the pix array happens to be the same size for all elements of the ``w1`` array.

- ``w2_sqw_dnd`` is as above, i.e. an array of dnd-type sqw objects whose plot axes match element by element those of the array ``w1``.

- ``w2_dnd`` same rules as for sqw of dnd type above.

- ``scalar`` the same scalar is subtracted from every pix array in the array of sqw objects.

There is one additional possibility

::

   wout = w1 + numeric_array


- ``numeric_array`` is an array of scalars whose size matches the size of the sqw array. The output will continue to be an sqw of sqw type, with a pix array.

dnd objects
-----------

Note that here we will use the phrase dnd object also to mean sqw object of dnd type, since the two are very closely related.

Single dnd object
=================

The choices for a dnd object are:

::

   wout = w1 + w2_sqw
   wout = w1 + w2_sqw_dnd_type
   wout = w1 + w2_dnd
   wout = w1 + scalar


The forms of these objects are as described for the sqw case. In all cases the output will be a dnd object. Note that the pix field of ``w2_sqw`` is ignored for this operation.



Array of dnd objects
====================

As with arrays of sqw objects, there is one further choice compared to a single dnd:

::

   wout = w1 + numeric_array


As for sqw objects, the numeric array has to be the same size as the array of dnd objects.


List of operations and their equivalent code
--------------------------------------------

The arithmetic operations above correspond to equivalent Matlab functions. You should never need to use these, but for reference the corresponding functions are:

::

   w1 + w2 --> plus(w1,w2)
   w1 - w2 --> minus(w1,w2)
   w1  w2 --> mtimes(w1,w2)
   w1 / w2 --> mrdivide(w1,w2)
   w1 \\ w2 --> mldivide(w1,w2)
   w1 ^ w2 --> mpower(w1,w2)


**Important** the matrix operations \*, /, \\\\ and ^ (mtimes, mrdivide, mldivide and mpower) are performed **element-by-element**. So the equivalent Matlab routines would be .*, ./, .\\\ and .^
