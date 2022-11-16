#######
Tobyfit
#######


Introduction
============

The purpose of Tobyfit is to enable you to fit to Horace datasets taking into account the broadening of the data arising
from the resolution of the instrument. Even if the excitations in your sample were infinitely long-lives you would have
non-zero broadening in energy and wave vector arising from numerous contributions. The spread of energies arise from:

- the non-zero width in the moderator pulse;
- the non-zero pulse width from the Fermi or disk choppers;
- the different flight-times for the neutrons due to different distances that neutrons travel depending on the point of
  emission from the moderator, point of scattering ion the sampel and point of absorption in the detector.

The spread of wavevector arises from:
- spread of angle of the incident neutrons at the sample from the non-zero width of the moderator;
- the non-zero size of the sample;
- a spread of scattering angles into a given detector element because of the non-zero size of the detector element.

Resolution effects can be quite considerable. Not only do they result in an increase in the energy width of peaks
(thereby giving an illusory shorter lifetime of the excitations), they can also shift the positions of peaks depending
on, for example, the curvature of dispersion relation within the resolution function. This can result in incorrect
values of exchange constants being extracted from the data is resolution is ignored.

Tobyfit uses the multifit fitting interface to enable you fit your data to a model for S(**Q**,w) together with background
functions. By default the S(**Q**,w) model can be global to all of the datasets you pass to Tobyfit i.e. a single model that
applies with the same parameter values to all datasets, with independent background functions for each of the
datasets. Alternatively, you can specify that the S(**Q**,w) model is local i.e. the parameters vary independently for each
dataset, but you can constrain parameters to be bound between the S(**Q**,w) models so that, for example, they all share
common magnetic exchange constants but the intensities and intrinsic lifetimes can vary independently for each cut.

Tobyfit therefore appears to operate just like :ref:`multifit_sqw <manual/Multifit:multifit_sqw>`, with the same set of
capabilities of controlling parameter setting, binding etc that all other :ref:`multifit variants
<manual/Multifit:Multifit>` have. The difference is that Tobyfit uses instrument information in the sqw objects to
convolute the S(**Q**,w) model(s) with the instrument resolution function using a Monte Carlo multi-dimensional integration,
and provides some additional methods to control how the convolution is carried out. Note that the background functions
are \*not\* convoluted with the resolution function - the assumption is that they are simply empirical functions such as
linear background models and so resolution function convolution makes little sense.

This also means that instrument information must be included in the ``sqw`` object. At present, this is done using the
``<inst>_instrument`` functions which are defined for the three ISIS spectrometers LET, MAPS and MERLIN. In future, this
information will be included when the ``sqw`` file is constructed by ``gen_sqw`` if the input files contain suitable
information.


Performing resolution convolution
=================================

Setting the sample and instrument information
*********************************************


The first thing you need to do is provide the sample and instrument information to your datasets. You can do this by
creating a sample object. There is an object class called ``IX_sample`` which does this; type ``doc IX_sample`` for more
information. An example invocation is :

::

   my_sample = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.03,0.03,0.04])


Next you must create an instrument description. Horace provides functions for the ISIS chopper spectrometers that do
this. For example, for the MAPS spectrometer you can use

::

   instru = maps_instrument (ei, frequency, chopper_type)

where

- ``ei`` : incident energy (meV)

- ``frequency`` : frequency of the Fermi chopper

- ``chopper_type`` : character that indicates the chopper type (in the case of MAPS this is 'A' , 'B' or 'S' for the sloppy chopper)

The functions for the other spectrometers are ``merlin_instrument``, ``mari_instrument``, and ``let_instrument``.

Now you need to associate this information with the cuts you wish to fit with Tobyfit. Tobyfit will only fit sqw
objects, because the information of each individual detector-energy bin is needed to perform the resolution
convolution. This information is removed when you create cuts of type d1d, d2d, etc. If you have already created the
cuts then you do the following:

::

   my_cuts = set_sample (my_cuts, my_sample)
   my_cuts = set_instrument (my_cuts, instru)


Note that these functions will operate on arrays of sqw objects, so you do not need to write ``for`` loops.

Alternatively, you can attach the information to the sqw file from which you are going to make the cuts:

::

   set_sample_horace (my_sqw_file, my_sample)
   set_instrument_horace (my_sqw_file, instru)


The advantage of doing this is that every cut you take from the sqw file will also have the sample and instrument information.


Fitting data
************

Once you have set the sample and instrument you can start fitting your data. To start, you need to create a fitting
object, which in the following example we'll give the name ``tf``:

::

   tf = tobyfit (my_cuts)


Now you have created this object, the procedure is just the same as for the various other flavours of ``multifit``, and
specifically the form of the fitting functions is the same as ``multifit_sqw``. You can follow the link to
:ref:`multifit <manual/Multifit:Multifit>` for the general information about how to create a fit, and :ref:`multifit_sqw
<manual/Multifit:multifit_sqw>` for the form of the function that models S(**Q**,w). For complete documentation use the
Matlab help by typing ``doc sqw/tobyfit`` and navigate the links to the various methods for setting functions,
parameters, fixed/free parameters and bindings between parameters.

In addition to all of the methods for setting up and performing a fit, there are a few that are specific to Tobyfit (and
which are documented in full in the Matlab documentation at ``doc sqw/tobyfit``). The most important are outlined
below. There is also the possibility to refine the crystal orientation and the moderator lineshape.


Controlling number of Monte Carlo points
----------------------------------------

::

   tf = tobyfit (my_data)
   tf = tf.set_mc_points (10)


and to enquire of the current values

::

   tf.mc_points


The default is 10. This is a good starting value.


Controlling which contributions to include in the resolution function
---------------------------------------------------------------------

There are a number of contributions to the resolution function. As an example:

::

   tf = tobyfit (my_data)
   tf = tf.set_mc_contributions ('nomoderator') % excludes the contribution from the moderator


To control the other contributions navigate the Matlab help ``doc sqw/tobyfit``. To enquire of the current values:

::

   tf.mc_contributions
