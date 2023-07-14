###########################################################
Manipulating and extracting data from SQW files and objects
###########################################################

.. |SQW| replace:: S(**Q**, :math:`\omega{}`)

cut
===

cut takes data from an SQW file and turns it into a cut of reduced size, either in range or dimensionality. The cut is
itself an SQW object which can be plotted, manipulated, etc. The "compulsory" inputs are given as follows:

.. code-block:: matlab

   my_cut = cut(data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin)


Cutting encompasses a rebinning of the pixels into the bins specified by the cut parameters (described below).
These binned pixels will make up the ``DnD`` of the output object which contains information regarding the plottable
data.


Data Source
-----------

``data_source`` is either a string giving the full filename (including path) of the input SQW file or just the variable
containing SQW object stored in memory from which the pixels will be taken.

Projection
----------

This defines the coordinate system you will use to plot the data.

``proj`` should be an instance of a ``projection`` (such as ``ortho_proj``, ``spher_proj``, etc.) containing information
about the axes and the coordinate system you wish to use to plot the data.

.. note::

   Because each point in the SQW file is labelled with h, k, and l (the reciprocal lattice vectors) and energy, the
   underlying pixels will be unchanged. It is possible to redefine the coordinate system with the one of your
   choice; the projection merely describes how pixels will be binned and thus displayed.


Lattice basis projections
-------------------------

The ``ortho_proj`` structure has several mandatory fields:

* ``proj.u``

  3-vector of (h,k,l) specifying first viewing axis.

* ``proj.v``

  3-vector of (h,k,l) in the plane of the second viewing axis.

  The second viewing axis is constructed to be in the plane of ``proj.u`` and ``proj.v`` and perpendicular to ``proj.u``.  The the third
  viewing axes is defined as the cross product of the first two. The 4th axis is always energy and need not be
  specified.

.. note::

   The ``u`` and ``v`` of an ``ortho_proj`` are distinct from the vectors ``u`` and ``v`` that are specified in
   :ref:`gen_sqw <manual/Generating_SQW_files:gen_sqw>`, which describe how the crystal is oriented with respect to the
   spectrometer and are determined by the physical orientation of your sample.

.. note::

   ``u`` and ``v`` are defined in the reciprocal lattice basis so if the crystal axes are not orthogonal, the here are
   not necessarily orthogonal in reciprocal space.

   E.g.:

   .. code-block:: matlab

      angdeg % => [60 60 90]
      proj = ortho_proj([1 0 0], [0 1 0]);

   such that proj.u = (1,0,0) and proj.v = (0,1,0). The reciprocal space projection will actually be offset according to
   angdeg.


There are optional fields too:

* ``proj.uoffset``

  3-vector in (h,k,l) or 4-vector in (h,k,l,e) specifies an offset for all cuts. For example you may wish to make the
  origin of all your plots (2,1,0), in which case set ``proj.uoffset = [2,1,0]``.

