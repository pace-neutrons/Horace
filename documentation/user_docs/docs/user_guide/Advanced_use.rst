############
Advanced use
############

The following details more comprehensively the functions in the Horace suite. In the :ref:`Getting started <user_guide/Getting_started:Getting started>` section a brief tutorial was provided on the use of the essential Horace functions. In addition there is also a :ref:`list of functions <manual/list_of_functions:list of functions>`, which details the syntax for every function.

Preamble
========

Horace has been designed to make use of the fact that Matlab can be written in an 'object-oriented' manner. We will not go into the (numerous) technical details of object oriented programming here, except to make a few points about why it is advantageous for the case of Horace to be written this way.

Examples of objects in Matlab include double-precision arrays, strings, cell arrays, structure arrays,... There are certain operations or functions that can only be applied to one kind of object, and are undefined for others. For example the ``det`` operation (which calculates the determinant of a matrix) does not work when applied to a string:

::

   >> A=[1 2; 3 4];
   A =

	1     2
	3     4

   >> B=det(A)

   B =

       -2

   >> C='hello'

   C =

   hello

   >> D=det(C)
   ??? Undefined function or method 'det' for input arguments of type 'char'.


In technical terms the function ``det`` is not a "method" of (i.e. function that works on) string objects.

Matlab allows you to create your own objects, and methods to go with them, and this is what has been done with Horace. The objects are named d0d, d1d, d2d, d3d, d4d, and sqw, which correspond to 0D datasets, 1D datasets,..., 4D datasets, and general datasets of any dimensionality with full detector pixel information retained. The methods that apply to these objects are contained within the directories ``C:\\mprogs\\Horace\\@d0d`` etc. Methods that apply to different objects can have the same name, and in the interests of keeping things relatively intuitive there are several examples of this within Horace, e.g. if you type ``plot(w)`` then the object ``w`` will be correctly plotted (unless it is a d0d or d4d object, of course!) because there is a ``plot`` method in all of the d1d, d2d, d3d, and sqw directories.

Help
====

To get help concerning a Horace function there are two options, in addition to reading this manual. Simply typing

::

   help function_name


where ``function_name`` is the name of the function you wish to get help with, usually works. For some functions the help given by this method is rather terse. For more detailed help you can type

::

   horace_help function_name


If a more detailed help message is available then it will be printed in the Matlab command window. If more detailed information is not available then an error is returned.


Creating an object from scratch
===============================

Suppose you wish to simulate the scattering over a particular region of reciprocal space, independent of any data you have collected. To do this you can create a dnd (where n is any number between 0 and 4) from scratch that matches your own specifications. Since the sqw object contains detector pixel information it should not be created from scratch except in certain circumstances, described later. The command structure to do this is quite straightforward, and we will illustrate it with an example where we create a d2d object.

::

   a=3.8; b=3.8; c=12.5;
   u0=[0,1,2,0];
   u1=[1,0,0,0];
   u2=[0,0,0,1];
   p1=[-1,0.05,1];
   p2=[0,1,100];
   w_2d=d2d([a,b,c,90,90,90],u0,u1,p1,u2,p2);


The parameters ``a``, ``b``, ``c`` are the lattice parameters. ``u0`` is the offset co-ordinates of the origin of all four axes, so in this case the reciprocal lattice points stated will be relative to **Q**\ =(0,1,2) and E=0. ``u1``. and ``u2`` give the directions of the axes for our object, so in this case one axis is energy and the other is (1,0,0). ``p1`` and ``p2`` are vectors of the form ``[lower limit, step, upper limit]``, i.e. they specify the range and step size of the object's variable axes.

In order to see the data within our d2d object ``w_2d`` we cannot just click on it in the Matlab workspace. We instead have to use the command

::

   array_out=get(w_2d)

which gives us a structure array called ``array_out`` which has the following fields:

