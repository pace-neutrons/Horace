#####################
Other shape functions
#####################

``replicate``
=============

This is a function to create a higher dimensional dataset by replicating along
an additional axis. For example, a ``d2d`` which is essentially a 2D array of
intensity, can be replicated to make a ``d3d`` (a 3D array of intensity) where
the extra dimension is made up of the original "stacked" atop copies of itself in
that direction. Likewise, a ``d4d`` might be made up of "stacked" copies of a
``d3d``.

In Matlab syntax this means e.g.

::

   oldmat = [1 2; 3 4];
   newmat(:,:,1) = oldmat;
   newmat(:,:,2) = oldmat;

The actual syntax for replicate does not construct the layers individually.
Instead, a reference object of the required dimensionality (``wref_3d`` below)
is supplied to act as a template.

::

   w_3d = replicate(w_nd, wref_3d);


or

::

   w_4d = replicate(w_nd, wref_4d);


.. note::

   ``wref`` can be either a ``dnd`` or an ``sqw`` type object.

.. warning::

   ``w_nd`` must be ``dnd`` and not ``sqw``, ``replicate`` on an ``sqw`` object
   simply returns its representative ``dnd`` replicated.

.. warning::

   This function cannot be applied to a 4-dimensional object, attempting to
   ``replicate`` a 4-d object will result in an error.

``compact``
===========

Trim empty bins from around the border of a dnd.

The resulting object has its ranges redefined such that all primary axis
dimensions are the minimum required to contain all data without losses.

::

   wout = compact(win);

.. note::

   For example,

   Suppose we have a 2-dimensional dataset where the axes are ``p{1} =
   [-4.5:1:4.5]`` and ``p{2} = [-4.5:1:4.5]``. The intensity would be given by a
   10x10 matrix. Suppose there is only non-zero intensity for ``-3 < p{1} < 3``
   and ``-3 < p{2} < 3``. In this case ``compact`` would reduce the size of the
   intensity matrix, to be ``[-2.5:1:2.5], [-2.5:1:2.5]`` (6x6).

``permute``
===========

Function to permute the order of the display (binning) axes in an object.

::

   wout = permute(win[, permutation]);


Permutation is an nx1 array for n-dimensional objects specifying the new order
of each axis. If no ``permutation`` is provided, the function will cyclically
permute the axes by one (e.g. 1->2, 2->3, 3->4, 4->1).

.. note::

    ::

       wout = permute(w_3d, [3 2 1]);


    makes the new 1st axis the old 3rd, and the new 3rd axis the old 1st.

.. note::

   This function only changes the order of the axes for display. All other
   information, including the projection axes, are unchanged.


``cut``
=======

Produce a rebinned dataset from a starting dataset. See :ref:`cut
<manual/Manipulating_and_extracting_data_from_SQW_files_and_objects:cut>` for
more details.

::

   wout=cut(win, ax_1, ax_2, ...);


where ``ax_1`` etc. take the form:

- ``[lo, hi]`` for integration between two limits

- ``[lo, step, hi]`` for a plot axis between given limits with a given step size

- ``[step]`` for a plot axis taking the existing lo and hi and rebinning to a
  given step size,

- ``[]`` for leaving the limits and step size of an axis unchanged.

.. note::

   For ``dnd`` objects, it is only possible to cut to the same or lower
   dimensionality. This is because they do not contain the underlying pixel
   information with which to rebin the data.

   For example, for a d3d starting dataset you can get to a d2d, d1d, or
   d0d. The lower dimensional dataset is created by taking the average over a
   given integration range from the original dataset.

.. note::

   For example:

   ::

      wout = cut(w_3d, [-0.2, 0.2], [0.9, 1.1], []);

   takes the input d3d object ``w_3d`` and averages the signal between the
   limits -0.2 and +0.2 for the 1st axis, and between 0.9 and 1.1 for the second
   axis. The resultant ``wout`` is thus a d1d.


``section``
===========

Takes a cut from an n-dimensional object without rebinning.

