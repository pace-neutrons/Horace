#################
Advanced Multifit
#################

Parallel fitting
================

It is possible to use ``multifit`` and its derivatives (``tobyfit``, ``multifit_sqw``, ``multifit_sqw_sqw``) in parallel
(see :ref:`manual/Parallel:Running Horace in Parallel` for more info) by either enabling HPC options through

::

   >> hpc('on');

or by setting ``parallel_multifit`` directly in the ``hpc_config`` (see :ref:`Changing Horace settings
<manual/Changing_Horace_settings:HPC Config>`)

::

   >> hc = hpc_config;
   >> hc.parallel_multifit = true;

Parallel multifit decomposes the objects passed in into slices which are distributed between the processors. E.g. if we
are fitting three ``IX_dataset`` objects with 100 points between two processors, each processor will receive 50
points from each ``IX_dataset``.

This decomposition is performed differently for each of the three classes of fittable objects for each they are divided
into ``N_items/N_procs``:

- For sqw objects, the items are pixels
- For dnd objects, the items are whole bins.
- For IX_dataset objects, the items are points.

If the fitting is run with the ``-ave`` option, then the decomposition will not split bins, but will distribute whole
bins only.

Multifit methods requirements
=============================
This section describes how to set up an object to work with Multifit specifications

In many cases, the most convenient thing to do is extract the x,y,e arrays from an object and pass those to
multifit. This can be done by using a method defined on the object to extract an x,y,e triple:

::

   >> [wout, fitdata] = multifit (xye(w), func, pin,...)

where the method xye must return a structure of the form required by multifit, namely a structure with fields ``x``,
``y`` and ``e`` ,where ``x`` is a cell array ``{x1,x2,...}`` containing vectors of coordinates of the points along the
first, second, ...  axes, and ``y`` and ``e`` are vectors of the signal standard deviations repeactively. A convenient
way to do this is to use the methods sigvar_get and sigvar_getx if they have been written to allow the object itself to
be passed to multifit (see below).

If multifit is being used to fit functions to objects rather than x-y-e triples, then there are some methods that need
to be defined. You might want to fit the objects if their internal structure is more complex, for example if the fitting
function depends on fields other than just the x values and parameters being passed to the fit function. Another case is
when the masking of points from fitting requires manipulation of fields other than simply removing x-y-e values. [An
example is the case of the sqw objects used in Horace. Here the calculation of the intensity at a data point depends on
the information of the individual pixels that contribute to that data point. Masking requires that the pixel information
of masked bins is removed from the sqw object.]

The methods required for fitting objects with multifit are as follows:

Fit functions
*************

The global function, and background function(s) if given, can be methods of the class or simply functions, with input
argument form as described in detail in multifit help. The general format is:

::

        >> wcalc = my_function (w,p,c1,c2,...)

If multifit is defined as a method of the class, then one can use the capability of nesting functions within the method
to accept different fit function syntax. This is done, for example, for sqw objects when the fit functions to multifit,
and equivalently multifit_func, are just a 1D/2D...4D Gaussian (according to the dimensionality of the sqw object).


Utility methods
---------------

These are required to enable multifit to work with objects

wout = mask(win, msk)
~~~~~~~~~~~~~~~~~~~~~~

A method that masks data points from further calculation. The output object must be a valid instance of the class in
which the masked values have been removed in whatever sense the class requires.


[y,var,msk] = sigvar_get(win)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A method that returns the intensity and variance arrays from the objects, along with a mask array that indicates which
elements are to be retained (where elements of msk are true, the corresponding elements of y and var are retained). The
output arrays y and var must have the same size and shape; msk must have the same number of elements (but can be a
different shape). The array msk must be understood by the method 'mask' defined below.


wsum = w1 + w2
~~~~~~~~~~~~~~

If a background function is provided, addition of objects must be defined (requires overloading of the addition
operator with a method named plus.m).



x = sigvar_getx(win) [optional]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get the corresponding x values to the y, var, msk arrays that are returned by sigvar_get.

- If one dimensional i.e. single x coordinate per point:

    x must be a single array, the same size as y and var
- If n-dimensional i.e. n x-values per point:

    x must be a cell array of arrays, one per x dimension, each the same size as y and var as returned by sigvar_get.

This method replaces the need to have the method 'mask_points' described below, as 'sigvar_getx' will enable the masking
function built in to multifit to be used. However, if mask_points exists, then it will have priority over the use of
sigvar_getx.


[msk, ok, mess] = mask_points(win, 'keep', xkeep, 'remove', xremove, 'mask', msk_in) [optional]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a mask array given ranges of x-coordinates to keep, remove or mask from the array. The elements of a mask array are
``true`` for those data points which are to be retained.

Function must output a logical flag ``ok``, with message string if ``ok==false`` rather than terminate.

(It is possible to have the function terminate if ``ok`` and ``mess`` are not given as return arguments; it is the
advanced syntax that is required within multifit).
