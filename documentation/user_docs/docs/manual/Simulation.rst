##########
Simulation
##########

There are a variety of simulation tools available in Horace, so that if you have a theoretical model to describe your data you can simulate the results for the specific data points that you measured.

**IMPORTANT** When simulating an S(Q,w) model (see sqw_eval below), bear in mind the difference between what is calculated for equivalent dnd and sqw datasets. See :ref:`FAQ <manual/FAQ:FAQ>`.

func_eval
=========

This evaluates a user-supplied function at the x, y, z, ... values of an n-dimensional dataset, or array of datasets. The syntax is as follows:

::

   wout = func_eval(win, @myfunc, p);
   wout = func_eval(win, @myfunc, p, 'all');

- ``win`` is the input dataset or array of datasets (sqw or dnd type) for which you wish to perform a simulation.

- ``myfunc`` is the name of a user-defined function to calculate the intensity at the points in the dataset(s). The function must be of the form ``y = mfunc(x1, x2, ..., xn, p)``, e.g. ``y = gauss2d(x1, x2, [amplitude, centre1, centre2, width1, width2, background])`` and accept equal sized arrays that contain the x1, x2, ... values. ``p`` can be a row-vector containing the parameters needed by the function.

The optional keyword ``'all'`` is used if you wish to calculate the intensity from the function over the whole domain covered by the input dataset. In other words, your dataset may contain gaps due to the trajectory of the detectors through reciprocal space, but you may wish to simulate the scattering even in the gaps. This option applies in the case of dnd objects, but not sqw objects.

sqw_eval
========

::

   wout = sqw_eval(win, @my_sqw_func, p);
   wout = sqw_eval(win, @my_sqw_func, p, 'all');


The syntax for ``sqw_eval`` is almost identical to that of ``func_eval``. The only difference is the form of the function required ``my_sqw_func``, which **must** be of the form

::

   weight = my_sqw_func(qh, qk, ql, en, p)


where ``qh, qk, ql, en`` area arrays that contain the co-ordinates in h, k, l and energy of every point in the dataset, irrespective of the dimensionality of that dataset. As before, ``p`` is a row-vector containing the parameters required by the function. These could be the values of exchange constants, intensity scale factor, or temperature, for example.

One would generally use ``sqw_eval`` in preference to ``func_eval`` if, for example, one had a model of the spin-wave cross-section for magnetic scattering.

dispersion
==========

Calculate dispersion relation for dataset or array of datasets.

::

   wdisp = dispersion (win, dispreln, p)            % dispersion only

   [wdisp,weight] = dispersion (win, dispreln, p)   % dispersion and spectral weight


The output dataset (or array of data sets), ``wdisp``, will retain only the Q axes, and the signal array(s) will contain the values of energy along the Q axes. If the dispersion relation returns the spectral weight, this will be placed in the error array (actually the square of the spectral weight is put in the error array). In the case when the dispersion has been calculated on a plane in momentum (i.e. wdisp is IX_datset_2d) then the plot function

``ds2`` (for draw surface from two arrays)

::

   ds2(wdisp)


will plot a surface with the z axis as energy and coloured according to the spectral weight.

**If you wish to overplot a dispersion relation on top of, for example, a Q-E slice from your data, then you would use:**

::

   plot(my_qe_slice)

   ploc(wdisp)       % for plot line on current


Note that in the above there must not be a *keep* command between plotting the Q-E slice and plotting the dispersion, since the ``ploc`` command works on the *current* figure.

The dispersion relation is calculated at the bin centres (that is, the individual pixel information in a sqw input object is not used).

If the function that calculates dispersion relations produces more than one branch (i.e. the output of ``dispreln`` is a cell array of arrays), then in the case of a single input dataset the output will be an array of datasets, one for each branch. If the input is an array of datasets, then only the first dispersion branch will be returned, so there is one output dataset per input dataset.

Input:

- ``win`` Dataset (or array of datasets) that provides the axes and points for the calculation. If one of the plot axes is energy transfer, then the output dataset will have dimensionality one less than the input dataset.

- ``dispreln`` Handle to function that calculates the dispersion relation w(Q). Must have form:
- ``w = dispreln (qh,qk,ql,p)``, or ``[w,s] = dispreln (qh,qk,ql,p)``

where

- ``qh,qk,ql`` Arrays containing the coordinates of a set of points in reciprocal lattice units

- ``p`` Vector of parameters needed by dispersion function , e.g. [A,js,gam] as intensity, exchange, lifetime

- ``w`` Array of corresponding energies, or, if more than one dispersion relation, a cell array of arrays.

- ``s`` Array of corresponding spectral weights, or, if more than one dispersion relation, a cell array of arrays.

The more general form is: ``w = dispreln (qh,qk,ql,p,c1,c2,..)``, or ``[w,s] = dispreln (qh,qk,ql,p,c1,c2,..)``

where

- ``p`` Typically a vector of parameters that we might want to fit in a least-squares algorithm

