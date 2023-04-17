
#######
Fitting
#######

Horace comes with a rich and powerful fitting syntax that is common to the methods used to fit functions or models of S(Q,w) to one or more datasets. For an introduction and overview of how to use the following fitting functions, please read :ref:`Fitting data <Multifit:Multifit>`. For comprehensive help, please use the Matlab documentation for the various fitting functions that can be obtained by using the ``doc`` command, for example ``doc d1d/multifit`` (for fitting function like Gaussians to d1d objects) or ``doc sqw/multifit_sqw`` (fitting models for S(Q,w) to sqw objects). It is strongly recommended that you use ``doc``, not ``help`` to explore how to use these methods, so that you can navigate between the numerous pages of documentation in the Matlab help window.

Several multifit variants are available for sqw and d1d,d2d,...d4d objects. The only substantive difference is the form of the fit functions they require: either they are functions of the numeric values of the plot coordinates, or they are function of wave vector in reciprocal lattice units and energy.

multifit
========

This is identical to ``multifit_func``)
The foreground and background functions both are functions of the plot axes x1,x2,...for as many x arrays as there are plot axes:

::

   y = my_function (x1,x2,... ,xn,pars)


or, more generally:

::

   y = my_function (x1,x2,... ,xn,pars,c1,c2,...)

where
- x1,x2,.xn Arrays of x coordinates along each of the n dimensions
- pars Parameters needed by the function
- c1,c2,... Any further constant arguments needed by the function. For example, they could be the filenames of lookup tables

multifit_sqw
============

The foreground function(s) are functions of S(Q,w), and the background functions are functions of the plot axes x1,x2,...

The general form of a model for S(Q,w) is:

::

   weight = sqwfunc (qh,qk,ql,en,p)


or, more generally:

::

   weight = sqwfunc (qh,qk,ql,en,p,c1,c2,..)


where
- qh,qk,ql,en Arrays containing the coordinates of a set of points
- p Vector of parameters needed by the model e.g. [A,js,gam] as intensity, exchange, lifetime
- c1,c2,... Other constant parameters e.g. file name for look-up table
- weight Array containing calculated spectral weight

The form for the background model(s) is the same as is required by ``multifit``.

multifit_sqw_sqw
================

The foreground and background function(s) are all functions of S(Q,w). The form of these models is the same as is required by ``multifit_sqw``.