::

   array_out =

	filename: ''
	filepath: ''
       title: ''
       alatt:[ 3.8000 3.8000 3.8000]
       angdeg: [90 90 90]
       uoffset: [0 1 2 0]
       u_to_rlu: [4x4 double]
	ulen: [1.6535 1.6535 0.5027 1]
       ulabel: {'\\zeta'  '\\xi'  '\\eta'  'E'}
       iax: [2 3]
       iint: [2x2 double]
       pax: [1 4]
       p: <1x2 cell>
       dax: [1 4]
       s: [41x101 double]
       e: [41x101 double]
       npix: [41x101 double]


It should be fairly clear what most of the fields of this structure array are, but it is useful to point out a couple of important ones now. ``ulen`` gives the conversion factor between reciprocal lattice units and :math:`\\AA^{-1}`. ``pax`` and ``iax`` tell us that the parameter axes are the 1st and 4th, and that the integration axes (i.e the fixed ones) are the 2nd and 3rd. The fields ``s`` and ``e`` are arrays which contain the scattering signal and the variance (i.e. the square of the errobar that is plotted). These arrays are filled with zeros when the object is created in this manner. The cell array called ``p`` contains two vectors which specify the bin boundaries of the pixels which were specified during the object creation. The ``pax`` and ``dax`` vectors respectively specify which of the axes (from the columns of ``u_to_rlu``) are variables (as opposed to being integrated over), and which way round the axes will be when plotted. Finally there is the array called npix. This tells us whether a pixel is contributing to the scattering, so it is 1 when the corresponding element of ``s`` is a number, and is zero if the corresponding element of ``s`` is NaN.

If you wish to create an sqw object then there are only two possible inputs you can give to the ``sqw`` command. You must supply either a file name, where sqw data can be found, or you can supply a structure array that has all of the appropriate fields for an sqw object in it. That is to say if you typed

::

   output=sqw(struc_array);


``struc_array`` would have to be the same as the structure array that would be returned when typing ``get(output)``.

The fields that should be present in the structure array associated with an sqw object are

::

   main_header <1x1 struct>
   header <nx1 cell>
   detpar <1x1 struct>
   data <1x1 struct>


The ``main_header`` structure array contains information about the sqw dataset from which the sqw object was derived, specifically the filename, file directory, information about the title (if any) and the number of SPE files used to generate the SQW file. For example the main_header array might look like this:

::

   filename 'w2a.sqw'
   filepath 'c:\\temp'
   title ''
   nfiles 186


The header cell array itself contains more structure arrays, one for each of the SPE files that contributed to the original SQW file. The fields of one of these structure arrays might look like this:

::

   filename 'map11014.spe'
   filepath 'C:\\mprogs\\demo\\'
   efix 787
   emode 1
   alatt [2.87 2.87 2.87]
   angdeg [90  90 90]
   cu [1 0 0]
   cv [0 1 0]
   psi 0
   omega 0
   dpsi 0
   gl 0
   gs 0
   en <167x1 double>
   uoffset [0; 0; 0; 0]
   u_to_rlu <4x4 double>
   ulen [1 1 1 1]
   ulabel <1x4 cell>


The detpar structure array contains information about all of the detectors, including the filename of the PAR file and the directory in which it is kept, plus information about the detector group, flight path, scattering angles phi and azimuth, the detector width, and the detector height. This might take the form:

::

   filename '9cards_4_4to1.par'
   filepath 'C:\\mprogs\\Horace\\demo\\'
   group <1x36864 double>
   x2 <1x36864 double>
   phi <1x36864 double>
   azim <1x36864 double>
   width <1x36864 double>
   height <1x36864 double>


Finally we have the data structure array. This contains much of the same information that was in the header cell array (specifically filename, directory, title, and lattice parameters). There is also some information that has the same field name as information in ``header``, but is not necessarily the same. An example of the full list of fields is:

