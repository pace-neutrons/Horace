###########################################################
Manipulating and extracting data from SQW files and objects
###########################################################

cut_sqw
=======

There are various different forms of input for this function, the purpose of which is to take data from an SQW file and turn it into a n-dimensional cut which can be plotted, manipulated, etc. The "compulsory" inputs are given as follows:

::

   my_cut = cut_sqw (data_source, proj, p1_bin, p2_bin, p3_bin)


Where ``data_source`` is either a string giving the full filename (including path) of the input SQW file or just the variable containing SQW object stored in memory.

** Projection **

This defines the coordinate system you will use to view the data.

:ref:``proj`` is an instance of ``ortho_proj`` class containing information about the axes and the coordinate system you wish to use to view the data. You can also use the structure, with the same fields as the ``ortho_proj`` class, but using the class is usually easier as the class properties are verified on consistency by class-properties setters and contain reasonable defaults. Because each point in the SQW file is labelled with h, k, and l (the reciprocal lattice vectors) and energy, it is possible, if you wish, to redefine the coordinate system with the one of your choice. For example you may wish to view the data in terms of (h,h,0)/(h,-h,0)/(0,0,l). This is distinct from the vectors ``u`` and ``v`` that are specified in `gen_sqw <List_of_functions:gen_sqw>`, which describe how the crystal is oriented with respect to the spectrometer and are determined by the physical orientation of your sample.

**Orthogonal axes case**

