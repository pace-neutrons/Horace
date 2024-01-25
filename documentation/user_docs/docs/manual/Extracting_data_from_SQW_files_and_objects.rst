###########################################################
Extracting data of interest from SQW files and objects
###########################################################

.. |SQW| replace:: S(**Q**, :math:`\omega{}`)
.. |Q| replace:: :math:`|\textbf{Q}|`

Normally the whole data produced on the previous stages of the neutron experiment are too large to fit the memory 
of majority of the modern computers. 


cut
===

``cut`` takes data from an ``sqw`` object, ``dnd`` object or saved ``sqw`` or
``dnd`` file and converts it to an object of the same or reduced size and dimensions.
The resulting cut object is itself an ``sqw`` or ``dnd`` object which can be plotted, manipulated,
etc. like any other ``sqw`` or ``dnd`` object. If the resulting object is itself too big to fit memory,
it will be backed by appropriate ``sqw`` file. 
The required inputs are as follows:

.. note::

   For the differences between ``dnd`` and ``sqw`` objects see: :ref:`here
   <manual/FAQ:What is the difference between sqw and dnd objects>`

.. code-block:: matlab

   my_cut = cut(data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin)


Cutting consists of a rebinning of the pixels into the bins specified by the cut
parameters (described below).  These binned pixels will make up the ``dnd`` of
the output object which contains information regarding the plottable data.


Data Source
-----------

``data_source`` is either a string giving the full filename (including path) of
the input ``.sqw`` file or just the variable containing an ``sqw`` or ``dnd``
object stored in memory from which the pixels will be taken.

.. warning::

   By convention both ``sqw`` and ``dnd`` objects use the ``.sqw`` suffix when
   stored to disc. It is advisable to name the file appropriately to distinguish
   the types stored inside, e.g. ``MnO2_sqw.sqw``, ``MnO2_d2d.sqw``.

Projection
----------

This defines the coordinate and thus binning system you will use to plot the
data.

``proj`` should be an instance of a ``projection`` (such as ``line_proj``,
``sphere_proj``, etc.) containing information about the axes and the coordinate
system you wish to use to plot the data.

.. note::

   Because each point in the ``sqw`` file is labelled with h, k, and l (the
   reciprocal lattice vectors) and energy, the underlying pixels will be
   unchanged. It is possible to redefine the coordinate system with the one of
   your choice; the projection merely describes how pixels will be accumulated
   (binned) and thus displayed.


Lattice basis projections
-------------------------

The most common type of projection for single-crystal experiments will be the
``line_proj`` which defines a (usually orthogonal, but not necessarily) system
of linear coordinates from a set of basis vectors.

The ``line_proj`` structure has several mandatory fields:

* ``proj.u``

  3-vector of (h,k,l) specifying first viewing axis.

* ``proj.v``

  3-vector of (h,k,l) in the plane of the second viewing axis.

  The second viewing axis is constructed to be in the plane of ``proj.u`` and
  ``proj.v`` and perpendicular to ``proj.u``.  The the third viewing axes is
  defined as the cross product of the first two. The 4th axis is always energy
  and need not be specified.

.. note::

   The ``u`` and ``v`` of a ``line_proj`` are distinct from the vectors ``u``
   and ``v`` that are specified in :ref:`gen_sqw
   <manual/Generating_SQW_files:gen_sqw>`, which describe how the crystal is
   oriented with respect to the spectrometer and are determined by the physical
   orientation of your sample.

.. note::

   ``u`` and ``v`` are defined in the reciprocal lattice basis so if the crystal
   axes are not orthogonal, they are not necessarily orthogonal in
   reciprocal space.

   E.g.:

   .. code-block:: matlab

      angdeg % => [60 60 90]
      proj = line_proj([1 0 0], [0 1 0]);

   such that ``proj.u`` = :math:`(1,0,0)` and ``proj.v`` = :math:`(0,1,0)`. The
   reciprocal space projection will actually be skewed according to ``angdeg``.


There are optional fields too:

* ``proj.uoffset``

  3-vector in (h,k,l) or 4-vector in (h,k,l,e) specifies an offset for all
  cuts. For example you may wish to make the origin of all your plots (2,1,0),
  in which case set ``proj.uoffset = [2,1,0]``.

