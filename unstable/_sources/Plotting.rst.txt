########
Plotting
########

An exhaustive list of commands to do with plotting your data - one of the primary functions of Horace!

plot
====

Plot a dnd or sqw object. This does not work for 0-dimensional objects (single points), or 4-dimensional objects (we couldn't think of a way of displaying 4 dimensions plus intensity!). For 1-dimensional objects a series of markers with errorbars are connected by a line. For 2-dimensional objects a 2D colourmap is displayed. For a 3-dimensional object the *sliceomatic* program is used, where a series of 2D slices within a box are plotted.

::

   plot(w)

   [figureHandle_, axesHandle_, plotHandle_] = plot(w)


The second line of code (with outputs) gives outputs that are Matlab handles to the figure window, the axes, and the plot respectively. These are useful if, for example, you wish to resize the axes, change the font size of labels, etc.

smooth
======

::

   wsmooth=smooth(w)

   wsmooth=smooth(w,[wid_x,wid_y,..],shape)


``smooth`` allows you to smooth the data for plotting. Can optionally specify the width and smoothing function ('hat' or 'gaussian'). The default is 'hat', and 3 bins either side in all directions.

**IMPORTANT NOTE** You can only apply smoothing to dnd objects, **not** to sqw objects, since with the latter you would be destroying the very pixel information that the object is designed to hold. To convert an sqw object (``win``) to a dnd, simply type ``wout=d1d(win)``, if ``win`` is 1-dimensional, ``wout=d2d(win)`` if it is 2-dimensional, and so on.


Altering plot characteristics and other useful commands
-------------------------------------------------------

Colour of lines and markers
===========================

To change the marker and line colour in a 1-dimensional Horace plot, type

::

   acolor <the color that you want>


e.g. for a red plot:


::

   acolor red


Line style
==========

To change the line style in a 1-dimensional plot, type e.g.

::

   aline --


to make a dashed line. You can also change the line thickness with something like

::

   aline 2


To change multiple characteristics, type e.g.

::

   aline(2,'--')


Type ``help aline`` in Matlab for a full list of options.

Marker style
============

You can change the style of marker in a 1-dimensional plot in a similar way to the above, e.g.

::

   amark o %gives a circular marker
   amark 6 %sets marker size to 6
   amark(6,'o') %sets a circular marker with size 6


Type ``help amark`` in Matlab for a full list of options.

Axes Limits
===========

To change the x, y, or z limits of a plot, type e.g.

::

   lx 0 3
   ly -6 1
   lz -2 2


which sets the x-axis limits to be 0 to 3, the y-axis limits to be -6 to 1, and the z-axis limits to be -2 to 2. Note the ``lz`` is used to change the color scale on a colormap plot.

To set the range to cover the full data range, just issue the commands without a range:

::

   lx
   ly
   lz


You can also change the axes scales to be linear or logarithmic using

::
   linx
   logx

   liny
   logy
   ...


Cursor
======

In order to get a cursor on your Horace plots, type

::

   xycursor


You then left click the mouse on a position in a figure, and the x and y values are printed in the Matlab window. You can do this multiple times. To turn off the cursor, hit the carriage return key.

Alternatively, to use a cursor to select x and y values and print them in the Matlab command window or save to arrays, type

::

   xyselect

   [x,y]=xyselect


Keeping plots
=============

To store a figure in your current session (i.e. so that the next plot you make opens in a new window, with the current plot preserved), type

::

   keep_figure


If you have multiple figures open and you wish to alter one of them (e.g. by appending a line or more data to it)that has been kept using the above command, click on it and then type

::

   make_current


Note that both of these options are also available in drop-down menus in the figures windows themselves.


One dimensional plots
---------------------

In the following the object being plotted can be a single sqw or dnd object, or an array of objects.

dd (draw data)
==============

Plotting command for 1-dimensional objects only, plotting markers, errorbars, and connecting lines. Any existing 1-dimensional figure window is cleared before plotting i.e. existing data is not overplotted. If you use this command and the current figure window does not correspond to a 1-dimensional object, then a new figure window will be created.

::

   dd(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] =  dd(w_1d)


dl (draw line)
==============

Plot line between points for a 1-dimensional object. No markers or errorbars displayed.

::

   dl(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] = dl(w_1d)


dm (draw markers)
=================

Plot markers at points for a 1-dimensional object. No line or errorbars displayed.

::

   dm(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] = dm(w_1d)


dp (draw points)
================

Plot markers and errorbars for a 1-dimensional object. No lines linking points are displayed.

::

   dp(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] = dp(w_1d)


de (draw errors)
================

Plot errorbars at points for a 1-dimensional object. No linking lines or markers are displayed.

::

   de(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] = de(w_1d)


dh (draw histogram)
===================

Plot histogram of a 1-dimensional object.

::

   dh(w_1d);

   [figureHandle_, axesHandle_, plotHandle_] = dh(w_1d)

pd (plot data)
==============

Overplotting command for 1-dimensional objects only, plotting markers, errorbars, and connecting lines. If the current window is a 1-dimensional figure window the existing plot is overplotted. If there is no current figure window then it plot a new one. If you use this command and the current figure window does not correspond to a 1-dimensional object, then a new figure window will also be created.

::

   pd(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] =  pd(w_1d)


pl (plot line)
==============

Overplot line between points for a 1-dimensional object. No markers or errorbars displayed.

::

   pl(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] = pl(w_1d)


pm (plot markers)
=================

Overplot markers at points for a 1-dimensional object. No line or errorbars displayed.

::

   pm(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] = pm(w_1d)


pp (plot points)
================

Overplot markers and errorbars for a 1-dimensional object. No lines linking points are displayed.

::

   pp(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] = pp(w_1d)


pe (plot errors)
================

Overplot errorbars at points for a 1-dimensional object. No linking lines or markers are displayed.

::

   pe(w_1d)

   [figureHandle_, axesHandle_, plotHandle_] = pe(w_1d)


ph (plot histogram)
===================

Overplot histogram of a 1-dimensional object.

::

   ph(w_1d);

   [figureHandle_, axesHandle_, plotHandle_] = ph(w_1d)


ploc (plot line over current)
=============================

Overplot a line in the current figure, regardless of type (i.e. can plot a 1d curve on top of a 2d dataset, such as when plotting a dispersion relation over a 2d Q-E slice).

::

   ploc(w_1d);


pdoc (plot data over current)
=============================

Overplot line, markers and error bars in the current figure, regardless of type.

::

   pdoc(w_1d);


pmoc (plot markers over current)
================================

Overplot markers in the current figure, regardless of type.

::

   pmoc(w_1d);


ppoc (plot points over current)
===============================

Overplot markers and error bars in the current figure, regardless of type.

::

   pm
   ppoc(w_1d);


peoc (plot errors over current)
===============================

Overplot error bars in the current figure, regardless of type.

::

   peoc(w_1d);


phoc
====

Overplot a histogram in the current figure, regardless of type.

::

   phoc(w_1d);


Two dimensional plots
---------------------

da (draw area)
==============

Area plot for a two-dimensional object, with colour-scale signifying intensity. It is this that is called when ``plot`` is used for a 2-dimensional object.

::

   da(w_2d);

   [figureHandle_, axesHandle_, plotHandle_] = da(w_2d)


ds (draw surface)
=================

Surface plot for a two-dimensional object, with colour scale and contour signifying intensity.

::

   ds(w_2d);

   [figureHandle_, axesHandle_, plotHandle_] = ds(w_2d)


ds2 (draw surface from 2 sources)
=================================

This routine is especially useful for making surface plots of dispersion relations, when used in conjunction with dispersion</code

Make a surface plot of a 2D sqw or d2d object, with the signal array setting the contours and the error array (or another data source) providing the intensity.

::

   ds2(w_2d)       % Use error bars to set colour scale

   ds2(w_2d,wc_2d) % Signal in wc sets colour scale (sqw or d2d object with same array size as w, or a numeric array)


Differs from ``ds>`` in that the signal sets the z axis, and the colouring is set by the error bars, or another object. This enables a function of three variables to be plotted (e.g. dispersion relation where the 'signal' array hold the energy and the error array hold the spectral weight).

One can optionally return figure, axes and plot handles:

::

   [fig_handle, axes_handle, plot_handle] = ds2(w_2d,...)


pa (plot area)
==============

Overplot an area plot of a two-dimensional object

::

   pa(w)


Optionally return figure, axes and plot handles:

::

   [fig_handle, axes_handle, plot_handle] = pa(w)


ps (plot surface)
=================

Overplot a surface plot of a two-dimensional object

::

   ps(w_2d)


Optionally return figure, axes and plot handles:

::

   [fig_handle, axes_handle, plot_handle] = ps(w_2d)


ps2 (plot surface from 2 objects)
=================================

Overplot a surface plot of a two-dimensional object with the colour scale set by the error bars or a second object)

