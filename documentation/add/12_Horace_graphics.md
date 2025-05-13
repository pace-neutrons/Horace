# Horace graphics 
Date: 2025-04-30



## Overview of Horace graphics

Horace has a number of graphical tools for plotting one-dimensional data (i.e. intensity and error bars as a function of one coordinate), two-dimensional and three-dimensional data. There are several classes of objects that we want to plot:

- `IX_dataset_1D`, `IX_datset_2D`, `IX_dataset_3D` (the underlying data classes in the Herbert utilities);
- `d1d`, `d2d`, `d3d` (the Horace classes without information of individual pixels and full experiment information);
- `sqw` objects with one, two or three dimensional data.

The goal of the graphics functions in Horace is to provide windows management and command line functions that are simple to use and to ensure uniformity of the interfaces for plotting objects of the different classes with the same dimensionality. The primary features are: 

- Figure window management which includes in particular the ability to have multiple figure windows for plots of data of the same class and dimensionality, one window active for graphical output with others retained, for example, for comparison.

- For each plottable class, there is a data plot interface that defines the plotting functions that are applicable to that class for making line/maker/error plots, overplotting the same on existing plots, area plots, surface plots etc.

- A set of simple to use functions, and changing the axes limits, axes scaling (linear or logarithmic), setting line and marker properties such as colour, line thickness and line or marker type for subsequent plots etc.

For historical reasons, the graphics tools within Horace are referred to as "genie graphics". They were inspired by the original Matlab data visualisation application `mslice` and developed for use with the Matlab implementation of neutron data reduction code called `mgenie` (both deprecated at the time of writing this document).



## Graphics figure window management

Horace manages graphics windows as 'genie_figures'. These are Matlab figure windows which use the figure property `Tag` to hold the figure status as either `Keep` or `Current`, and two menus on the figure window (`Keep` and `Make Current`) for a user to change the status. They are used by e.g. Horace, Herbert and the Matlab mslice applications to make the management of collections of related figures convenient. For example, Horace has one-dimensional plots, two-dimensional area plots, two-dimensional surface plots and 3D volume plots, and there can be several figures of each type. The windows for each type are distinguished by their name. For example, 1D `sqw` data and `d1d` data are plotted on windows called 'Horace 1D data'; Horace 2D data are plotted in windows called 'Horace area plot' or 'Horace surface plot' etc. Only one figure of each set can be currently active for graphical output for the type accepted by that set - this is the one that has `Current` status; the others have `Keep` status. If none of the windows for a particular plot type has `Current` status - that it, they all have `Keep` status - then when a request is made to make fresh plot of data of that type then a new figure window of the appropriate type is created and set to `Current` status.

For example, if `my_data_1`, `my_data_2` etc. are one-dimensional sqw objects and we start with no genie_figures:

```
% Create a 'Horace 1D plot' genie_figure: (will be given 'Current' status)
dl (my_data_1)	% 'draw line'

% Create a fresh figure: (clears the axes in the current 'Horace 1D plot' genie_window)
dl (my_data_2)	% 'draw line'

% Overplot on the current 'Horace 1D plot'
pl (my_data_3)	% 'plot line'

% Keep the current genie_figure: (gives it `Keep` status)
keep_figure	% alternatively, use the `Keep` menu item on the genie_figure)

% Request another plot
dl (my_data_4)	% 'draw line' (creates a second 'Horace 1D plot' genie_figure)
```

Users do not need to know about the functions that form the genie_figure window management because they are developer functions that are used by plot commands like `dl`, `dm`, `de`... and the methods for the plottable class (`IX_dataset_1d` etc.).


### Defining features of genie_figures

The defining features of genie_figures are:
- A name which can be shared by several figure to define a collection of related figure windows (e.g. 'Horace 1D plot').

- `Keep` and 'Make Current' menus on the figure (and associated figure object properties to keep track of the figure state), whereby at most one of the collection can be set to be the one currently active for further graphical output directed to a genie_figure with that name.