- ``c1,c2,...`` Other constant parameters e.g. file name for look-up table

- ``p`` Arguments needed by the function that calculates the dispersion relation(s). Most commonly, a vector of parameter values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general set of parameters is required by the dispersion relation function, then package these into a cell array {p, c1, c2, ...}.

The output is:

- ``wdisp`` Output dataset or array of datasets. Output is always dnd-type. The output dataset (or array of data sets) will retain only the Q axes, the the signal array(s) will contain the values of energy along the Q axes, and the error array will contain the square of the spectral weight. If the function that calculates dispersion relations produces more than one branch, then in the case of a single input dataset the output will be an array of datasets, one for each branch. If the input is an array of datasets, then only the first dispersion branch will be returned, so there is one output dataset per input dataset.

- ``weight`` Mirror output: the signal is the spectral weight, and the error array contains the square of the frequency.

e.g. If ``win`` is a 2D dataset with Q and E axes, then ``wdisp`` is a 1D dataset with just the Q axis

disp2sqw_eval
=============

Similar to ``sqw_eval``, but takes as the input function a routine that calculates both the dispersion and the spectral weight, and only requires as its inputs h, k, l and some model parameters.

::

   wout = disp2sqw_eval(win,@dispreln,pars,fwhh,<Optional input parameters>)


- ``win`` is the input dataset (sqw or dnd) or array of datasets

- ``dispreln`` is a function of the form ``[w,s] = dispreln (qh,qk,ql,p)``, or more generally ``[w,s] = dispreln (qh,qk,ql,p,c1,c2,..)``, where in addition to the coordinates ``qh, qk, ql`` and model input parameters ``p``, some extra information contained in the data structures (cell arrays, vectors, structure arrays, etc) ``c1, c2, ...`` is supplied. The outputs ``w`` and ``s`` are the dispersion and spectral weight respectively. These are cell arrays of arrays if there is more than one branch of the dispersion.

- ``pars`` is the input parameters to the function. If this is just ``p`` then ``pars = p``, but if extra parameters are required then ``pars = {p, c1, c2, ...}``, i.e. ``pars`` is a cell array.

- ``fwhh`` is the full-width half-height of Gaussian broadening applied to dispersion relation.

The optional inputs are:

- ``'all'`` - Requests that the calculated sqw be returned over the whole of the domain of the input dataset. If not given, then the function will be returned only at those points of the dataset that contain data. Applies only to input with no pixel information - it is ignored if full sqw object.

- ``'ave'`` - Requests that the calculated sqw be computed for the average values of h,k,l of the pixels in a bin, not for each pixel individually. Reduces cost of expensive calculations. Applies only to the case of sqw object with pixel information - it is ignored if dnd type object.

The output is:

- ``wout`` - Output dataset or array of datasets

dispersion_plot
===============

Plot dispersion relation or array of dispersion relations along a path in reciprocal space. It can be called in the following ways, with or without outputs, as below:

::

   dispersion_plot(rlp,@dispreln,pars)

   dispersion_plot(lattice,rlp,@dispreln,pars)

   dispersion_plot(...,'dispersion') % plot dispersion only

   dispersion_plot(...,'weight') % plot spectral weight only

   dispersion_plot(...,'labels',{'G','X',...})  % customised labels at the positions of the rlp

   dispersion_plot(...,'ndiv',n)   % plot with number of points per interval other than the default

   [wdisp,weight]=dispersion_plot(...)  % output arrays of IX_dataset_1d with dispersion and spectral weight

   [wdisp,weight]=dispersion_plot(...,'noplot') % output arrays without plotting


The inputs are as follows:

- ``lattice`` [optional] Lattice parameters [a,b,c,alpha,beta,gamma] (Angstrom, degrees). Default is [2*pi,2*pi,2pi,90,90,90]

- ``rlp`` Array of reciprocal lattice points, e.g. [0,0,0; 0,0,1; 0,-1,1; 1,-1,1; 1,0,1; 1,0,0];

- ``@dispreln`` Handle to a Matlab function ``dispreln``) that calculates the dispersion relation w(Q) and spectral weight, S(Q).

The most commonly used form is:

- ``[w,s] = dispreln (qh,qk,ql,p)``

where,

- ``qh,qk,ql`` Arrays containing the coordinates of a set of points in reciprocal lattice units

- ``p`` Vector of parameters needed by dispersion function e.g. [A,js,gam] as intensity, exchange, lifetime

- ``w`` Array of corresponding energies, or, if more than one dispersion relation, a cell array of arrays.

- ``s`` Array of spectral weights, or, if more than one dispersion relation, a cell array of arrays.

The more general form is:

- ``[w,s] = dispreln (qh,qk,ql,p,c1,c2,..)``

where,

- ``p`` Typically a vector of parameters that we might want to fit in a least-squares algorithm

- ``c1,c2,...`` Other constant parameters e.g. file name for look-up table.

