#####
S new
#####

On this page we give details of significant changes between various releases of Horace. Minor debugs will not be listed here.

Version 2.0.2
=============

Released December 2011

v2.0.2 Major changes
********************

**Scan planner**

There is now a tool to enable you to calculate quickly the coverage of Q-space you will get at a particular energy transfer, given a certain incident energy and range of sample angles.

- *Herbert* graphics / the death of Libisis

It is now no longer a requirement to install Libisis as well as Horace. The only bits of Libisis that were required were graphics and some low-level routines for fitting. These have now been replaced by a much smaller package called Herbert, which contains no Fortran or other mex files.

Version 2.0.1
=============

Released November 2009

v2.0.1 Major changes
********************

Multifit

  ``multifit_sqw`` and ``multifit_func`` added for sqw and dnd objects. Allows simultaneous fitting of multiple cuts/slices to a global cross-section model.

p-code and license

   Much of the lower level Matlab code is now in p-code format. This means that it has been pre-compiled and is not accessible to the user - this has been done in order to ensure that users only have known stable versions of Horace and do not accidentally break the software. Horace is now covered the the GNU public license.

Graphical User Interface (GUI)

   There is now a quick and easy way to get started with Horace without the need to use the Matlab command line.

Symmetrisation

   It is now possible to perform symmetry operations on cuts and slices (e.g. fold -H on to H) to improve the statistics on a given cut/slice. You can also now create symmetrised datasets, whereby data from equivalent Brillouin zones are combined together and written out into a new file.

Version 1.0
===========

Released May 2009 - the first version of Horace available to the public.

v1.0 Major changes
******************

SQW objects

   The most significant change relative to the beta version of Horace is the addition of sqw objects. Previously a 1d cut would be represented by a d1d object, a 2d slice by a d2d object, and so on. An sqw object encompasses all 5 possible dimensionalities (0 to 4) - i.e. one can have a 1-dimensional sqw object, a 2-dimensional sqw object etc.

   The sqw object is a special / protected object, in that only a limited number of operations can be performed on it. For example, you can make cuts, plots and add a single number to an sqw object, but you cannot smooth it.

   The sqw object is protected because it contains, in addition to signal/error/co-ordinate arrays, information about every detector pixel which contributed to the signal in that object. This is to allow, in principle, resolution corrections to be performed, amongst other things. It is for this reason that operations such as smoothing are not permitted, since any such operation cannot maintain consistency between the information displayed in a plot and the detector pixel information contained in the sqw object.

Libisis graphics and low level functions

   Previous versions of Horace made use of low-level functions in MGenie, and also the plotting facilities therein. MGenie is no longer supported, so these functions have been passed over to Libisis, which is supported.