- Selecting one of the genie_figures to be have `Current` status (that is, to be the currently active one in the collection) automatically sets the others in the collection to `Keep` status.



### Genie_figure management functions


| Function | Description|
|----------| ------------|
|`genie_figure_create`          | Create a named genie_figure, or convert any matlab figure window into a named genie_window
|`genie_figure_clear`           | Clear a genie_figure (same functionality and options as the Matlab function `clf`, except that the defining genie_figure menus `Keep` and `Make Current` are retained
|`genie_figure_keep`            | Keep the indicated genie_figure (also: has the alternative user-facing synonym `keep_figure`)
|`genie_figure_make_cur`        | Make the indicated genie_figure the current one of that name for graphical output (also: has the alternative user-facing synonym `make_cur`)
|`genie_figure_set_target`      | Set the indicated genie_figure or other matlab figure window as the current target for graphical output
|`genie_figure_all_handles`     | Return the figure, axes and all plot handles for the indicated genie_figure
|`genie_figure_parse_plot_args` | Parse plot method input arguments
|`is_genie_figure`              | Enquire if a figure is a genie_figure

The functions are publically visible as they can be used by methods of other classes, and the synonyms `keep_figure` and `make_cur` to `genie_figure_keep` and `genie_figure_make_cur` are user functions. The genie figure management functions are also designed to be available for use by other applications. (For example, they were used by the old mgenie routines before that was deprecated).


### Default genie_figure names

By default genie_figure figure window names depend on the type of plot (see the following table). The different figure names mean that by default 1D line plots are created in different windows to those of 2D area plots, for example.

| Dimension<br><br> | Plot type<br><br> | Default genie_figure name<br>(Used by `IX_dataset_*d`, `*` = 1,2,3) | Used by `d1d`,`d2d`,`d3d`,`sqw`<br><br> |
|-------------------|-------------------|--------------|--------|
|1D data| line plots, histogram plots etc.| 'Herbert 1D plot' | 'Horace 1D plot'|
|2D data| area plot<br> surface plot      | 'Herbert area plot' <br>'Herbert surface plot' | 'Horace area plot' <br>'Horace surface plot'
|3D data| volume plot                     | 'Sliceomatic' | 'Horace sliceomatic'

Plots of `IX_dataset_1d`, `IX_dataset_2d` and `IX_dataset_3d` objects use the default genie_figure names. The plot interfaces (see section **Plot interface and data plotting methods** below) for `d1d`, `d2d`, `d3d` and `sqw` classes define different default names by temporarily setting the default name for the relevant plot methods implemented in the plot interfaces.


### Technical details about genie_figures

A genie_figure window will always have the following:
- Object property `Tag` with the value `<name>$current$` or `<name>$keep$`, where `<name>` is the value of the figure property `Name` (and which is the displayed name of the plot following the figure number, for example `Herbert area plot`).
- Two uimenus on the window toolbar named `Keep` and `Make Current`, with the property tags `Keep` and `make_cur` respectively.
- One of these uimenus will have property `Enable` set to 'on', the other will have the property `Enable` set to 'off' (and will in consequence be greyed out), according to the figure tag being `<name>$current$` or `<name>$keep$`.

To detect if a figure is a genie_figure the defining quality to be tested for is the presence of one of the tags `<name>$current$` and `<name>$keep$`. The presence of the uimenus alone is not sufficient as the visualisation application mslice also has those uimenus. The genie_figure management function `is_genie_figure` uses this defining quality to implement its functionality.



## Plot interface and data plotting methods
There are a number of commands for creating or adding plot data to figures. They can be grouped into three types:
- **"draw"**: Plot a fresh figure in the `Current` genie_figure of the particular plot type (for example 1D line plot, 2D area plot, 2D surface plot, 3D volume plot), or if no `Current` figure exists, create a new genie_figure.
- **"plot over"**: Overplot data on the axes of the `Current` genie_figure of the given plot type, or if no `Current` figure exists, create a new genie_figure.
- **"plot over current"** Overplot on the current Matlab figure, regardless of what type of genie_figure, or even if it is not a genie_figure. This can be used, for example, to plot a dispersion relation over a 2D area plot of the intensity as a function of wavevector and energy.

The inheritance of an abstract classdef defining a plot interfaces (see next section) for the different classes `IX_dataset_*d` (\* = 1,2,3), `d*d` and `sqw` provides for the following plot methods to be defined. Any of the methods that are not implemented for a class will cause an informative error to be thrown by the default implementation in the plot interface.


| **One-dimensional data** | **Description**
|--------------------------|--------------------
|Draw a fresh genie_figure<br>`dl`<br> `dh`<br> `dm`<br> `de`<br> `dp`<br> `dd`          | <br>"draw line"<br> "draw histogram"<br> "draw markers"<br> "draw errorbars"<br> "draw points" *(markers and errorbars)*<br> "draw data" *(lines, markers and errorbars)*
|Plot on existing genie_figure<br>`pl`<br> `ph`<br> `pm`<br> `pe`<br> `pp`<br> `pd`       | <br>"plot line"<br> "plot histogram"<br> "plot markers"<br> "plot errorbars"<br> "plot points" *(markers and errorbars)*<br> "plot data" *(lines, markers and errorbars)*
|Plot on current Matlab figure<br>`ploc`<br> `phoc`<br> `pmoc`<br> `peoc`<br> `ppoc`<br> `pdoc`       | <br>"plot line on current"<br> "plot histogram on current"<br> "plot markers on current"<br> "plot errorbars on current"<br> "plot points on current" *(markers and errorbars)*<br> "plot data on current" *(lines, markers and errorbars)*
| **Two-dimensional data** | |
|Draw a fresh genie_figure<br>`da`<br> `ds`<br> `ds2`<br> <br>       | <br>"draw area"<br> "draw surface" *(z-axis is signal; colour scale is also signal)*<br> "draw surface, two datasets"<br>*(z-axis is signal of dataset 1; colour scale is errors, or signal of dataset 2 if given)*<br> 
|Plot on existing genie_figure<br>`pa`<br> `ps`<br><br> `ps2`<br><br>        | <br>"plot area"<br> "plot surface"<br> *(z-axis is signal; colour scale is also signal)*<br> "plot surface, two datasets"<br>*(z-axis is signal of dataset 1; colour scale is errors, or signal of dataset 2 if given)*
|Plot on current Matlab figure<br>`paoc`<br> `psoc`<br><br> `ps2oc`<br><br>        | <br>"plot area on current"<br> "plot surface on current"<br> *(z-axis is signal; colour scale is also signal)*<br> "plot surface, two datasets, on current"<br>*(z-axis is signal of dataset 1; colour scale is errors, or signal of dataset 2 if given)*
| **Three-dimensional data** | |
|Draw a fresh genie_figure<br>`sliceomatic`<br> `sliceomatic_overview`       | <br>3D slicing tool; perspective view of data<br> 3D slicing tool, view down axis of choice<br> 


### Interface to plot functions

A uniform user interface to plottable objects is accomplished by defining plot interfaces that inherit from the abstract class `data_plot_interface`. This base abstract class defines interfaces to the plot methods for one-dimensional, two dimensional and three dimensional objects. The specific classes `sqw`, `dnd` and Herbert `IX_dataset_*d` inherit `data_plot_interface` and implement plotting methods specific to the particular n-dimensional objects.

The uniformity of a user interface to plotting is achieved by actual implementation of plot methods of the `IX_dataset_1d`, `IX_dataset_2d` and `IX_dataset_3d` classes. The user interface to `dnd` type objects is done by some wrapping of these methods, but most of the work is delegated to the appropriate `IX_dataset_*d` methods. Similarly, the plot interface to `sqw` does some light wrapping but otherwise delegates the plotting to the `dnd` methods. This looks like a hierarchy `sqw` > `dnd` > `IX_dataset` for plotting. In particular, this enables the same syntax for arguments controlling plot limits and the target figure or axes handle for plotting to be the same for all the classes. The formal inheritance diagram of this plotting interface is presented in the following figure, and is explained more fully below.

![Data plot interface](../diagrams/sqw-dnd_plot_interface.png)
 


### Plot methods for `IX_dataset_1d`, `IX_dataset_2d` and `IX_dataset_3d` objects

These classes inherit the corresponding `IX_data_*d` class and abstract class `data_plot_interface`, with the class definition files having explicit interfaces to the plot methods of the appropriate class dimensionality. 

For example, in the case of `IX_dataset_1d` the classdef file contains:

```
classdef IX_dataset_1d < IX_data_1d & data_plot_interface
        :
    methods
        :
        % Actual plotting interface:
        [figureHandle, axesHandle, plotHandle] = dd(w,varargin);
        [figureHandle, axesHandle, plotHandle] = de(w,varargin);
        :
        [figureHandle, axesHandle, plotHandle] = pp(w,varargin);
        [figureHandle, axesHandle, plotHandle] = ppoc(w,varargin);
        :    
    end
```

Specific implementations of `dd`, `de`, ...`pp`, `ppoc` are defined in separate files in the class folder for `IX_dataset_1d`. Only methods for plotting 1D data are implemented for `IX_dataset_1d`. The inherited abstract class `data_plot_interface` ensures that plot methods for other dimensionalities (e.g. in the above case `da` for "draw area") will throw an appropriate error message. Likewise, only methods for plotting 2D data are implemented for `IX_dataset_2d`.


### Plot methods for `d1d`, `d2d` and `d3d` objects

These classes are extremely lightweight children of the abstract superclass `DnDBase` which is the generic multi-dimensional Horace 'image' class. 

One possible way to have implemented plot methods for `d1d`, `d2d` and `d3d` could have been an exact mirror of that for `IX_dataset_*d`. That is, the classdef for `d1d` could inherit `data_plot_interface`, have explicit interfaces for the 1D plot methods and implement those methods in separate files in the classdef folder for `d1d`, and similarly for `d2d` and `d3d`.

However, a simpler approach has been followed that places the emphasis on the primacy of the generic multi-dimensional parent class `DnDBase` of `d1d`, `d2d` and `d3d`, and the fact that only simple wrapping of the `IX_dataset_*d` plot methods is needed to implement the plot methods. Accordingly, in the present implementation `DnDBase` inherits the abstract plot interface `dnd_plot_interface`, which in turn inherits `data_plot_interface`. A single .m file defines `dnd_plot_interface` and the plot methods for all dimensionalities; each plot method makes a call to convert the input `d*d` object (\* = 1,2,3) into the corresponding `IX_dataset_*d` object and then calls the appropriate plot method. The advantage with this implementation is that just one file holds the entire plot implementation for `d1d`, `d2d` and `d3d`, which makes future maintenance easier.

Note:
- The plot methods each need to make a check of the dimensionality of the incoming `d\*d` object to ensure that, for example, a 1D method is not called on a 2D object. (Organising the plot methods separately for `d1d`, `d2d` and `d3d`, just as has been done for `IX_dataset_1d` etc. would not require such a check as the method would never be called in the first place).
- The 2D and 3D plot methods permit an additional input option to control the aspect ratio of the plot axes. Service functions in `dnd_plot_interface` strip the optional input arguments that are permitted in addition to those permitted for the `IX_dataset_*d` plot methods.
- The Matlab help for each plot method has to be copied from the corresponding `IX_daaset_*d` method, so that the help can refer to the appropiate class name in each case, and to describe additional options such as the aspect ratio control. Developers must be aware that the help for each method must be maintained in conjunction with the corresponding `IX_dataset_*d` method.
- The classdef file for `dnd_plot_interface` is held in the same subfolder of the Herbert graphics that holds `data_plot_interface`.

### Plot methods for `sqw` objects

Objects of class `sqw` can have dimensionality 0, 1, 2, 3 or 4. The plot interface is implemented in the same way as for `d*d`: `sqw` inherits an abstract class `sqw_plot_interface`  that inherits `data_plot_interface` and implements all the plot functions, each of which converts the input object into the corresponding `d\*d` object and calls the corresponding plot method for that object.
- Again, developers must be aware that the help for each method must be maintained in conjunction with the corresponding `d1d`, `d2d` or `d3d` method.
- The classdef file for `sqw_plot_interface` is held in the same subfolder of the Herbert graphics that holds `dnd_plot_interface` and `data_plot_interface`.



## Functions that alter plot properties

|Function |Description
|---------|-------------
|**Lines, markers and colours**<br> `acolor`<br> `aline`<br> `amark`<br><br> | <br>Alter colour of lines and markers \* <br> Alter line styles and widths \* <br> Alter marker types and sizes and style(s) \* <br>  \* *Changes apply to subsequent line and marker plots* <br>
|**Axes properties**<br>`aspect`<br> `lx`<br> `ly`<br> `lz`<br> `lc`<br> `linx`<br> `liny`<br> `linz`<br> `logx`<br> `logy`<br> `logz`<br><br>      | <br>Alter aspect ratio<br> Change limits along x-axis<br> Change limits along y-axis<br> Change limits along z-axis<br> Change limits along colour axis<br> set linear x-axis \* <br> set linear y-axis \* <br> set linear z-axis \* <br> set logarithmic x-axis \* <br> set logarithmic y-axis \* <br> set logarithmic z-axis \* <br> \* *Applies to the current and subsequent plots*
|**Figure window functions**<br>`clearfigs`<br> `keep_figure`<br> `make_cur`<br> `colorskider`<br> `meta`<br><br>| Delete figure or figures<br> Lock a genie_figure from future plotting<br> Make a genie_figure current for plot output<br> Create, refresh or delete a colorslider *(see notes below)*<br> Make a metafile copy of a figure (in Windows copies to the clipboard)<br>
|**Get coordinates of points**<br>`xycursor`<br> `xyselect`<br> `xyzselect`   | <br>Select point with cross-hairs; on mouse click, draw coordinates on plot<br> Select point with cross-hairs; on mouse click, print to command window<br> Select point on volume plot; on mouse click, print to command window<br>


Notes:
- A `colorslider` is a colorbar on 2D area and surface plots, as can be created by the Matlab `colorbar` function, with in addition (1) boxes to edit the minimum and maximum values for the colorscale and (2) a slider bar adjacent to each of those boxes to enable those values to be increased or decreased by clicking on the 'up' and 'down' arrows on those slider bars.
- Several of the functions in the table apply to any Matlab figure, not just genie_figures. These are `aspect`, `lx`, `ly`, `lz`, `lc`, `xycursor`, `xyselect`, `xyzselect`, and, for the current plot but not subsequent plots, `linx`, `liny`, `linz`, `logx`, `logy`, `logz`.


## Location of source code

The core graphics functions are in `/herbert_core/graphics`.

This folder contains:
- Genie_figure management functions (see the table in section: **Graphics figure window management**)
- The folder `/herbert_core/graphics/plot_interfaces` that contains the base abstract interface `data_plot_interface` and the child abstract interfaces for `d*d` (\* = 1,2,3) and `sqw` classes `dnd_plot_interface` and `sqw_plot_interface` (see section: **Plot interface and data plotting methods**)
- Functions that control genie_figure colors, line and marker properties, axes properties etc. (see the table in section: **Functions that alter plot properties**)
- Folder `/herbert_core/graphics/sliceomatic` that implements the volume slicing-and-dicing tool `sliceomatic`. This was originally downloaded from the Matlab Central File Exchange in c. 2005, and modified and maintained for ISIS. It is the core graphics tool that is wrapped in the implementations of methods of the same name for `IX_dataset_3d`, `d3d` and `sqw` classes.

In addition, the folder contains the class definition of a singleton class, `genieplot` that holds information about settings for linestyle, linewidth, marker type and size, colours, axes scaling etc. It effectively holds the configuration state of the graphics.Its properties are set or get across the genie graphics functions and in implementations of plot methods defined in the various plot interfaces.