- ``pars`` Arguments needed by the function that calculates the dispersion relation. Most commonly, a vector of parameter values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general set of parameters is required by the function, then package these into a cell array and pass that as pars. In the example above then pars = {p, c1, c2, ...}


The keyword options (which can be abbreviated to single letter) are:

- ``'dispersion'`` Only plot the dispersion relation(s). The default is to plot and/or return dispersion, and weight if available

- ``'weight'`` Only plot the spectral weight(s). The default is to plot and/or return dispersion, and weight if available

- ``'labels'`` Tick labels to place at the positions of the Q points in argument rlp. e.g. {'G','X','M','R'}. By default the labels are character representations of rlp, e.g. {0,0,0; 0.5,0,0; 0.5,0.5,0; 0.5,0.5,0.5} becomes {'0,0,0', '0.5,0,0', '0.5,0.5,0', '0.5,0.5,0.5'}

- ``'ndiv'`` \\tNumber of points into which to divide the interval between two r.l.p. (default=100)

- ``'noplot'`` Do not plot, just return the output IX_dataset_1d (see below)


The outputs are as follows

- ``wdisp`` Array of IX_dataset_1d containing dispersion, one per dispersion relation. The x-axis is the distance in Ang^-1 along the path described

- ``weight`` Array of IX_dataset_1d with corresponding spectral weight, one per dispersion relation

disp2sqw_plot
=============

Generate an Q-E intensity plot for a dispersion relation along a path in reciprocal space. The function is very closely related to ``dispersion_plot``), and most of the input arguments and options are the same for the two functions.

::

   disp2sqw_plot(rlp,@dispreln,pars,ebins,fwhh)

   disp2sqw_plot(lattice,rlp,@dispreln,pars,ebins,fwhh)

   disp2sqw_plot(...,'labels',{'G','X',...})  % customised labels at the positions of the rlp

   disp2sqw_plot(...,'ndiv',n)   % plot with number of points per interval other than the default

   weight=disp2sqw_plot(...)  % output IX_dataset_2d with spectral weight

   weight=disp2sqw_plot(...,'noplot') % output array without plotting


The inputs are as follows:

- ``lattice`` [optional] Lattice parameters [a,b,c,alpha,beta,gamma] (Angstrom, degrees). Default is [2*pi,2*pi,2pi,90,90,90]

- ``rlp`` Array of reciprocal lattice points, e.g. [0,0,0; 0,0,1; 0,-1,1; 1,-1,1; 1,0,1; 1,0,0];

- ``@dispreln`` Handle to a Matlab function ``dispreln``) that calculates the dispersion relation w(Q) and spectral weight, S(Q).

The most commonly used form is:

- ``[w,s] = dispreln (qh,qk,ql,p)``

where,

- ``qh,qk,ql`` Arrays containing the coordinates of a set of points in reciprocal lattice units

- ``p`` Vector of parameters needed by dispersion function e.g. [A,js,gam] as intensity, exchange, lifetime

- ``w`` Array of corresponding energies, or, if more than one dispersion relation, a cell array of arrays.

- ``s`` Array of spectral weights, or, if more than one dispersion relation, a cell array of arrays.

The more general form is:

- ``[w,s] = dispreln (qh,qk,ql,p,c1,c2,..)``

where,

- ``p`` Typically a vector of parameters that we might want to fit in a least-squares algorithm

- ``c1,c2,...`` Other constant parameters e.g. file name for look-up table.

- ``pars`` Arguments needed by the function that calculates the dispersion relation. Most commonly, a vector of parameter values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general set of parameters is required by the function, then package these into a cell array and pass that as pars. In the example above then pars = {p, c1, c2, ...}

- ``ebins`` Defines the energy bin centres: a three-vector [ecentre_lo, bin_width, ecentre_hi]

- ``fwhh`` Full width half height of broadening applied to the dispersion to produce the intensity map

The keyword options (which can be abbreviated to single letter) are:

- ``'labels'`` Tick labels to place at the positions of the Q points in argument rlp. e.g. {'G','X','M','R'}. By default the labels are character representations of rlp, e.g. {0,0,0; 0.5,0,0; 0.5,0.5,0; 0.5,0.5,0.5} becomes {'0,0,0', '0.5,0,0', '0.5,0.5,0', '0.5,0.5,0.5'}

- ``'ndiv'`` \\tNumber of points into which to divide the interval between two r.l.p. (default=100)

- ``'noplot'`` Do not plot, just return the output IX_dataset_1d (see below)


The output is as follows:

- ``weight`` IX_dataset_2d containing the spectra weight. The x-axis is the distance in Ang^-1 along the path described

The image intensity, as the function of **Q** along the rlp path alonx x-axis and the energy transfer along y-axis is determined by the equation:

::

   weight(energy)= sfact.*exp(-(w(**Q**,\ **p**)-energy).^2/(2*sig.^2))./(sig*sqrt(2*pi));


where

::

   sig = fwhh/sqrt(log(256));
