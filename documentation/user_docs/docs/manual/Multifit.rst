########
Multifit
########

.. |SQW| replace:: :math:`S(\mathbf{Q}, \omega)`

Horace comes with a rich and powerful fitting syntax that is common to the
methods used to fit functions or models of |SQW| to one or more datasets.

..
   The documentation here is only meant to give an introduction and overview. For the
   full help, please use the Matlab documentation for the various fitting functions that can be obtained by using the
   ``doc`` command, for example ``doc d1d/multifit`` (for fitting function like Gaussians to ``d1d`` objects) or ``doc
   sqw/multifit_sqw`` (fitting models for |SQW| to ``sqw`` objects). It is strongly recommended that you use ``doc``, not
   ``help`` to explore how to use these methods, so that you can navigate between the numerous pages of documentation in
   the Matlab help window.

Overview
========

Horace provides a set of methods for fitting ``sqw`` and ``d1d``, ``d2d``,
``d3d`` & ``d4d`` objects, which all share the same fitting syntax and
capabilities. The various forms of multifit enable you to:

- fit a function to single dataset

  For example, fitting a Gaussian function to a single one-dimensional dataset

- fit a function with a global set of parameters to several datasets
  simultaneously

  For example, fitting a model for |SQW| from spin waves to several
  function ``sqw`` objects to determine the global intensity scale and magnetic
  exchange constants that best fit the set of data

- fit a global foreground function with local background functions

  For example, in the previous illustration, allowing an independent linear
  background for each ``sqw`` dataset, or even different functional forms for
  the background for different datasets

- fix one or more parameters in the foreground functions and background
  functions
- bind the values of pairs of parameters so that they vary in a fixed ratio in
  the fit

The last functionality can be very useful if you have a model for |SQW|
where you want to have parameters that apply globally (for example, magnetic
exchange constants that define spin wave dispersion) but other parameters that
can vary independently for each dataset (for example, the spin wave lifetime)
. In this instance, you can define the foreground function to be local, then
bind the exchange constants across all datasets with ratio unity.

The following multifit variants are available for ``sqw`` and ``d1d``, ``d2d``,
``d3d`` & ``d4d`` objects:

- ``multifit_func`` (or equivalently ``multifit``)

  The foreground and background functions both are functions of the plot axes
  x1, x2, ...

- ``multifit_sqw``

  The foreground function(s) are functions of |SQW|, and the background
  functions are functions of the plot axes x1, x2, ...

- ``multifit_sqw_sqw``

  The foreground and background function(s) are all functions of |SQW|


Introduction to setting up and performing a fit
===============================================

All the variants of multifit share a common procedure for setting up and
performing a fit - they differ only in the form of the functions, which are
either functions of the plot coordinates or qh, qk, ql, en. In what follows we
refer to ``multifit``, but the same information is true for ``multifit_func``,
``multifit_sqw``, ``multifit_sqw``, and ``tobyfit``.


Simple fitting
**************

First you have to create a multifit object with the data you want to fit. You
can give it any name you like - here we'll use the name ``kk``

::

   >> kk = multifit(w1);   % w1 is an object (or array of objects) to be fitted


::

   >> kk = multifit(w1, w2, w3, w4);   % several (arrays of) objects to be fitted simultaneously


Next you need to set the fitting functions. In this case, let us assume that you
are fitting an array of three objects and that you are going to fit Gaussian
functions to all three objects simultaneously:

::

   >> kk = multifit (my_data);
   >> kk = kk.set_fun (@gauss);


In the Horace installation there is a folder
(``herbert_core\applications\mfit_funcs``) with a selection of fitting
functions, including ``gauss.m``. A fit function requires a particular set of
input and output arguments (see :ref:`Fitting functions <manual/Multifit:Fitting
functions>`).

Now we need to provide the starting parameters for the fit. This is a row vector
of the numerical values for the parameters, which in the case of ``gauss`` is
the height, position and standard deviation:

::

   >> kk = kk.set_pin([100, 0, 10]); % height 100, centred on 0, standard deviation 10


By default, multifit will allow all these parameters to float freely in the
fit. However, suppose you want to keep the Gaussian centred on the origin. Then
you can provide a list of which parameters are allowed to float (1) or are fixed
(0). In this example:

::

   >> kk = kk.set_free([1, 0, 1]); % keep the second parameter fixed in the fit

At this point, you can perform a fit:

::

   >> [my_fitted_data, fit_params] = kk.fit();


This returns two arguments: ``my_fitted_data`` is an array of objects which is
the same shape and types as the input data, where that the signal (or
equivalently, the intensity) is set to the calculated values at the final fitted
parameter values; and ``fit_params``, which is a structure that contains the
fitted parameter values, estimated errors on those fitted values, the value of
chi-squared for the fit and the covariance matrix of the fitted parameters.

If you want to see how the fit is progressing from one iteration to the next,
and also get a listing in the Matlab command window of the final fit parameters,
you can ask for more verbose output by changing one of the multifit options:

::

   >> kk = kk.set_options('list', 2); % prints highly verbose output to the screen


Other options change the fit convergence criteria, and whether or not the final
fit is calculated only for data points that remained once points with zero error
bars were removed or for all data points.

Fitting can be computationally very expensive. Before you start fitting, it can
be very useful to simulate at the initial parameters to see if your starting
point close to expected final values, it can be helpful to check visually using
simulate:

::

   >> [my_fitted_data, fit_params] = kk.simulate();


Background functions
********************

One of the nice features of multifit is that as well as fitting a global
function (the 'foreground') function to all your datsets, you can define local
'background' functions, that is functions whose parameters vary independently
for each dataset. This can be useful, for example, if you have a model for
|SQW| which should apply to all your datasets, but you need to have a
linear background that is independent for each dataset. We continue with our
example of an array of three datasets which we set up above; to recap:

::

   >> kk = multifit (my_data);
   >> kk = kk.set_fun (@gauss);
   >> kk = kk.set_pin ([100, 0, 10]);
   >> kk = kk.set_free ([1, 0, 1]);


Now let us add an independent linear background for each of the three datasets:

::

   >> kk = kk.set_bfun (@linear_bg); % set_bfun sets the background functions
   >> kk = kk.set_bpin ([5.5, 0]);   % initial background constant and gradient
   >> kk = kk.set_bfree ([1, 0]);    % fix the backgroun gradient


Even though only one background function was given in the example above, the
default is assume that it applies locally. That is, multifit will assume that we
want an independent linear background for each dataset. The same is true of the
initial parameter values and the free/fixed parameters.

If you wanted to have different initial starting parameters for each of the
linear backgrounds, you should provide a cell array of row vectors, one per
dataset:

::

   >> kk = kk.set_bpin ({[5.5, 0]}, [3, 0], [1.2, 0]);


Similarly, if you wanted to fit a linear background to the first two datasets
and a quadratic background to the to the third then you should provide a cell
array of function handles, one per dataset. Note that three parameters are
required for a quadratic background, so you need to give a cell array of
starting values as well.

::

   >> kk = kk.set_fun ({@linear_bg, @linear_bg, @quad_bg});
   >> kk = kk.set_bpin ({[5.5, 0]}, [3, 0], [1.2, 0, 0]);


Binding parameters
******************

You can bind parameters together so that they are always in a fixed ratio. For
example if you wanted the height to always be ten times the standard deviation
of the Gaussian, you set a binding descriptor, which is a cell array that gives
in sequence the bound parameter, the free parameter, and the ratio of the bound
to free parameter:

::

   >> kk = kk.set_bind ({1, 3, 10});


This is a particular case of a binding descriptor. More generally, you need to
give the parameter index and the function index for each of the bound and free
parameters. The general syntax of a binding descriptor is:

::

   {[ipar_bound, ifun_bound], [ipar_free, ifun_free], ratio}


