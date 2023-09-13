##########
Simulation
##########

There are a variety of simulation tools available in Horace, so that if you have
a theoretical model to describe your data you can simulate the results for the
specific data points that you measured.

.. note::

   When simulating an S(Q,w) model (see sqw_eval below), bear in mind the
   difference between what is calculated for equivalent ``dnd`` and ``sqw``
   datasets. See :ref:`FAQ <manual/FAQ:FAQ>`.

func_eval
=========

This evaluates a user-supplied function at the x, y, z, ... values of an
n-dimensional dataset, or array of datasets. The syntax is as follows:

.. code-block:: matlab

   wout = func_eval(win, @myfunc, p);
   wout = func_eval(win, @myfunc, p, 'all');

- ``win`` is the input dataset or array of datasets (sqw or dnd type) for which
  you wish to perform a simulation.

- ``myfunc`` is the name of a user-defined function to calculate the intensity
  at the points in the dataset(s).

.. warning::

   The function must be of the form

   .. code-block:: matlab

      y = mfunc(x1, x2, .., xn, p)

   e.g.

   .. code-block:: matlab

      y = gauss2d(x1, x2, [amplitude, centre1, centre2, width1, width2, background])

   and accept equal sized arrays that contain the x1, x2, ... values.

- ``p`` should be a row-vector containing the parameters needed by the function.

- ``'all'`` is used if you wish to calculate the intensity from the function
  over the whole domain covered by the input dataset. In other words, your
  dataset may contain gaps due to the trajectory of the detectors through
  reciprocal space, but you may wish to simulate the scattering even in the
  gaps. This option applies in the case of dnd objects, but not sqw objects.

sqw_eval
========

.. code-block:: matlab

   wout = sqw_eval(win, @my_sqw_func, p);
   wout = sqw_eval(win, @my_sqw_func, p, 'all');

The syntax for ``sqw_eval`` is almost identical to that of ``func_eval``. The
only difference is the form of the function required ``my_sqw_func``,

.. warning::

   The function supplied to ``sqw_eval`` must be of the form:

   .. code-block:: matlab

      weight = my_sqw_func(qh, qk, ql, en, p)

   where ``qh, qk, ql, en`` are arrays that contain the co-ordinates in
   :math:`h, k, l` and energy of each point in the dataset, irrespective of the
   dimensionality of the representative ``dnd``.

- ``p`` is a row-vector containing the parameters required by the
  function.

.. note::

   These could be the values of exchange constants, intensity scale factor, or
   temperature, for example.

One would generally use ``sqw_eval`` in preference to ``func_eval`` if, for
example, one had a model of the spin-wave cross-section for magnetic scattering.

dispersion
==========

Calculate dispersion relation for dataset or array of datasets.

.. code-block:: matlab

   [wdisp,weight] = dispersion(win, dispreln, p)   % dispersion and spectral weight

The output dataset (or array of data sets), ``wdisp``, will retain only the Q
axes, and the signal array(s) will contain the values of energy along the Q
axes. If the dispersion relation returns the spectral weight, this will be
placed in the error array (actually the square of the spectral weight is put in
the error array).

.. note::

   The dispersion relation is calculated at the bin centres, i.e. the
   individual pixel information in an ``sqw`` object is not used.

Inputs:

- ``win`` - Dataset (or array of datasets) that provides the axes and points for
  the calculation. If one of the plot axes is energy transfer, then the output
  dataset will have dimensionality one less than the input dataset.

- ``dispreln`` - Handle to function that calculates the dispersion relation
  w(Q) and spectral weight, S(Q).


- ``p`` Arguments needed by the function that calculates the dispersion
  relation(s). Most commonly, a vector of parameter values e.g. ``[A, js, gam]``
  as intensity, exchange, lifetime. If a more general set of parameters is
  required by the dispersion relation function, then package these into a cell
  array ``{p, c1, c2, ...}``.

.. _dispreln:

.. warning::

   The function ``dispreln`` must be of the form:

   .. code-block:: matlab

      [w, s] = dispreln(qh, qk, ql, p, c1, c2, ..)

   where the inputs are:

   - ``qh, qk, ql`` - Arrays containing the coordinates of a set of points in
     reciprocal lattice units

   - ``p`` - Vector of parameters needed by dispersion function, e.g.
     ``[A, js, gam]`` as intensity, exchange, lifetime

   - ``c1, c2, ...`` **[Optional]** - Other constant parameters e.g. file name
     for look-up table

   and the outputs are:

   - ``w`` - Array of corresponding energies, or, if more than one dispersion
     relation, a cell array of arrays.

   - ``s`` **[Optional]** - Array of corresponding spectral weights, or, if more
     than one dispersion relation, a cell array of arrays.

