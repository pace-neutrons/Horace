############################################################################################################
Special ``SQW`` information from sqw objects and files
############################################################################################################

.. |SQW| replace:: S(**Q**, :math:`\omega{}`)
.. |Q| replace:: :math:`|\textbf{Q}|`


``sqw`` or ``dnd`` objects in memory are normal MATLAB objects, so they can be converted into structure for analysis. 
The objects contain complex information including service information, so converting them into structure may return
a lot of unnecessary and unclear information. This is why MATLAB normally warns you against applying ``struct`` 
function to an object.

To return full essential information about Horace objects in memory, one may use ``to_struct`` method. 
Majority of Horace objects are ``serializable`` objects, which means they may be converted into linear sequence of 
bytes and reconstruct from this sequence. 
``to_struct`` method is used for converting object into a structure containing information, sufficient for recovering
``sqw`` or ``dnd`` object from this information. 
 
 Number of additional commands exist for extracting information essential for physical problem or some special purposes.
 
.. note::

   The commands described here work on object in memory and return information about part of the object, placed in memory.
   If they applied to a file-backed object or object which would not fit memory, they return different forms of 
   references to the part of the information remained in file.
   

head
===========

Gets the principal information about binary ``.sqw`` or ``.dnd`` file at the location given
in ``filename`` or in the object, specified as input.

If the option ``'-full'`` is used, then the full set of header information,
rather than just the principal header, is returned. Equivalent usage forms are:

.. code-block:: matlab

   info = head(filename[,'-full']);
   info = head(obj,[,'-full']);
   info = obj.head(['-full']);   

where ``obj`` is an ``sqw`` or ``dnd`` object.

If applied to file, the main use of this function is to determine whether or not the file contains
an ``sqw`` or a ``dnd`` object. It also returns general information about the contents of the
this object, i.e. data ranges, number of pixels in ``sqw`` file etc., whatever developers decided 
most important for user to know about correspondent object.

Note, that the outputs from calling ``head(filename);`` and ``res = head(filename)`` differ:

>> ``head(filename);`` **"Scientific" view:**

.. code-block:: matlab

    >> head('sqw_1d_2.sqw');
    1-dimensional object:
    -------------------------
    Original datafile:  ...\Horace\_test\common_data\sqw_1d_2.sqw
                Title: <none>

    Lattice parameters (Angstroms and degrees):
        a=2.87           b=2.87            c=2.87
    alpha=90          beta=90          gamma=90

    Extent of data:
    Number of spe files: 186
        Number of pixels: 4324

    Size of 1-dimensional dataset: [21]
        Plot axes:
            \xi = -0.525:0.05:0.525 in [1, \xi, 0]
        Integration axes:
            0.95 =< \zeta =< 1.05 in [\zeta, 0, 0]
            -0.05 =< \eta =< 0.05 in [0, 0, \eta]
            150 =< E =< 160
    Object is stored in Horace-2 format file     % what version of Horace produced this file

>> ``res = head(filename)`` **"Programmer's" view:**

.. code-block:: matlab

    ss = 
        struct with fields:                                   
             filename: 'sqw_1d_2.sqw'                          % Name of the file containing the object
             filepath: '...\Horace\_test\common_data'          % path to the file containing the object
                title: ''                                      % Title to be displayed when object is plotted
                alatt: [2.8700 2.8700 2.8700]                  % 3-element array of lattice parameters
               angdeg: [90 90 90]                              % 3-element array of lattice angles
               offset: [0 0 0 0]                               % Image offset from point [0,0,0,0] in reciprocal space defined by lattice
             u_to_rlu: [4×4 double]                            % 4x4 matrix used for conversion from pixel to image coordinate system (for line_proj) 
                 ulen: [3.0961 3.0961 2.1893 1]                % scales used in conversion from pixel to image coordinate system (axes units)
                label: {'\zeta'  '\xi'  '\eta'  'E'}           % axes labels
                  iax: [1 3 4]                                 % what directions of full 4-dimensional dataset are integrated
                 iint: [2×3 double]                            % [2 x numel(iax)] array of image integration ranges (parts of img_range)
                  pax: 2                                       % what direction of full 4-dim dataset is binned
                    p: {[-0.5250 -0.4750  … ] (1×22 double)}   % [1 x numel(pax)] cellarray of  binning ranges for each binned direction
                  dax: 1                                       % order of displaying axis  among all binned axes
            img_range: [2×4 double]                            % Ranges of the image dimensions including integrated and binned dimensions
           dimensions: 1                                       % Number of image dimensions (binned dimensions)
        creation_date: ''                                      % Date the sqw object was created. Valid for Horace-4 objects only.
              npixels: 4324                                    % Number of pixels (neutron events) stored in dataset
    num_contrib_files: 186                                     % Number of source files (runs) contributed into the dataset
           data_range: [2×9 double]                            % 2x9 array of min/max ranges of Pixel data. Valid for Horace-4 only
      faccess_version: 2                                       % version of class used to access data. Usually corresponds to Horace version.


legacy equivalents of ``head``
------------------------------

Number of methods were used in the past to retrieve information similar to the information returned by ``head`` function. 
These methods are still available and work as before repeating the operations, performed by ``head`` function.
These methods are: ``head_horace``, ``head_dnd`` and ``head_sqw``. Internally these methods are interfaces to ``head`` function. 


xye
===

Extract the bin centres, intensity and standard errors from an sqw or dnd
object.

.. code-block:: matlab

   S = xye(object);


The output is a structure with fields:

- ``S.x`` - vector of bin centres if a 1D object, or cell array of vectors
  containing the bin centres along each axis if 2D, 3D or 4D object

- ``S.y`` - array of intensities

- ``S.e`` - array of estimated error on the intensities


save_xye
========

Save an ``sqw`` or ``dnd`` object to an ascii format file at the location
``filename``.

.. code-block:: matlab

   save_xye(object, filename);

The format of the ascii file for an n-dimensional dataset is n columns of
co-ordinates along each of the axes, plus one column of signal and another
column of error (standard deviation).



..
    hkle
    ====

    Obtain the reciprocal space coordinate :math:`[h,k,l,e]` for points in the
    coordinates of the display axes for an ``sqw`` object

    .. warning::

       This extracts data only from an ``sqw`` derived from a single ``.spe`` file

    .. code-block:: matlab

        [qe1, qe2] = hkle(object, x)


    The inputs take the form:

    * ``w``

      sqw object

    * ``x``

      Vector of coordinates in the display axes of an sqw object. The number of
      coordinates must match the dimensionality of the object. e.g. for a 2D sqw
      object, ``x = [x1,x2]``, where ``x1``, ``x2`` are column vectors. More than
      one point can be provided by giving more rows e.g. ``[1.2,4.3; 1.1,5.4; 1.32,
      6.7]`` for 3 points from a 2D object. Generally, an (``n`` x ``nd``) array,
      where ``n`` is the number of points, and ``nd`` the dimensionality of the
      object.

    The outputs take the form:

    * ``qe1``

      Components of momentum (in rlu) and energy for each bin in the
      dataset. Generally, will be (n x 4) array, where n is the number of points

    * ``qe2``

      For the second root