* ``proj.type``

  Three character string denoting the unit along each of the three
  **Q**-axes, one character for each axis.

  There are 3 possible options for each element of ``type``:

  1. ``'a'`` -- Inverse angstroms

  2. ``'r'`` -- Reciprocal lattice units (r.l.u.) which normalises so that the
     maximum of :math:`|h|`, :math:`|k|` and :math:`|l|` is unity

  3. ``'p'`` -- Preserve the values of ``proj.u`` and ``proj.v``

  For example, if we wanted the first two **Q**-components to be in r.l.u. and
  the third to be in inverse Angstroms we would have ``proj.type = 'rra'``.

You may optionally choose to use non-orthogonal axes:

.. code-block:: matlab

   proj = line_proj([1 0 0], [0 1 0], [0 0 1], 'nonorthogonal', true);

If you don't specify ``nonorthogonal``, or set it to ``false``, you will get
orthogonal axes defined by ``u`` and ``v`` normal to ``u`` and ``u`` x
``v``. Setting ``nonorthogonal`` to true forces the axes to be exactly the ones
you define, even if they are not orthogonal in the crystal lattice basis.

.. warning::

   Any plots produced using a non-orthogonal basis will plot them as though the
   basis vectors are orthogonal, so features may be skewed.

   The benefit to this is that it makes reading the location of a feature in a
   two-dimensional **Q**-**Q** plot straightforward. This is the main reason for
   treating non-orthogonal bases this way.

Spherical Projections
---------------------

In order to construct a spherical projection, i.e. a projection in
|Q|, :math:`\theta` (azimuth), :math:`\phi` (elevation), :math:`E`, we define the
projection in a similar way to other projections, but instead use ``sphere_proj``:

.. code-block:: matlab

   sp_proj = sphere_proj([0, 0, 0, 0]);

Where ``[0, 0, 0, 0]`` is the offset of the projection with respect to :math:`h,k,l,E`

.. note::

   A spherical projection does not have any scaling aspect to the
   |Q| in the same way a ``line_proj`` can define non-unitary
   vectors as the axes.

When it comes to cutting and plotting, we can use a ``sphere_proj`` in exactly
the same way as we would a ``line_proj`` with one key difference. The binning
arguments of ``cut`` no longer refer to :math:`h,k,l,E`, but to |Q|,
:math:`\theta`, :math:`\phi`, :math:`E`.

.. code-block:: matlab

   sp_cut = cut(w, sp_proj, Q, theta, phi, e, ...);

The structure of the arguments to cut is still the same (see `Binning arguments`_ below)

.. note::

   By default a ``sphere_proj`` will define its principal axes for angular
   integration (:math:`\theta`, :math:`\phi`) as the notional goniometer axes as
   defined by ``u`` and ``v`` in :ref:`gen_sqw
   <manual/Generating_SQW_files:gen_sqw>`. It is possible to change these by
   setting ``ex`` and ``ez`` which are vectors lying in-plane and perpendicular
   to the plane respectively.

Cylindrical Projections
-----------------------

TBD

Binning arguments
-----------------

.. _barguments:

* ``p1_bin``, ``p2_bin``, ``p3_bin`` and ``p4_bin``

  specify the binning / integration arguments for the Q & Energy axes in the
  target projection's coordinate system. Each can independently have one of four
  different forms:

.. warning::

   The meaning of the first, second, third, etc. components changes between each
   form. Ensure that you have the correct value in each component to ensure your
   cut is what you expect.

* ``[]``

  An empty binning range will use the source binning axes in that dimension.

* ``[n]``

  if a single (scalar) number is given then that axis will be a plot axis and the
  bin width will be the number you specify. The lower and upper limits are the
  source binning axes in that dimension.

.. note::

   A value of ``[0]`` is equivalent to ``[]`` and will use the source binning axes.

* ``[lo,hi]``

  If you specify a vector with two components then the signal will be integrated
  over that axis between limits specified by the two components of the vector.

.. warning::

   A two-component binning axis defines the integration region between bin
   edges. For example, ``[-1 1]`` will capture pixels from ``-1`` to ``1``
   inclusive.

* ``[lower,step,upper]``

  A three-component binning axis specifies an axis is a plot axis with the first
  ``lower`` and the last ``upper`` components specifying the centres of the
  first and the last bins of the data to be cut. The middle component specifies
  the bin width.