::

   wout=section(win, [ax1_lo, ax1_hi], [ax2_lo, ax2_hi], ...)

.. warning::

   Only bin centres within the limits of ``lo``, ``hi`` will be captured.

.. note::

   The difference between ``section`` and ``cut`` is that ``section`` does not
   have to rebin data as the selected data are taken from the original's
   bins. This means that section is much faster for cases where bins are not
   changing.

   This does, however, mean that it is impossible to reshape or resize bins as
   part of a ``section`` operation.


``win`` is the input dnd or sqw object, and the vectors ``[ax_lo, ax_hi]``
specify the lower and upper limits on each axis to retain.

.. note:: If just a zero is specified, e.g.

   ::

      wout = section(win, [1, 2], 0, [3, 4])


   then the existing limits are retained. So for the above 3-dimensional example
   data along the first axis between 1 and 2 are retained, and data between 3
   and 4 on the 3rd axis are retained, and all of the data along the second axis
   are retained.


``smooth``
==========

A function that can be used on ``dnd`` objects smooths the data ``win`` by
convolving it with a windowing function.

.. warning::

   This function is not implemented for ``sqw`` objects where it would make very
   little sense.


::

   wout = smooth(win[, width_vector][, function])


.. note::

   This function is will do nothing if applied to ``d0d`` objects where it is
   functionally meaningless.


.. note::

   The default ``width_vector`` if not supplied is ``3`` for all dimensions.

The vector ``[width_vector]`` is an nx1 array for a n-dimensional object and
gives the width of the convolution along each axis in terms of the number of
bins. Alternatively you can supply a 1x1 (scalar) array, in which case the same
width will be used for all axes. You can also choose with what function the data
are convoluted.

``function`` may be either either ``'hat'`` or ``'gaussian'`` to apply the
respective windowing function.

``mask``
========

Apply a mask to points in an n-dimensional dataset ``win``.

::

   wout = mask(win, mask_array)


The points to mask are defined by ``mask_array``, an array of the same size as
the plot axes of ``win``, consisting of booleans where data are to be retained
(``true``) or masked (``false``) respectively.

.. note::

   In a ``dnd`` The masked out bins have their intensity (``s``) set to NaN,
   errorbar (``e``) set to zero and ``npix`` set to zero.

   In an ``sqw`` the masked pixels are filtered from the data as though cut and
   the corresponding ``dnd`` will reflect this.


``mask_points``
===============

A function to generate a suitable mask array (see above) for an n-dimensional
dataset.

::

   sel = mask_points(win[, 'keep', xkeep][, 'remove', xremove][, 'mask',
   mask_array])


The inputs are:

- ``win`` is the input dataset

- ``xkeep`` is the range of display axes to keep, e.g. ``[x1_lo, x1_hi, x2_lo,
  x2_hi, ..., xn_lo, xn_hi]``. Note also that more than one range can be
  specified for each dimension by writing ``[range_1; range_2;...]``

- ``xremove`` is the range of display axes to remove. Follows the same format as
  ``xkeep``.

- ``mask_array`` is an array of booleans with the same number of elements as the
  data array, with corresponding ``true`` to keep and ``false`` to remove.

.. note::

   This should match the internal stored data, not as presented on the plotting
   axes.

The outputs are:

- ``sel`` mask array the required size, accounting for all of the input
  requirements.

``mask_runs``
=============

Remove all pixels from one or more runs from an sqw object. Useful, for example
if one run from many in an sqw file is deemed to be spurious (e.g. detector
noise, unknown sample orientation, etc.)

::

    wout = mask_runs (win, runno)


The inputs are:

- ``win`` is the ``sqw`` object to be masked.

- ``runno`` is the run number, or array of run numbers, in the sqw object to be
  masked.

.. note::

  Convention is that run number is the position of the file in the list when the
  ``.sqw`` file was generated. This value can be determined by inspecting
  ``win.header``

The output is:

- ``wout``, the output sqw object with mask applied