::

   ps2(w_2d)

   ps2(w_2d, wc_2d)


Optionally return figure, axes and plot handles:

::

   [fig_handle, axes_handle, plot_handle] = ps2(w_2d,...)


spaghetti_plot
==============

Plots data in sqw-file or sqw-object along HKL directions.

::

   wsp = spaghetti_plot([0 0 0; 0.5 0.5 0.5; 0.5 0.5 0],sqw_file,'labels',{'\\Gamma','R','M'})


Three dimensional plots
-----------------------

sliceomatic
===========

Sliceomatic plot of multiple area plots, for a 3-dimensional object. This function is called by the ``plot`` routine.

::

   sliceomatic(w_3d);


sliceomatic_overview
====================

As ``sliceomatic``, but the default view is from above. In effect this means you see a 2d slice which can be animated/changed by the third slider bar. Useful for e.g. following a spin wave dispersion ring/cone as a function of energy.

::

   sliceomatic_overview(w_3d);               % views down the third projection axis by default

   sliceomatic_overview(w_3d, axis_number);  % view down the given axis number (axis_number = 1,2 or 3)


Miscellaneous functions
-----------------------

``meta(fig)`` allows you to copy the figure into a metafile. On Windows, this function puts the file in the clipboard so that it can be pasted directly into Word, Powerpoint etc.
