####################
Changing object type
####################

dnd
===

Convert an n-dimensional sqw object into the equivalently dimensioned object out of d0d, d1d, d2d, d3d, d4d d0d object (i.e. throw away the pixel information)

::

   wout_dnd=dnd(win_sqw)


d0d
===

Convert an 0-dimensional sqw object into a d0d object (i.e. throw away the pixel information)

::

   wout_d0d=d0d(win_sqw)


d1d
===

Convert an 1-dimensional sqw object into a d1d object (i.e. throw away the pixel information)

::

   wout_d1d=d1d(win_sqw)


d2d
===

Convert an 2-dimensional sqw object into a d2d object (i.e. throw away the pixel information)

::

   wout_d2d=d2d(win_sqw)


d3d
===

Convert an 3-dimensional sqw object into a d3d object (i.e. throw away the pixel information)

::

   wout_d3d=d3d(win_sqw)


d4d
===

Convert an 4-dimensional sqw object into a d4d object (i.e. throw away the pixel information)

::

   wout_d4d=d4d(win_sqw)


sqw
===

Convert a dnd object into an n-dimensional sqw object


::

   wout_sqw=sqw(win_dnd)


IX_dataset_1d
=============

Convert an 1-dimensional sqw/dnd object into the generic Herbert IX_dataset_1d object


::

   wout_IX=IX_dataset_1d(win_sqw)


IX_dataset_2d
=============

Convert an 2-dimensional sqw/dnd object into the generic Herbert IX_dataset_2d object


::

   wout_IX=IX_dataset_2d(win_sqw)


IX_dataset_3d
=============

Convert an 3-dimensional sqw/dnd object into the generic Herbert IX_dataset_3d object


::

   wout_IX=IX_dataset_3d(win_sqw)
