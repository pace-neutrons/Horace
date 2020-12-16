#############
Reshaping etc
#############

replicate
=========

This is a function to create a higher dimensional dataset by replicating along an additional axis. For example a d2d, which is essentially a matrix of intensity, can be replicated to make a d3d (an array of matrices) where the nth matrix is the same as the original one, or a d4d. In Matlab syntax this means e.g.

::

   Oldmat=[1 2; 3 4];
   Newmat(:,:,1) = Oldmat;
   Newmat(:,:,2) = Oldmat;

and so on.

Clearly this function cannot apply to a 4-dimensional object, but does apply to all other dimensionalities. In order to make the new object a reference object of this dimensionality (``wref``) must be supplied to act as a template. e.g.

::

   w_3d=replicate(w_2d,wref_3d);


or

::

   w_4d=replicate(w_2d,wref_4d);


Note that ``wref`` can be either a dnd or an sqw type object. However ``w_nd`` MUST be dnd and not sqw, as we have not yet implemented replication for sqw datasets.

compact
=======

A function to squeeze the range of a dataset to eliminate empty bins. For example, suppose we have a 2-dimensional dataset where the axes are ``p{1} = [-2:0.05:10]`` and ``p{2} = [-7:0.05:8]``. The intensity would be given by a 241 x 301 matrix. However suppose that we actually only have non-zero intensity for ``p{1} < 6`` and ``p{2} > -1``. In this case using the compact command would reduce the size of the intensity matrix, and make the dataset smaller on the computer.

::

   wout = compact(win);


permute
=======

Function to permute the order of the display axes in an object. There are two possible syntaxes:

::

   wout = permute(win);


which cyclically permutes the axes by one. The other possibility is to specify the order of the new axes in terms of the old ones. e.g. for a d3d object

::

   wout = permute(w_3d, [3 2 1]);


makes the new 1st axis the old 3rd, and the new 3rd axis the old 1st.

The permute function exists for dimensionalities 1 to 4 (obviously); however the 1-dimensional version simply returns the original object since there is only one axis and permutation of it does not do anything.

Note that the only thing that this function changes is the order of the axes for display. All other information, including the projection axes, are unchanged.


cut
===

This is one of the most important functions in Horace. It applies to all objects (except 0-dimensional ones) to produce a dataset the dimensionality of which is lower than the starting dataset. For example, for a d3d starting dataset you can get to a d2d, d1d, or d0d. The lower dimensional dataset is created by taking the average over a given *integration range* from the original dataset. e.g.

::

   wout=cut(w_3d,[-0.2,0.2],[0.9,1.1],[]);


takes the input d3d object ``w_3d`` and averages the signal between the limits -0.2 and +0.2 for the 1st axis, and between 0.9 and 1.1 for the second axis. The resultant ``wout`` is thus a d1d.

The general syntax is:

::

   wout=cut(win,ax_1,ax_2,...);


where ``ax_1`` etc. take the form:
- ``[lo,hi]`` for integration between two limits

- ``[lo,step,hi]`` for a plot axis between given limits with a given step size

- ``[step]`` for a plot axis taking the existing lo and hi and rebinning to a given step size,

- ``[]`` for leaving the limits and step size of an axis unchanged.


smooth
======

A function that can be used on all dnd objects except d0d (for which it would be meaningless). It is currently not implemented for sqw objects.

::

   wout=smooth(win)


This smooths the data ``win`` by convoluting it with a hat function of width 3 (the default width).

Alternatively

::

   wout=smooth(win,[width_vector])
   wout=smooth(win,[width_vector],function)

The vector ``[width_vector]`` contains n element for a n-dimensional object and gives the width of the convolution along each axis in terms of the number of bins. Alternatively you can supply a scalar, in which case the same width will be used for all axes. You can also choose with what function the data are convoluted. There are two choices for the argument ``function``, either 'hat' or 'gaussian'.

mask
====

::

   wout=mask(win,mask_array)


Apply a mask to points in an n-dimensional dataset ``win``. The masked out points have their intensity set to NaN, errorbar set to zero and npix field set to zero. The points to mask are defined by ``mask_array``, which should be an array the same size as the intensity array of ``win``, consisting of 1s and 0s where data are to be retained or masked respectively.

mask_points
===========

A function to generate a suitable mask array (see above) for an n-dimensional dataset.

::

   [sel,ok,mess]=mask_points(win,'keep',xkeep)
   [sel,ok,mess]=mask_points(win,'remove',xremove)
   [sel,ok,mess]=mask_points(win,'mask',mask_array)
   [sel,ok,mess]=mask_points(win,'keep',xkeep,'remove',xremove,'mask',mask_array)


The inputs are:

- ``win`` is the input dataset

- ``xkeep`` is the range of display axes to keep, e.g. ``[x1_lo,x1_hi,x2_lo,x2_hi,...,xn_lo,xn_hi]``. Note also that more than one range can be specified for each dimension by writing ``[range_1; range_2;...]``

- ``xremove`` is the range of display axes to remove. Follows the same format as ``xkeep``.

- ``mask_array`` is an array of 1s and 0s with the same number of elements as the data array, with 1s for elements to keep and 0s for elements to remove. Note that this applies to the stored data, not the display axes (which can be switched around by manipulating the ``dax`` field).

The outputs are:

- ``sel`` mask array the same size as data array, accounting for all of the ranges etc. input.

- ``ok`` =true if the function worked, =false if it did not (e.g. if there was a problem with one of the inputs).

- ``mess`` is a message string giving information about why the function failed. If ok==true then this is an empty string.

mask_runs
=========

Remove all pixels from one or more runs from an sqw object. Useful, for example if one run from many in an sqw file is deemed to be spurious (e.g. detector noise, unknown sample orientation, etc.)

::

    wout = mask_runs (win, runno)


The inputs are:

- ``win`` is the sqw object to be masked (single object only, not array)

- ``runno`` is the run number, or array of run numbers, in the sqw object to be masked. Convention is that run number 1 is the first file in the list when the sqw file was generated, and so on. Can be determined from inspection of ``win.header``

The output is:

- ``wout``, the output sqw object with mask applied

section
=======

Takes a section from an n-dimensional object

::

   wout=section(win,[ax1_lo,ax1_hi],[ax2_lo,ax2_hi],...)


``win`` is the input dnd or sqw object (except for d0d and 0-dimensional sqw objects), and the vectors ``[ax_lo,ax_hi]`` specify the lower and upper limits on each axis to retain. If just a zero is specified, e.g.

::

   wout=section(win,[1,2],0,[3,4])


then the existing limits are retained. So for the above 3-dimensional example data along the first axis between 1 and 2 are retained, and data between 3 and 4 on the 3rd axis are retained, and all of the data along the second axis are retained.