::

   filename 'w2a.sqw'
   filepath 'C:\\mprogs\\Horace\\demo\\'
   title ''
   alatt [2.87 2.87 2.87]
   angdeg [90 90 90]
   uoffset [0; 0; 0; 0]
   u_to_rlu <4x4 double>
   ulen [3.0961 3.0961 2.1893 1]
   ulabel <1x4 cell>
   iax [1 3]
   iint [0.95 -0.05; 1.05 0.05]
   pax [2 4]
   p <1x2 cell>
   dax [1 2]
   s <21x60 double>
   e <21x60 double>
   npix <21x60 double>
   urange [0.95 -0.024995 -0.049953 52.5; 1.05 1.025 0.049953 312.5]
   pix <9x93270 double>


For this two-dimensional object the new fields are as follows: ``iax`` are the indices of the axes which are integrated over / held constant in the cut from the original 4-dimensional dataset. In this case the first and third axes are held constant. ``iint`` gives the ranges over which data are integrated to create a lower dimensional cut. ``pax`` gives the indices of the plot axes. ``p`` is a cell array whose elements are vectors, each of which describes the grid of bin boundaries from which the object's axes are constructed. ``dax`` details which way round the axes described in ``pax`` will be displayed when the object is plotted. In this case because it is [1 2] axis-2 will be horizontal and axis-4 will be vertical. ``s`` and ``e`` are arrays which give the intensity and variance (i.e. the square of the plotted errorbar) respectively for each bin. ``npix`` is an array which tells us how many pixels contributed to the intensity in each bin. ``urange`` gives the range of data in the object along each of the 4 axes, column-wise. Finally ``pix`` details all of the detector pixel information. It has 9 rows, which contain respectively the location in Cartesian Q-space + energy of each pixel (in inverse Angstroms and meV respectively), the index of the contributing SPE file, the index of the contributing detector, the index of the energy channel, the intensity counted in the pixel, and the error on the intensity in the pixel.


Reading and writing to file
===========================

One way of storing datasets that you've created is to save your Matlab workspace, however this may not always be the most efficient thing to do -- for example your Matlab workspace may contain lots of objects that you do not wish to save.

Horace allows you to write single objects into a binary file straightforwardly. Suppose you wish to save the d2d object we just created, ``w_2d``, in a file called ``my_saved_d2d``. All you have to do is type:

::

   save(w_2d, 'C:\\mprogs\\Horace\\demo\\my_saved_d2d.dat');


At a later time you may wish to read this object back into your Matlab workspace. To do this, simply use the command:

::

   w_2d_new = read_dnd ('C:\\mprogs\\Horace\\demo\\my_saved_d2d.dat');


Note that the commands ``save`` and ``read_dnd`` are methods specific to each kind of object (i.e. there is a ``save`` function in the @d0d,...,@d4d, @sqw directories). Also note that the file extension .dat does not have to be used. In fact it is probably a good idea to use the extensions .d0d,...,.d4d, or .sqw so that you can tell easily what sort of object has been saved by just looking at the filename.


Binary operations
=================

Horace allows you to perform simple binary arithmetic operations on dnd and sqw objects. There are a few constrains on how you can use these functions, however:

- You cannot perform arithmetic operations on objects of different dimensionality, e.g. you cannot subtract a d2d object from a d3d object.
- You can perform arithmetic operations on a dnd/sqw object and a scalar, e.g. you can add the number 3 to a d2d object -- this will add 3 to every element of the intensity array.
- The objects on which you are performing the arithmetic operation must have the same size, e.g. if adding two d2d objects they must both have intensities that are represented by arrays of the same size (in this case m-by-n matrices).
- You must be careful to notice that it is possible perform the operation on two objects that do not cover the same area in (**Q**,E)-space. This is fine if, for example, you wish to subtract the scattering around one value of **Q** from that around another. However it is in general advisable to be careful since you can end up adding/subtracting/etc spectra from completely different parts of reciprocal space that you maybe didn't want to...


A complete list of binary arithmetic operations can be found :ref:`here <manual/Binary_operations:Binary operations>`

Unary operations
================