You can also give more than one binding in one command, by providing a cell
array of binding descriptors. For example, if you want to bind the linear
background constants together in the example above:

::

   >> kk = kk.set_bbind ({[1, 2], [1, 1], 1}, {[1, 3], [1, 1], 1});


Various defaults apply if you abbreviate the descriptor. For example, if you
don't give the parameter ratio, then multifit will assume the value determined
by the initial parameter values in ``set_pin`` and ``set_bpin``. If you don't give
the bound function index then it is assumed that you mean that the binding
applies for all functions of that type (i.e. the type being foreground or
background functions). The syntax enables complex bindings to be created in
quite a succinct form, and you should navigate to the help for ``set_bind``
(foreground function bindings) and ``set_bbind`` (background function bindings)
from ``doc sqw/multifit``. You can also accumulate bindings to ones you've
already set using ``add_bind`` and ``add_bbind``.


Semi-global fits
****************

So far we've seen how to have a global 'foreground' function that applies to all
datasets (a Gaussian in the above, but it could be a model for |SQW|)
together with independent 'background' functions for each dataset. A commonly
encountered requirement is to have a model for the foreground where some
parameters are global and other are local - for example a single exchange
constant in a model for spin waves but independent intensities and inverse
lifetimes. To achieve this you can set the background model to be local rather
than global, just as teh default is for the background functions. Then you can
use binding s to link a parameter across all datasets. For example, returning to
our Gaussian foreground model, if we want the position constrained to be the
same (but not necessarily zero) for all datasets, but the height and standard
deviation allowed to be different:

::

   >> kk = multifit (my_data);
   >> kk = kk.set_local_foreground;    % override the default
   >> kk = kk.set_fun (@gauss);        % sets every function to be Gaussian
   >> kk = kk.set_pin ([100, 0, 10]);  % same initial parameter for all functions
   >> kk = kk.set_bind ({2, [2, 1]});  % bind parameter 2 of all functions


The syntax of the last function means that parameter 2 of all foreground
functions is bound to parmaeter 2 of the first function. The ratio will be unity
because they were all initialised to the same value.

Summary of commands with multifit
=================================

The command set and the inputs they take is considerably richer than the taster
that has been given above. The ``multifit`` help in Matlab that you invoke by
typing ``doc sqw/multifit`` (and any of the variants for ``d1d``, ``d2d``,
... objects, and ``multifit_func``, ``multifit_sqw``, ``multifit_sqw_sqw``) is
the gateway to discovering more about the commands and links to example fitting
functions. The summary of the commands is as follows:

To set data:

::

   set_data     - Set data, clearing any existing datasets
   append_data  - Append further datasets to the current set of datasets
   remove_data  - Remove one or more dataset(s)
   replace_data - Replace one or more dataset(s)


To mask data points:

::

   set_mask     - Mask data points
   add_mask     - Mask additional data points
   clear_mask   - Clear masking for one or more dataset(s)


To set fitting functions:

::

   set_fun      - Set foreground fit functions
   clear_fun    - Clear one or more foreground fit functions

   set_bfun     - Set background fit functions
   clear_bfun   - Clear one or more background fit functions


To set initial function parameter values:

::

   set_pin      - Set foreground fit function parameters
   clear_pin    - Clear parameters for one or more foreground fit functions

   set_bpin     - Set background fit function parameters
   clear_bpin   - Clear parameters for one or more background fit functions


To set which parameters are fixed or free:

::

   set_free     - Set free or fix foreground function parameters
   clear_free   - Clear all foreground parameters to be free for one or more data sets

   set_bfree    - Set free or fix background function parameters
   clear_bfree  - Clear all background parameters to be free for one or more data sets


To bind parameters:

::

   set_bind     - Bind foreground parameter values in fixed ratios
   add_bind     - Add further foreground function bindings
   clear_bind   - Clear parameter bindings for one or more foreground functions

   set_bbind    - Bind background parameter values in fixed ratios
   add_bbind    - Add further background function bindings
   clear_bbind  - Clear parameter bindings for one or more background functions