.. note ::

   If ``step`` is ``0``, the ``step`` is taken from the source binning axes.

.. warning::

   A three-component binning axis defines the integration region by bin centres,
   i.e. the limits of the data to be cut lie between ``min = lower-step/2`` and
   ``max = upper+step/2``, including ``min/max`` values. For example, ``[-1 1
   1]`` will capture pixels from ``-1.5`` to ``1.5`` inclusive.


* ``[lower, separation, upper, cut_width]``

  A four-component binning axis defines **multiple** cuts with **multiple**
  integration limits in the selected direction.  These components are:

  * ``lower``

    minimum cut bin-centre

  * ``separation``

    distance between cut bin-centres

  * ``upper``

    approximate maximum cut bin-centre

  * ``cut_width``

    half-width of each cut from each bin-centre in both directions

  The number of cuts produced will be the number of ``separation``-sized steps
  between ``lower`` and ``upper``.


.. warning::

   ``upper`` will be automatically increased such that ``separation`` evenly
   divides ``upper - lower``.  For example, ``[106, 4, 113, 2]`` defines the
   integration ranges for three cuts, the first cut integrates the axis over
   ``105-107``, the second over ``109-111`` and the third ``113-115``.


Optional arguments
------------------

.. code-block:: matlab

   my_cut = cut (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin, '-nopix', filename)


* ``'-nopix'``

  means that the individual pixel information contributing to the resulting data
  is NOT retained (at present the default is to retain it, resulting in an
  output that is an ``sqw`` object, whereas using ``'-nopix'`` gives a ``dnd``
  output).

* ``filename``

  is a string specifying a full filename (including path) for the data to be
  stored, in addition to being stored in the Matlab workspace.

Further Examples
----------------

To take a cut from an existing ``sqw`` or ``dnd`` object, retaining the existing
projection axes and binning:

.. code-block:: matlab

   w1 = cut(w,[],[lo1,hi1],[lo2,hi2],...)

.. note::

   The number of binning arguments need only match the dimensionality of the
   object ``w`` (i.e. the number of plot axes), so can be fewer than 4.

.. note::

   You cannot change the binning in a dnd object, i.e. you can only set the
   integration ranges, and have to use ``[]`` for the plot axis. The only option
   you have is to change the range of the plot axis by specifying
   ``[lo1,0,hi1]`` instead of ``[]`` (the '0' means 'use existing bin size').


section
=======

``section`` is an ``sqw`` method, which works like a cut but uses the existing
bins of an ``sqw`` object rather than rebinning.

.. code-block:: matlab

   wout = section(w, p1_bin, p2_bin, p3_bin, p4_bin)


Because it only extracts existing bins, this means that it doesn't need to
recompute any statistics related to the object itself and is therefore faster
and more efficient. However, it has the limitation that it cannot alter the
projection or binning widths from the original.

The parameters of section are as follows:

* ``w``

  ``sqw`` object(s) to be sectioned as an array (of 1 or more elements)

* ``pN_bin``

  Range of bins specified as bin edges to extract from ``w``.

  There are three valid forms for any ``pN_bin``:

  * ``[]``, ``[0]``

    Use entire original binning axis.

  * ``[lo, hi]``

    Range containing bin centres to extract from ``w``


.. note::

   The number of ``pN_bin`` specified must match the dimensionality of the
   underlying ``dnd`` object.

.. note::

   These parameters are specified by inclusive edge limits. Any ranges beyond
   the the ``sqw`` object's ``img_range`` will be reduced to only capture extant
   bins.

.. warning::

   The bins selected will be those whose bin centres lie within the range ``lo -
   hi``, this means that the actual returned ``img_range`` may not match ``[lo
   hi]``. For example, a bin from ``0 - 1`` (centre ``0.5``) will be included by
   the following ``section`` despite the bin not being entirely contained within
   the range. The resulting image range will be ``[0 1]``.

   .. code-block:: matlab

      section(w, [0.4 1])

In order to extract bins whose centres lie in the range ``[-5 5]`` from a 4-D
``sqw`` object:

.. code-block:: matlab

   w2 = section(w1, [-5 5], [], [], [])