One can also use Horace to perform unary mathematical operations, i.e. operations that act on a single object. An example would be ``cos``, which takes the cosine of the intensity at every point in a dnd/sqw object.

A full list of unary operations can be found :ref:`here <manual/Unary_operations:Unary operations>`.


Obtaining information about objects
===================================

There are several functions which one can use to find out general information about sqw and dnd objects, i.e. they print information to the Matlab command window that you would otherwise have to obtain by using the ``get`` command and then inspecting the resulting structure array.

You can get an object's header information by typing

::

   head(obj);


where ``obj`` can be any dnd or sqw. The command ``display`` does exactly the same thing. In order to find out the dimensionality of an sqw object you can use

::

   ndims=dimensions(obj);


and the number of dimensions will be returned. This method also exists for dnd objects, however it should not be possible for, say, a d2d object to contain anything other than 2-dimensional data.
If you have modified by hand an sqw or dnd object then you can check that the basic formatting has not been broken by typing

::

   [ok,mess]=isvalid(obj);

If the object is a valid sqw or dnd then the variable ``ok`` will be 'true' and the variable ``mess`` will be an empty string. Conversely if the object is not a valid type then the variables will be 'false' and will contain an error message detailing where the fault lies respectively.

In order to get direct access to the data, header information, etc. of an object there are two equivalent commands that you can use - ``get`` and ``struct``. Both commands return a structure array whose fields are main_header, header, detpar, and data, however these structure arrays are not protected in the same way that an sqw or dnd object would be. That is to say, you can edit them in any way you wish, and there are no internal checks to ensure that the data are consistent and of the correct format.

::

   get_struc=get(obj);
   struct_struc=struct(obj);


In the above ``get_struc`` and ``struct_struc`` are identical.