To set functions as operating globally or local to a single dataset

::

   set_global_foreground - Specify that there will be a global foreground fit function
   set_local_foreground  - Specify that there will be local foreground fit function(s)

   set_global_background - Specify that there will be a global background fit function
   set_local_background  - Specify that there will be local background fit function(s)


To fit or simulate:

::

   fit          - Fit data
   simulate     - Simulate datasets at the initial parameter values


Fit control parameters and other options:

::

   set_options  - Set options
   get_options  - Get values of one or more specific options


Fitting functions
=================

Several ``multifit`` variants are available for ``sqw`` and ``d1d``, ``d2d``,
``d3d`` & ``d4d`` objects. The only substantive difference is the form of the
fit functions they require: either they are functions of the numeric values of
the plot coordinates, or they are function of wavevector in reciprocal lattice
units and energy.


multifit function
*****************

This method is identical to ``multifit_func``.

- Foreground function(s): function of the plot axes ``x1``, ``x2``, ..., ``xn``
  for as many x arrays as there are plot axes
- Background function(s): functions of the plot axes ``x1``, ``x2``, ..., ``xn``
  for as many x arrays as there are plot axes

The general form of a function of plot axis coordinates is:

::

   y = my_function (x1, x2, ..., xn, pars)

or, more generally:

::

   y = my_function (x1, x2, ..., xn, pars, c1, c2, ... cn)


where

- ``x1``, ``x2``, ..., ``xn`` Arrays of x coordinates along each of the n
  dimensions

- ``pars`` Parameters needed by the function

- ``c1``, ``c2``, ..., ``cn`` Any further constant arguments needed by the
  function. For example, they could be the filenames of lookup tables


multifit_func
*************

This method is identical to ``multifit``.


multifit_sqw
************

- Foreground function(s): functions of |SQW|
- Background function(s): functions of the plot axes ``x1``, ``x2``, ..., ``xn``
  for as many x arrays as there are plot axes

The general form of a model for |SQW| is:

::

   weight = sqwfunc (qh, qk, ql, en, p)


or, more generally:

::

   weight = sqwfunc (qh, qk, ql, en, p, c1, c2, ..., cn)


where

- ``qh``, ``qk``, ``ql``, ``en`` Arrays containing the coordinates of a set of
  points
- ``p`` Vector of parameters needed by the model e.g. [A, js, gam] as intensity,
  exchange, lifetime
- ``c1``, ``c2``, ..., ``cn`` Other constant parameters e.g. file name for
  look-up table weight Array containing calculated spectral weight

The general form of a function of plot axis coordinates is:

::

   y = my_function (x1, x2, ..., xn, pars)


or, more generally:

::

   y = my_function (x1, x2, ..., xn, pars, c1, c2, ..., cn)


where

- ``x1``, ``x2``, ..., ``xn`` Arrays of x coordinates along each of the n
  dimensions
- ``pars`` Parameters needed by the function
- ``c1``, ``c2``, ..., ``cn`` Any further constant arguments needed by the
  function. For example, they could be the filenames of lookup tables


multifit_sqw_sqw
****************

- Foreground function(s): functions of |SQW|
- Background function(s): functions of |SQW|

The general form of a model for |SQW| is:

::

   weight = sqwfunc (qh, qk, ql, en, p)


or, more generally:

::

   weight = sqwfunc (qh, qk, ql, en, p, c1, c2, ..)


where

- ``qh``, ``qk``, ``ql``, ``en`` Arrays containing the coordinates of a set of
  points
- ``p`` Vector of parameters needed by the model e.g. [A, js, gam] as intensity,
  exchange, lifetime
- ``c1``, ``c2``, ..., ``cn`` Other constant parameters e.g. file name for
  look-up table weight Array containing calculated spectral weight
- ``weight`` Array containing calculated spectral weight
