#################
Binary operations
#################

Binary operations between two objects can be applied in a variety of ways in Horace. You can either use the
symbolic form (``+``, ``-`` , ``*``, ``/``, ``\``), or you can use the explicit function names (``plus, minus, mtimes,
mrdivide``, ``mldivide``, etc.).

sqw objects
===========

Let us take for our example the addition operator ``+``, and our initial ``sqw`` object is called ``w1`` and has an
attached ``pix`` array.

.. note::

   In the case of ``sqw`` objects, binary operations transform the ``signal`` and ``variance`` elements of the pixel data.
..
   .. note::

      You can have an ``sqw`` object without the pix array by converting a ``dnd`` to ``sqw``. Though this is inadvisable.

Single sqw object
-----------------

You can add values to ``w1`` in the following ways:

- ``w2_sqw`` is an ``sqw`` object with a pix array of identical size to the pix array of ``w1``.

  ::

     wout = w1 + w2_sqw;

.. note::

   A common use for this is when a background dataset has been created that maps exactly onto the real dataset, and
   needs to be subtracted.

- ``w2_dnd`` is a ``dnd`` object commensurate with ``w1.data``

  ::

     wout = w1 + w2_dnd;


- ``num`` is a numeric array of the same size as the pix array of ``w1``.

  ::

     wout = w1 + num;

- ``scalar`` is a single number, e.g. if you want to add 4.782 to all of the data in ``w1``.

  ::

     wout = w1 + scalar;

..
   - ``w2_sqw_dnd_type`` is an sqw of dnd type (i.e. no it has pix array) whose plot axes overlap exactly with those of
     ``w1``. An example is taking a 1d cut along the energy axis from two different regions of reciprocal space, and then
     adding or subtracting one from the other. In this case the output will be a sqw object of dnd type, since the pixel
     information has lost its connection with the signal and error that are plottable.

     ::
        wout = w1 + w2_sqw_dnd_type;


Array of sqw objects
--------------------

You can use the same binary operation syntax as for single sqw objects, with the following conditions

- ``w2_sqw`` is either a scalar ``sqw`` object of commensurate size, or an array of ``sqw`` objects of commensurate size
  with each element of ``w1`` respectively.

..
   - ``w2_sqw_dnd`` is as above, i.e. an array of dnd-type sqw objects whose plot axes match element by element those of
   the array ``w1``.

- ``w2_dnd`` same rules as for sqw of dnd type above.

- ``num`` is a numeric array following the size rules above.

- ``scalar`` the same scalar is subtracted from every pix array in the array of sqw objects.

dnd objects
===========

Let us again take for our example the addition operator ``+``, and our initial ``dnd`` object is called ``w1`` .

.. note::

   In the case of ``dnd`` objects, binary operations transform the ``s`` and ``e`` matrices


Single dnd object
-----------------

You can add values to ``w1`` in the following ways:

- ``w2_sqw`` is an ``sqw`` object a ``dnd`` (in ``data``) of identical size to ``w1``.

  ::

     wout = w1 + w2_sqw;

- ``w2_dnd`` is a ``dnd`` object commensurate with ``w1``.

  ::

     wout = w1 + w2_dnd;


- ``num`` is a numeric array of the same size as the arrays of ``w1``.

  ::

     wout = w1 + num;

- ``scalar`` is a single number, e.g. if you want to add 4.782 to all of the data in ``w1``.

  ::

     wout = w1 + scalar;


Array of dnd objects
--------------------

Similar to arrays of sqw objects.

As for sqw objects, arrays have to be the same size as the array of dnd objects with respectively commensurate array
sizes or a scalar object as the same size of each.


List of operations and their equivalent code
--------------------------------------------

The arithmetic operations above correspond to equivalent Matlab functions. You should never need to use these, but for
reference the corresponding functions are:

::

   w1 + w2 --> plus(w1,w2)
   w1 - w2 --> minus(w1,w2)
   w1 * w2 --> mtimes(w1,w2)
   w1 / w2 --> mrdivide(w1,w2)
   w1 \ w2 --> mldivide(w1,w2)
   w1 ^ w2 --> mpower(w1,w2)


.. warning::

   The matrix operations ``*``, ``/``, ``\`` and ``^`` (``mtimes``, ``mrdivide``, ``mldivide`` and ``mpower``) are
   performed element-by-element. So the equivalent Matlab routines would be ``.*``, ``./``, ``.\`` and ``.^`` respectively.