You can find out what the plot titles (i.e. axes' labels etc.) of an object are without plotting it by typing

::

   Output=plot_titles(obj);


The output returned provides (if such information exists) a vector ``[title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]`` where ``title_main`` is the title that would appear at the top of the plot, ``title_pax`` contains the annotations for each of the plot axes, ``title_iax`` contains the legend detailing the integration axes limits etc, ``display_pax`` is a cell array containing axes annotations for each of the plot axes suitable for printing to the screen, ``display_iax`` is a cell array containing axes annotations for each of the integration axes suitable for printing to the screen, and ``energy_axis`` gives the index of the column in the 4x4 matrix din.u that corresponds to the energy axis.


Reformatting the data
=====================

You can convert an sqw object into a dnd object (i.e. you throw away the individual pixel information) quite easily. You simply type

::

   dnd_out=dnd(sqw_obj);


If you do not know the number of dimensions of the object ``sqw_obj``. If you do know the number of dimensions (e.g. 2) then you can type

::

   d2d_out=d2d(sqw_obj);


One can also reformat a dnd object so that it is turned into an sqw object, although the pixel information will be empty. This is done by typing

::

   sqw_out=sqw(dnd_obj);


You can potentially reduce the amount of memory taken up by a dnd or sqw object by using the command ``compact``. This effectively squeezes the data along all of its dimensions so that the axes ranges are just enough to encompass all of the data, but not more. e.g.

::

   w_less_memory=compact(w);


One can permute the order of the axes for '''plotting purposes only''' by using the command ``permute``. e.g.

::

   w_permuted=permute(w,[3,1,2]);


The second argument of this function gives the order in which the new axes will be displayed for this 3-dimensional example object, i.e. what was previously the third plot axis will now be the first, the old first plot axis will now be the second, and the old second axis will be plotted as the third. Note that this command simply alters the ``w.data.dax`` field, i.e. it does not permute the dimensions of the intensity, error, etc. matrices.

One can take a section out of a dnd or sqw object using the command ``section``, e.g.

::

   w_sectioned=section(w,[ax1_lo,ax1_hi],[ax2_lo,ax2_hi],...);


so that the new object ``w_sectioned`` has the same dimensionality as the input object ``w`` but data is only kept if it is between ``ax1_lo`` and ``ax1_hiu`` for the first axis, and so on.

Finally, one can create higher dimensional datasets by using the command ``replicate``.

::

   wout=replicate(win,wref);


This function takes an input object ``win`` and maps it on to a higher dimensional dataset ``wref`` by repeating the data over the extra dimension(s). At present ``wout`` and ``win`` must be dnd objects, and NOT sqw objects, however ``wref`` can be either a dnd or an sqw.

Plotting
========

The command for default plotting is

::

   plot(obj);


which will produce an appropriate plot based on the dimensions of the object ``obj`` (i.e. a marker and line plot for 1-d, a colourmap for 2-d, and a sliceomatic colourmap for 3-d). Zero dimensional and 4-dimensional objects cannot be plotted, of course.

There are several different ways of plotting two- and one-dimensional data (e.g. with/without errorbars for 1d, etc.). One-dimensional data can be plotted using :ref:``dd, de, dh, dl, dm, dp, mp, pd, pe, peoc, ph, phoc, pl, ploc, pm, pmoc, pp`` and ``sp``, whereas two-dimensional data can be plotted using ``da, ds, mp`` and ``sp``, in addition to ``plot``. The differences between all of these plot commands is given in detail in the `plot functions <manual/List_of_functions:Plotting>` section of this manual. For three-dimensional data only the ``plot`` command exists, since Horace has only one way of plotting 3-d data.
Once a plot has been made there are various commands that can be used to alter its appearance (e.g. the axes, labels, etc.).

To alter the limits along the x, y, or z axes you use the commands ``lx, ly`` and ``lz``, e.g.

::

   lx 0 2
   ly -3 3
   lz 0 20


to change the limits along x to be 0 and 2, and so on.
To change the axes to log-scale, you use the commands ``logx, logy`` and ``logz``, and to change to a linear scale you use ``linx``\ ...etc. A full list of formatting options can be found `here <http://www.libisis.org/User_Manual#Plot_Commands>`__.

Fitting
=======

You can also use Horace to fit your data. It can take quite a long time for the fit to converge, so it is therefore a good idea to provide a good initial guess of the fit parameters. You can work these out simulating and then comparing the result to the data by eye.

For an introduction and overview of how to use the following fitting functions, please read :ref:`Fitting data <manual/Multifit:Multifit>`. For comprehensive help, please use the Matlab documentation for the various fitting functions that can be obtained by using the ``doc`` command, for example ``doc d1d/multifit`` (for fitting function like Gaussians to d1d objects) or ``doc sqw/multifit_sqw`` (fitting models for S(Q,w) to sqw objects).


Simulating
==========

There are two functions used for doing simulations - ``func_eval`` and ``sqw_eval``. The difference between these two functions is relatively minor, and relates to the format of the function that you wish to simulate.

::

   wout1=func_eval(win, func_handle, pars, options);
   wout2=sqw_eval(win, sqw_func_handle, pars, options);

In both cases in the above example ``win`` can be an sqw or dnd dataset, that is used as a template to tell Horace where to simulate the intensity. There is just one option available for both ``func_eval`` and ``sqw_eval``, and that is 'all', which has the same meaning as when it is used in conjunction with ``multifit``.
The essential difference comes for the function used to simulate the data. For ``func_eval`` the format is the same as for ``multifit``, specifically the first few input arguments of the function are arrays, all of which have the same number of elements as there are data points. For a 2-dimensional object there would be two such arrays, for a 3-dimensional one there would be three, and so on. Furthermore the arrays are just the axes of the input object, i.e. ``win.data.p{1}, win.data.p{2},...``.
The arrays input to the ``sqw_eval`` function are different, because there must always be 4 arrays before the input parameters are given. The 4 arrays correspond to the values of the Miller indices h, k, and l; plus energy. The 4 arrays are always supplied, even if the dimensionality of the object to be simulated is lower than 4 -- in this case the values of all of the elements for one or more of the arrays will all be the same. This means that the same function can be used to simulate datasets of different dimensionality with the same model, without having to re-write the function each time. It is also useful if you have a model, such as a spin-wave model, where the calculation is easier if the co-ordinate system is (H,0,0) / (0,K,0) / (0,0,L).

Further information concerning simulations can be found in the :ref:`Simulations <LoF_Fitting>` section of the list of functions.

SQW generation and manipulation
===============================

When converting a series of SPE files into a single SQW file there are only a few commands that you ever need to use. The first is ``gen_sqw``:

::

   [tmp_file,grid_size,urange] = gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
						 u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in);