Outputs:

- ``wdisp`` Output dataset or array of datasets. Output is always a ``dnd``. The
  output dataset (or array of data sets) will retain only the Q axes, the the
  signal array(s) will contain the values of energy along the Q axes, and the
  error array will contain the square of the spectral weight.

.. warning::

  If the function that calculates dispersion relations produces more than one
  branch, then in the case of a single input dataset the output will be an array
  of datasets, one for each branch.

  If the input is an array of datasets, then only the first dispersion branch
  will be returned, so there is one output dataset per input dataset.

- ``weight`` Mirror output: the signal is the spectral weight, and the error
  array contains the square of the frequency.

.. note::

   If ``win`` is a 2D dataset with Q and E axes, then ``wdisp`` is a 1D
   dataset with just the Q axis


.. note::

   In the case when the dispersion has been calculated on a plane in momentum
   space (i.e. ``wdisp`` is an ``IX_dataset_2d`` object) then the plot function
   ``ds2`` (draw surface from two arrays)

   .. code-block:: matlab

      ds2(wdisp)


   will plot a surface with the z axis as energy, coloured according to the
   spectral weight.

   If you wish to overplot a dispersion relation on top of, for example, a Q-E
   slice from your data, then you would use:

   .. code-block:: matlab

      plot(my_qe_slice)

      ploc(wdisp)       % for plot line on current


   .. warning::

      In the above there must not be a ``keep_figure`` command between plotting the Q-E
      slice and plotting the dispersion, since the ``ploc`` command works on the
      current figure.


disp2sqw_eval
=============

Similar to ``sqw_eval``, but takes as the input function a routine that
calculates both the dispersion and the spectral weight, and only requires as its
inputs :math:`h, k, l` and some model parameters.

.. code-block:: matlab

   wout = disp2sqw_eval(win, @dispreln, pars, fwhh, 'all', 'ave')

- ``win`` - the input dataset (``sqw`` or ``dnd``) or array of datasets

- ``dispreln`` - Handle to function that calculates the dispersion relation
  w(Q) and spectral weight, S(Q).

- ``p`` - Vector of parameters needed by dispersion function, e.g.
  ``[A, js, gam]`` as intensity, exchange, lifetime

- ``fwhh`` - the full-width half-height of Gaussian broadening applied to
  dispersion relation.

.. warning::

   The function ``dispreln`` must be of the form as `specified above <dispreln_>`_

The optional inputs are:

- ``'all'`` **[Optional]** - Requests that the calculated sqw be returned over
  the whole of the domain of the input dataset. If not given, then the function
  will be returned only at those points of the dataset that contain
  data. Applies only to input with no pixel information - it is ignored if full
  ``sqw`` object.

- ``'ave'`` **[Optional]** - Requests that the calculated sqw be computed for
  the average values of :math:`h, k, l` of the pixels in a bin, not for each
  pixel individually. Reduces cost of expensive calculations. Applies only to
  the case of sqw object with pixel information - it is ignored if ``dnd``
  object.

The output is:

- ``wout`` - Output dataset or array of datasets

dispersion_plot
===============

Plot dispersion relation or array of dispersion relations along a path in
reciprocal space. It can be called in the following ways, with or without
outputs, as below:

.. code-block:: matlab

   [wdisp, weight] = dispersion_plot(lattice, rlp, dispreln, pars, 'dispersion', 'weight' ...
                                     'labels', {'G', 'X', ..}, 'ndiv', n, 'noplot')


The inputs are as follows:

- ``lattice`` **[Optional]** - Lattice parameters :math:`[a,b,c,\alpha,\beta,\gamma]`
  (Angstrom, degrees). Default is :math:`[2\pi,2\pi,2\pi,90,90,90]`

- ``rlp`` - Array of reciprocal lattice points, e.g.

  ::

     [0, 0,0;
      0, 0,1;
      0,-1,1;
      1,-1,1;
      1, 0,1;
      1, 0,0];

- ``dispreln`` - Handle to function that calculates the dispersion relation
  w(Q) and spectral weight, S(Q).

.. warning::

   The function ``dispreln`` must be of the form as `specified above <dispreln_>`_

The keyword options are:

- ``'dispersion'`` **[Optional]** - Only plot the dispersion relations. The
  default is to plot and/or return dispersion, and weight if available