The ``proj`` structure has several fields:
- ``proj.u`` is a 3-component vector of the form (h,k,l) which specifies the first viewing axis.
- ``proj.v`` is another 3-component vector of the same type which determines the second viewing axis: it is constructed to be in the plane of ``proj.u`` and ``proj.v`` and perpendicular to ``proj.u``.
The program then automatically calculates the third viewing axes to be the cross product of the first two. The 4th axis is always energy and need not be specified.
There are optional fields too:
- ``proj.uoffset``, specifies an offset for all cuts, which is a 3-component vector in [h,k,l] or a 4-vector [h,k,l,e]. For example you may wish to make the origin of all your plots (2,1,0), in which case set ``proj.uoffset=[2,1,0]``.
- ``proj.type`` specifies a three character string denoting the unit of measure along each of the three Q-axes, one character for each axis. If you want an axis to be displayed in inverse Angstroms, set the character to 'a'. For r.l.u. set the corresponding character to 'r' (which normalises so that the maximum of \|h|,|k\| and \|l\| is unity) or 'p' (which preserves the values of ``proj.u`` and ``proj.v``. For example, if we wanted the first two Q-components to be in r.l.u. and the third to be in inverse Angstroms we would have ``proj.type='rra'``.
- ``proj.lab1='labelname'`` supplies a label for the first projection axis, and ``proj.lab2='labelname'`` supplies a label for the second etc.s.

**Non-orthogonal axes case**

In the case when the crystal lattice is not orthogonal there are two options for viewing the data. In the default case the ``proj`` is specified in the same way as above, however remember that, for example, if proj.u = (1,0,0) and proj.v=(0,1,0), but (1,0,0) and (0,1,0) are not orthogonal in reciprocal space, the second viewing axis will actually be the vector orthogonal to proj.u in the plane of proj.u and proj.v. The third axis is then the cross product as before.

You may optionally choose to use non-orthogonal axes, as in the following example. Specify proj.u = (1,0,0), proj.v=(0,1,0), ``proj.nonorthogonal = true`` (and optionally specify the third projection axis by setting ``proj.w=[0,0,1]``). This forces the axes to be the ones you define, even if they are not orthogonal. Beware the plots that are produced plot them as orthogonal axes so any features may be skewed. However, it does make reading the location of a feature in a two-dimensional Q-Q plot straightforward, which is the main reason for doing this.

**Binning arguments**

- ``p1_bin``, ``p2_bin``, ``p3_bin`` and ``p4_bin``  specify the binning / integration arguments for the Q&Energy axes in the target coordinate system. Each can independently have one of four different forms:
   - If a single number (scalar) ``step`` is given then that axis will be a plot axis and the bin width will be the number you specify. The lower and upper limits are determined by the extent of the data along that direction.
   - If you specify a vector with three components, namely ``[lower,step,upper]`` than that axis is a plot axis with the first ``lower`` and the last ``upper`` components specifying the centres of the first and the last bins of the data to be cut. The middle component specifies the bin width. The limits of the data to be cut are then lie between ``min = lower-step/2`` and ``max = upper+step/2``, including ``min/max`` values. If step in this form equal to 0, the step is taken from the input binning in this direction.
   - If you specify a vector with two components then the signal will be integrated over that axis between limits specified by the two components of the vector.
   - Four elements vector define multiple cuts with multiple integration limits in the selected direction. The input
   would have form ``[plo, rdiff, phi, rwidth]`` This defines an integration axis: minimum range center, distance between range centers, maximum range center, range size for each cut. The number of cuts produced will be the number of ``rdiff`` sized steps between ``plo`` and ``phi``; ``phi`` will be automatically increased such that ``rdiff`` divides ``phi - plo``.
   For example, ``[106, 4, 113, 2]`` defines the integration range for three cuts, the first cut integrates the axis over ``105-107``, the second over ``109-111`` and the third ``113-115``.


**Optional arguments**

::

   my_cut = cut_sqw (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin, '-nopix', filename)


- ``'-nopix'`` means that the individual pixel information contributing to the resulting data is NOT retained (at present the default is to retain it, resulting in an output that is an sqw object, whereas using ``'-nopix'`` gives a dnd output).
- ``filename`` is a string specifying a full filename (including path) for the data to be stored, in addition to being stored in the Matlab workspace.

cut
===

This is a specific case of cut_sqw that can be used to take cuts from sqw objects that are already in memory, rather than on disk in the SQW file. Such objects can either be the result of using cut_sqw, or if have been read into memory from disk using the read_horace function

To take a cut from an existing sqw or dnd object, retaining the existing projection axes and binning:

::

   w1=cut(w,[],[lo1,hi1],[lo2,hi2],...)


Note that the number of binning arguments need only match the dimensionality of the object ``w`` (i.e. the number of plot axes), so can be fewer than 4. Note also that you cannot change the binning in a dnd object, i.e. you can only set the integration ranges and have to use ``[]`` for the plot axis. The only option you have is to change the range of the plot axis by specifying ``[lo1,0,hi1]`` instead of ``[]`` (the '0' means 'use existing bin size')

To take a cut from an existing sqw object and change the binning along one or more of the plot axes:

::

   w1=cut(w, p1_bin, p2_bin,....)


where ``pbin_1``, ``pbin_2``,... have the same form as for cut_sqw described above, and there are as many binning arguments as the dimensionality of the object. This is essentially the same syntax as ``cut_sqw``, but with an sqw object rather than an SQW file as the first input, and the projection axes left unchanged. The same set of optional arguments, namely ``'-nopix'`` and ``filename`` also applies.

To take a cut from an existing sqw object and change the plot axes (i.e. use a new set of projections):

::

   w1=cut(w, proj, p1_bin, p2_bin, p3_bin, p4_bin)


where ``pbin_1``, ``pbin_2``,... have the same form as for cut_sqw described above, and there are as many binning arguments as the dimensionality of the object. This is essentially the same syntax as ``cut_sqw``, but with an sqw object rather than an SQW file as the first input. The same set of optional arguments, namely ``'-nopix'`` and ``filename`` also applies.


head_horace
===========

::

   info=head_horace(filename);

   info=head_horace(filename,'-full')


This is a function to give the header information in an SQW file or file to which an sqw object or dnd object has been saved, and whose full filename is given by the argument ``filename``. If the option ``'-full'`` is used then a fuller set of header information, rather than just the principal header, is returned. The purpose of this function is to read the contents regardless of your knowledge of whether or not the file contains an sqw object or a dnd object.


head_sqw
========

::

   info=head_sqw(filename);

   info=head_sqw(filename,'-full')


This is a function to give the header information in an SQW file or file to which an sqw object has been saved, whose full filename is given by the argument ``filename``. If the option ``'-full'`` is used then a fuller set of header information, rather than just the principal header, is returned.


head_dnd
========

::

   info=head_dnd(filename);


This is a function to give the header information in file to which a dnd object has been saved, whose full filename is given by the argument ``filename``.

read_horace
===========

::

   output=read_horace(filename);


This is a function to read sqw or dnd data from a file. The object type is determined from the contents of the file. If the file contains a full sqw dataset (whether created using gen_sqw or as the result of saving a cut), the returned variable is an sqw object; if the file contains a dnd dataset, the output is the corresponding d01, d1d, ...or d4d object.

read_sqw
========

::

   output=read_sqw(filename);

This is a function to read sqw data from a file. Note that in this context we mean an n-dimensional dataset, which includes pixel information, that has been saved to file. This could be either a full SQW file created wusing gen_sqw, or an sqw dataset that has been saved to file. The object ``output`` will be an sqw object.


read_dnd
========

::

   output=read_dnd(filename);


Exactly the same as above, but reads dnd data saved to file. If the file contains full sqw dataset, then it will be read as if it contained just a dnd dataset.


save
====

::

   save(object,filename)


Saves the sqw object or dnd object ``object`` from the Matlab workspace into the file specified by ``filename``.


save_xye
========

Save data in an sqw or dnd dataset to an ascii file.

::

   filename='C:\\mprogs\\my_ascii_file.txt';
   save_xye(w_in,filename);


The format of the ascii file for an n-dimensional dataset is n columns of co-ordinates along each of the axes, plus one column of signal and another column of error (standard deviation).


xye
===

Extract the bin centres, intensity and standard errors from an sqw or dnd object.

::

   S=xye(w);


The output is a structure with fields S.x (bin centres if a 1D object, or cell array of vectors containing the bin centres along each axis if 2D, 3D or 4D object), S.y (array of intensities), S.e (array of estimated error on the intensities).


hkle
====

Obtain the reciprocal space coordinate [h,k,l,e] for points in the coordinates of the display axes for an sqw object **from a single spe file**

::

    [qe1,qe2] = hkle(w,x)


The inputs take the form:

``w`` - sqw object
``x`` - Vector of coordinates in the display axes of an sqw object. The number of coordinates must match the dimensionality of the object. e.g. for a 2D sqw object, ``x=[x1,x2]``, where ``x1``, ``x2`` are column vectors. More than one point can be provided by giving more rows e.g. ``[1.2,4.3; 1.1,5.4; 1.32, 6.7]`` for 3 points from a 2D object. Generally, an (n x nd) array, where n is the number of points, and nd the dimensionality of the object.

The outputs take the form:


``qe1`` - Components of momentum (in rlu) and energy for each bin in the dataset. Generally, will be (n x 4) array, where n is the number of points

``qe2`` - For the second root