This is the full syntax for the :ref:``gen_sqw`` command. At its most basic it can be used without output arguments, and without the input arguments ``grid_size_in`` and ``urange_in``. The other input arguments take the form given `here <Generating_SQW_files:Generating SQW files>`.
There are two additional circumstances in which you would not wish to use ``gen_sqw``. The first is if, for some reason, the ``gen_sqw`` command has failed (usually due to low-level problems between Matlab and your computer's operating system), and the second is if you wish to view data ''on the fly'' whilst the experiment is still running. In both circumstances a time saving is involved because you do not have to rewrite all of the intermediate TMP files.
If ``gen_sqw`` has failed after creating all of the necessary TMP files (i.e. one TMP file for every SPE file) then the command to use is

::

   write_nsqw_to_sqw(tmp_files, sqw_file);


where ``tmp_files`` is a cell array, each element of which gives the full filename of one of the TMP files, and ``sqw_file`` is a string giving the full filename of the SQW file you wish to create. This function does the last part of the job of ``gen_sqw``, i.e. it takes data from the TMP files and writes them into the SQW file.
If not all of the TMP files were written before ``gen_sqw`` failed, or if you are generating data ''on the fly'', then before using ``write_nsqw_to_sqw`` you must first make sure all of the necessary TMP files exist. The function that does this is ``write_spe_to_sqw``, and it is used as follows:

::

   [grid_size, urange] = write_spe_to_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
						      u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)


where the input arguments take the same meaning as with ``gen_sqw``, except that ``sqw_file`` should be a string giving the full filename of a TMP file, and ``spe_file`` is a string giving a single SPE filename. This means that in order to generate more than one TMP file this command must be run in a loop.
If you are generating TMP files in this way then it is important to ensure that the ``urange_in`` argument is supplied. If not then the data range of each TMP file will be different, since by default the program will choose the minimum range that includes all of the data. This will then prevent the information in the TMP files from being collated into a single SQW fille. There are two ways to ensure this problem does not arise. The simplest is just to choose a range (along all 4 axes) for the data, in which case you give

::

   urange_in=[ax1_lo, ax2_lo, ax2_lo, ax4_lo; ax1_hi, ax2_hi, ax3_hi, ax4_hi];


Alternatively you can calculate what would be the range of the smallest hypercuboid that contains all of the data (this is what is done internally by gen_sqw). To do this you type

::

   urange_in=calc_sqw_urange(efix, emode, eps_lo, eps_hi, det, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)


where ``efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl``, and ``gs`` have the same form as when they are used in ``gen_sqw``. Note that the vector ``psi`` should contain all of the values you wish to use for the whole experiment, not just the ones you have already got data for. E.g. you may have measured from Psi=0 to Psi=60 in 2 degree steps, but you may wish to go to Psi=120, in which case you should put ``psi=[0:2:120]``. If you are unsure of what range of Psi you will actually use then you should use a conservative estimate, the most pathological of which would be to have ``psi=[0:360]``. In reality it is a good idea to avoid such a case, because the final data file will have large parts which are devoid of any actual data but still take up quite a large amount of disk space on your computer. Also note that ``eps_lo`` and ``eps_hi`` are respectively the minimum and maximum energy transfers you wish to include (in meV).