* ``proj.type``

  Three character string denoting the unit of measure along each of the three **Q**-axes, one character for each
  axis. If you want an axis to be displayed in inverse Angstroms, set the character to 'a'. For r.l.u. set the
  corresponding character to 'r' (which normalises so that the maximum of \|h|,|k\| and \|l\| is unity) or 'p' (which
  preserves the values of ``proj.u`` and ``proj.v``. For example, if we wanted the first two Q-components to be in
  r.l.u. and the third to be in inverse Angstroms we would have ``proj.type = 'rra'``.

You may optionally choose to use non-orthogonal axes:

.. code-block:: matlab

   proj = ortho_proj([1 0 0], [0 1 0], [0 0 1], 'nonorthogonal', true);

If you don't specify ``nonorthogonal``, or set it to ``false``, you will get orthogonal axes defined by ``u`` and ``v``
normal to ``u`` and ``u`` x ``v``. Setting ``nonorthogonal`` to true forces the axes to be exactly the ones you define, even if
they are not orthogonal in the crystal lattice basis.

.. warning::

   Plots that are produced plot them as orthogonal axes so any features may be skewed.

   However, it does make reading the location of a feature in a two-dimensional **Q**-**Q** plot straightforward, which is the main reason for doing this.

Spherical Projections
---------------------

TBD

Cylindrical Projections
-----------------------

TBD

Binning arguments
-----------------

* ``p1_bin``, ``p2_bin``, ``p3_bin`` and ``p4_bin``
  specify the binning / integration arguments for the Q & Energy axes in
  the target projection's coordinate system. Each can independently have one of four different forms:

.. warning::

   The meaning of the first, second, third, etc. components changes between each form. Ensure that you have the correct
   value in each component to ensure your cut is what you expect.

* ``[]``
  An empty binning range will use the source binning axes in that dimension.

* ``[n]``
  if a single (scalar) number is given then that axis will be a plot axis and the bin width will be the
  number you specify. The lower and upper limits are the source binning axes in that dimension.

.. note::

   A value of ``[0]`` is equivalent to ``[]`` and will use the source binning axes.

* ``[lo,hi]``
  If you specify a vector with two components then the signal will be integrated over that axis between limits
  specified by the two components of the vector.

.. warning::

   A two-component binning axis defines the integration region between bin edges. For example, ``[-1 1]`` will capture
   pixels from ``-1`` to ``1`` inclusive.

* ``[lower,step,upper]``

  A three-component binning axis specifies an axis is a plot axis with the first ``lower`` and the last ``upper``
  components specifying the centres of the first and the last bins of the data to be cut. The middle component specifies
  the bin width.

.. note ::

   If ``step`` is ``0``, the ``step`` is taken from the source binning axes.

.. warning::

   A three-component binning axis defines the integration region by bin centres, i.e. the limits of the
   data to be cut lie between ``min = lower-step/2`` and ``max = upper+step/2``, including ``min/max``
   values. For example, ``[-1 1 1]`` will capture pixels from ``-1.5`` to ``1.5`` inclusive.


* ``[lower, separation, upper, cut_width]``

  A four-component binning axis defines **multiple** cuts with **multiple** integration limits in the selected direction.
  These components are:

  * ``lower``

    minimum cut bin-centre

  * ``separation``

    distance between cut bin-centres

  * ``upper``

    approximate maximum cut bin-centre

  * ``cut_width``

    half-width of each cut from each bin-centre in both directions

  The number of cuts produced will be the number of ``separation``-sized steps between ``lower`` and ``upper``.


.. warning::

   ``upper`` will be automatically increased such that ``separation`` evenly divides ``upper - lower``.  For example, ``[106,
   4, 113, 2]`` defines the integration ranges for three cuts, the first cut integrates the axis over ``105-107``, the
   second over ``109-111`` and the third ``113-115``.


Optional arguments
------------------

.. code-block:: matlab

   my_cut = cut (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin, '-nopix', filename)


* ``'-nopix'``

  means that the individual pixel information contributing to the resulting data is NOT retained (at present the default
  is to retain it, resulting in an output that is an sqw object, whereas using ``'-nopix'`` gives a dnd output).
* ``filename``

  is a string specifying a full filename (including path) for the data to be stored, in addition to being stored in the
  Matlab workspace.

Further Examples
----------------

To take a cut from an existing sqw or dnd object, retaining the existing projection axes and binning:

.. code-block:: matlab

   w1 = cut(w,[],[lo1,hi1],[lo2,hi2],...)

.. note::

   The number of binning arguments need only match the dimensionality of the object ``w`` (i.e. the number of plot
   axes), so can be fewer than 4.

.. note::

   You cannot change the binning in a dnd object, i.e. you can only set the integration ranges, and have to use ``[]``
   for the plot axis. The only option you have is to change the range of the plot axis by specifying ``[lo1,0,hi1]``
   instead of ``[]`` (the '0' means 'use existing bin size').


section
=======

``section`` is an ``sqw`` method, which works like a cut but uses the existing bins of an ``sqw`` object rather than
rebinning.

.. code-block:: matlab

   wout = section(w, p1_bin, p2_bin, p3_bin, p4_bin)


Because it only extracts existing bins, this means that it doesn't need to recompute any statistics related to the
object itself and is therefore faster and more efficient. However, it has the limitation that it cannot alter the
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

   The number of ``pN_bin`` specified must match the dimensionality of the underlying ``dnd`` object.

.. note::

   These parameters are specified by inclusive edge limits. Any ranges beyond the the ``sqw`` object's ``img_range``
   will be reduced to only capture extant bins.

.. warning::

   Selected bins will be those whose bin centres lie within the range ``lo - hi``, this means that the actual returned
   ``img_range`` may not match ``[lo hi]``. For example, a bin from ``0 - 1`` (centre ``0.5``) will be included by the
   following ``section`` despite the bin not being entirely contained within the range. The resulting image range will
   be ``[0 1]``.

   .. code-block:: matlab

      section(w, [0.4 1])

In order to extract bins whose centres lie in the range ``[-5 5]`` from a 4-D ``sqw`` object:

.. code-block:: matlab

   w2 = section(w1, [-5 5], [], [], [])


head_horace
===========

.. code-block:: matlab

   info = head_horace(filename);

   info = head_horace(filename,'-full')


This is a function to give the header information in an SQW file or file to which an sqw object or dnd object has been
saved, and whose full filename is given by the argument ``filename``. If the option ``'-full'`` is used then a fuller
set of header information, rather than just the principal header, is returned. The purpose of this function is to read
the contents regardless of your knowledge of whether or not the file contains an sqw object or a dnd object.


head_sqw
========

.. code-block:: matlab

   info = head_sqw(filename);

   info = head_sqw(filename,'-full')


This is a function to give the header information in an SQW file or file to which an sqw object has been saved, whose
full filename is given by the argument ``filename``. If the option ``'-full'`` is used then a fuller set of header
information, rather than just the principal header, is returned.


head_dnd
========

.. code-block:: matlab

   info = head_dnd(filename);


This is a function to give the header information in file to which a dnd object has been saved, whose full filename is
given by the argument ``filename``.

read_horace
===========

.. code-block:: matlab

   output = read_horace(filename);


This is a function to read sqw or dnd data from a file. The object type is determined from the contents of the file. If
the file contains a full sqw dataset (whether created using gen_sqw or as the result of saving a cut), the returned
variable is an sqw object; if the file contains a dnd dataset, the output is the corresponding d01, d1d, ...or d4d
object.

read_sqw
========

.. code-block:: matlab

   output = read_sqw(filename);

This is a function to read sqw data from a file. Note that in this context we mean an n-dimensional dataset, which
includes pixel information, that has been saved to file. This could be either a full SQW file created wusing gen_sqw, or
an sqw dataset that has been saved to file. The object ``output`` will be an sqw object.


read_dnd
========

.. code-block:: matlab

   output = read_dnd(filename);


Exactly the same as above, but reads dnd data saved to file. If the file contains full sqw dataset, then it will be read
as if it contained just a dnd dataset.


save
====

.. code-block:: matlab

   save(object,filename)


Saves the sqw object or dnd object ``object`` from the Matlab workspace into the file specified by ``filename``.


xye
===

Extract the bin centres, intensity and standard errors from an sqw or dnd object.

.. code-block:: matlab

   S = xye(w);


The output is a structure with fields S.x (bin centres if a 1D object, or cell array of vectors containing the bin
centres along each axis if 2D, 3D or 4D object), S.y (array of intensities), S.e (array of estimated error on the
intensities).


save_xye
========

Save data in an sqw or dnd dataset to an ascii file.

.. code-block:: matlab

   filename = 'C:\\mprogs\\my_ascii_file.txt';
   save_xye(w_in,filename);


The format of the ascii file for an n-dimensional dataset is n columns of co-ordinates along each of the axes, plus one
column of signal and another column of error (standard deviation).


hkle
====

Obtain the reciprocal space coordinate [h,k,l,e] for points in the coordinates of the display axes for an sqw object
**from a single spe file**

.. code-block:: matlab

    [qe1,qe2] = hkle(w,x)


The inputs take the form:

* ``w``

  sqw object

* ``x``

  Vector of coordinates in the display axes of an sqw object. The number of coordinates must match the dimensionality of
  the object. e.g. for a 2D sqw object, ``x = [x1,x2]``, where ``x1``, ``x2`` are column vectors. More than one point can
  be provided by giving more rows e.g. ``[1.2,4.3; 1.1,5.4; 1.32, 6.7]`` for 3 points from a 2D object. Generally, an
  (``n`` x ``nd``) array, where ``n`` is the number of points, and ``nd`` the dimensionality of the object.

The outputs take the form:


* ``qe1``

  Components of momentum (in rlu) and energy for each bin in the dataset. Generally, will be (n x 4) array, where n is the number of points

* ``qe2``

  For the second root
