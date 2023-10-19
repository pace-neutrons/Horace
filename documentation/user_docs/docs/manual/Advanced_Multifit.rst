#################
Advanced Multifit
#################

At some point in the future it may be possible that someone wishes to extend the
usage of ``multifit`` as a generic fitting engine to fit multivariate problems
with multiple correlated datasets contained in a data-containing class. To
support this no-doubt noble goal, this section describes how to define a
dataclass which is compatible with ``multifit`` specifications.


Multifit methods requirements
=============================


In many cases, the most convenient thing to do is extract the x, y, and error
arrays from an object and pass those to ``multifit``. This can be done by
defining an ``xye`` method on the class which returns an x, y, e triple:

.. code-block:: matlab

   >> kk = multifit(xye(w));

where the method ``xye`` must return a structure of the form required by
``multifit``, i.e. a structure with fields ``x``, ``y`` and ``e``, where ``x``
is a cell array ``{x1, x2, ...}`` containing vectors of coordinates along each
axis, and ``y`` and ``e`` are vectors of the signal's magnitude and standard
deviation respectively.

A convenient way to do this is to use the methods `sigvar_get`_ and
`sigvar_getx`_ if they have been written to allow the object itself to be passed
to ``multifit``.

If ``multifit`` is being used to fit functions to instances of the class itself
rather than bare x-y-e triples, then there are some methods that need to be
defined on the class. You might want to fit the objects if their internal
structure is more complex, for example if the fitting function depends on fields
other than just the x values and parameters being passed to the fit function.

Another case is when the masking of points from fitting requires manipulation of
fields other than simply removing x-y-e values.

.. note::

   One example is the ``sqw`` objects used in Horace. Here, the calculation of
   the intensity at a data point depends on the individual pixels that
   contribute to that data point. Masking requires that the pixel information of
   masked bins is removed from the ``sqw`` object.

The methods required for fitting objects with ``multifit`` are as follows:

Fit functions
*************

The general format for a valid fitting function is:

.. code-block:: matlab

   >> wcalc = my_function (w, c1, c2, c3, ...)

where ``w`` is the object to be fitted and ``c1``, ``c2``, ``c3``, ... are the fit
parameters.

.. note::

   The global and background function(s) if given, can be methods of the
   class or simply functions, with input argument form as described in detail by
   ``help('multifit')``.

Defining members of the ``multifit`` family of functions as methods of your
class allows you to use that method to process arguments as needed before
passing them through to the underlying ``mfclass`` object (which defines the
fitting operation itself). This is done when fitting a Guassian to an ``sqw``,
for example, where the ``sqw`` determines the correct dimensionality of Gaussian
to match that of the object.

Utility methods
---------------

This section contains a list of methods which ``multifit`` understands and are
used to fit user-defined classes.

.. note::

   Those defined as "[Optional]" are not necessary for an class to be fit, but
   can be helpful in optimisation. They will be used if available, but
   ``multifit`` will fall back to mandatory methods automatically if not
   provided.

mask
~~~~

.. code-block:: matlab

   wout = mask(win, msk)


A method that removes data points from further calculation. The output object must
be a valid instance of the class in which the masked values have been removed in
whatever sense the class and fitting requires.

.. _mask_points:

mask_points [optional]
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   [msk, ok, mess] = mask_points(win, 'keep', xkeep, 'remove', xremove, 'mask', msk_in)

Create a mask array given ranges of x-coordinates to keep, remove or mask from
the array. The elements of a mask array are ``true`` for those data points which
are to be retained, i.e. NOT omitted.

.. note::

   It is not necessary to provide a ``mask_points`` method if a `sigvar_getx`_
   method is defined, however, ``mask_points`` will take priority over
   ``sigvar_getx``

.. warning::

   ``mask_points`` should return a logical flag ``ok``, with message string in
   ``mess`` if not ``ok`` rather than terminate.

   If the function is only ever to be used without demanding the ``ok`` /
   ``mess`` return values from ``multifit`` it is possible to avoid this
   requirement.

   However, if it is expected that other people will attempt to fit your custom
   class, this requirement should be respected or very obviously documented as
   not complying.

sigvar_get
~~~~~~~~~~

.. code-block:: matlab

   [y, var, msk] = sigvar_get(win)

A method that returns the intensity and variance arrays from an object, along
with a mask array that indicates which elements are to be retained.

.. note::

   elements of ``y`` and ``var`` which correspond to ``true`` elements of
   ``msk`` are retained.

   An example of where ``msk`` might be useful is points where ``y``
   or ``var`` are undefined due to normalisation (dividing by zero) as part of
   calculating ``sigvar``.

.. warning::

   The output arrays ``y`` and ``var`` must have the same size and shape.

   ``msk`` must have the same number of elements as ``y`` and ``var``, but can
   be a different shape.

.. warning::

   The returned ``msk`` must be compatibible with the `mask`_ method.

.. _sigvar_getx:

sigvar_getx [optional]
~~~~~~~~~~~~~~~~~~~~~~


.. code-block:: matlab

   x = sigvar_getx(win)

Get the corresponding ``x`` values to the ``y``, ``var``, ``msk`` arrays that
are returned by ``sigvar_get``.

- If one dimensional, i.e. single x coordinate per point:

  ``x`` will be a single array, the same size as ``y`` and ``var``

- If n-dimensional, i.e. n x-values per point:

  ``x`` will be a cell array of arrays, one per x dimension, each the same size
  as ``y`` and ``var`` as returned by ``sigvar_get``.

.. note::

   This method replaces the need to have the `mask_points`_ method, as
   ``sigvar_getx`` will enable ``multifit`` to use its own masking
   function. However, if ``mask_points`` exists, then it will have priority over
   ``sigvar_getx``.

plus [optional]
~~~~~~~~~~~~~~~

.. code-block:: matlab

   wsum = plus(w1, w2)

Basic addition of two objects of the custom class.

.. warning::

   In order to use a background function with ``multifit``, the addition of
   objects must be defined.
