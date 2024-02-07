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