- ``'weight'`` **[Optional]** - Only plot the spectral weights. The default is
  to plot and/or return dispersion, and weight if available

- ``'labels'`` **[Optional]** - Tick labels to place at the positions of the Q
  points in argument rlp. e.g. ``{'G', 'X', 'M', 'R'}``. By default the labels
  are character representations of rlp, e.g. ``{0, 0, 0; 0.5, 0, 0; 0.5, 0.5, 0;
  0.5, 0.5, 0.5}`` becomes ``{'0, 0, 0', '0.5, 0, 0', '0.5, 0.5, 0', '0.5, 0.5,
  0.5'}``

- ``'ndiv', N`` **[Optional]** - Number of points into which to divide the
  interval between two r.l.p. (default=100)

- ``'noplot'``  **[Optional]** - Do not plot, just return the output ``IX_dataset_1d``

The outputs are as follows

- ``wdisp`` **[Optional]** - Array of ``IX_dataset_1d`` containing dispersion,
  one per dispersion relation. The x-axis is the distance in Ang^-1 along the
  path described

- ``weight`` **[Optional]** - Array of ``IX_dataset_1d`` with corresponding
  spectral weight, one per dispersion relation

disp2sqw_plot
=============

Generate an Q-E intensity plot for a dispersion relation along a path in
reciprocal space. The function is very closely related to `dispersion_plot <dispersion_plot_>`_,
and most of the input arguments and options are the same for the two functions.

.. code-block:: matlab

   weight = disp2sqw_plot(lattice, rlp, dispreln, pars, ebins, fwhh, 'labels', {'G', 'X', ..}, 'noplot')

The inputs are as follows:

- ``lattice`` **[Optional]** - Lattice parameters :math:`[a, b, c, \alpha, \beta, \gamma]`
  (Angstrom, degrees). Default is :math:`[2\pi, 2\pi, 2\pi, 90, 90, 90]`

- ``rlp`` - Array of reciprocal lattice points, e.g.

  ::

     [0, 0,0;
      0, 0,1;
      0,-1,1;
      1,-1,1;
      1, 0,1;
      1, 0,0];

- ``dispreln`` - Handle to function that calculates the dispersion relation
  w(Q) and spectral weight, S(Q).

.. warning::

   The function ``dispreln`` must be of the form as `specified above <dispreln_>`_

- ``ebins`` - Defines the energy bin centres: a three-vector
  ``[ecentre_lo, bin_width, ecentre_hi]``

- ``fwhh`` - Full width half height of broadening applied to the dispersion to
  produce the intensity map

The keyword options (which can be abbreviated to single letter) are:

- ``'labels'`` **[Optional]** - Tick labels to place at the positions of the Q points in argument
  rlp. e.g. ``{'G', 'X', 'M', 'R'}``. By default the labels are character
  representations of rlp, e.g. ``{0, 0, 0; 0.5, 0, 0; 0.5, 0.5, 0; 0.5, 0.5, 0.5}`` becomes
  ``{'0, 0, 0', '0.5, 0, 0', '0.5, 0.5, 0', '0.5, 0.5, 0.5'}``

- ``'ndiv', N`` **[Optional]** - Number of points into which to divide the interval between two
  r.l.p. (default=100)

- ``'noplot'`` **[Optional]** - Do not plot, just return the output IX_dataset_1d (see below)


The output is as follows:

- ``weight`` **[Optional]** - ``IX_dataset_2d`` containing the spectral weights. The x-axis is the
  distance in Ang^-1 along the path described.

The image intensity, as a function of **Q** along the r.l.p path along the x-axis
and the energy transfer along y-axis is determined by the equation:

.. math::

   weight(\mathbf{Q}, E) = \frac{S}{\sigma\sqrt{2\pi}} \exp\left[ \frac{ - \left( w(\mathbf{Q}, \{p\}) - E \right)^{2}}{2\sigma{}^{2}} \right]

..
   .. code-block:: matlab

      weight(energy) = sfact.*exp(-(w(Q, p)-energy).^2/(2*sig.^2))./(sig*sqrt(2*pi));


where :math:`w` is the dispersion relation function ``dispreln``, :math:`\{p\}` are the parameters given in ``p``, :math:`E` is the energy and

.. math::

   \sigma{} = \frac{\textrm{fwhh}}{\sqrt{\log(256)}}

..
   .. code-block:: matlab

      sig = fwhh/sqrt(log(256));
