###################
Symmetry Operations
###################

Symmetry Operators
==================

Symmetry operators or "sym op"s define the transformation between sets of symmetry related sets. In Horace these are
implemented as the ``Symop`` class, which is subclassed to represent the three basic forms of symmetry operations:

- ``SymopReflection``
    A reflection across a plane
- ``SymopRotation``
    A rotation about an axis
- ``SymopGeneral``
    A general matrix transform which may be the product of a series of reflections and rotations

Symmetry operators are, by definition, non-scaling transformations and as such must have a determinant of ``1``
(Rotation) or ``-1`` (Reflection).


Reflections
-----------

Reflections are implemented as the ``SymopReflection`` class and are defined in Horace by three 3-vectors. Two vectors
which define the plane of reflection, and a vector which defines a point on the plane (the offset). The constructor for
a ``SymopReflection`` is as follows:

::

   SymopReflection(v1, v2, offset)
   >> sym = SymopReflection([1 0 0], [0 1 0], [0 0 0]); % Reflection across the Z axis

**N.B.** For any ``Symop`` constructor the offset can be omitted and it will default to ``[0 0 0]``.

Rotations
---------

Rotations are implemented as the ``SymopRotation`` class and are defined by two 3-vectors and a scalar. These are the
axis of rotation, the angle (in degrees) of rotation and a point on the axis (the offset). The constructor for a
``SymopRotation`` is as follows:

::

   SymopRotation(axis, angle, offset)
   >> sym = SymopRotation([0 0 1], 60, [0 0 0]); % Rotation of 60 degrees about th Z axis

``SymopRotation`` also provides a convenience method for generating the appropriate set of symmetry operations for
cutting/reducing an n-Fold rotationally symmetric dataset about an axis. This takes a scalar integer and two
3-vectors. The number of reductions (for an angle of ``360/nFold`` each time) and the axis and offset of the rotation as
above.

::

   SymopRotation.fold(nFold, axis, offset)
   >> sym = SymopRotation.fold(4, [0 0 1], [0 0 0]);   % Ready to cut from a 4-fold rotationally symmetric dataset about Z


General Transformations
-----------------------

Generalised matrix transforms are implemented as the ``SymopGeneral`` class and are defined by a 3x3 matrix and a
3-vector. These are the transform itself and the offset. The constructor for a ``SymopGeneral`` is as follows:

::

   SymopGeneral(matrix, offset)
   >> sym = SymopGeneral([0 1 0
                          1 0 0
                          0 0 1], [0 0 0]); % Reflection across y=x

It should be noted that it is possible to get the general transformation from any of the other transformation types by
applying the transform to the identity (for which ``R`` is a convenience property)

::

   >> sym = SymopRotation([0 1 0], 90, [0 0 0]);
   >> sym.R

    ans =

        0.0000         0    1.0000
             0    1.0000         0
       -1.0000         0    0.0000

   >> sym.transform_vec(eye(3))

    ans =

        0.0000         0    1.0000
             0    1.0000         0
       -1.0000         0    0.0000

Groups of symmetry operators
----------------------------

For a more complex transformation involving a series of rotations and reflections it is possible to construct an array
of transformations to be applied in sequence (as a series of pre-multiplications, i.e. applied in the reverse order of
the list).

::

   % Rotate 90 deg about X, Reflect across X, Rotate back 90 deg about X
   >> big_sym = [SymopRotation([1 0 0], 90), SymopReflection([0 1 0], [0 0 1]), SymopRotation([1 0 0], -90)];


Commands for cuts and slices
============================

In Horace it is possible to symmetrise both whole S(**Q**, w)s and also to symmetrise cuts to extract data as though the
S(**Q**, w) had been symmetrised without the overhead of transforming all pixels, only those that might contribute to
the result.

Symmetric cuts
--------------

In order to do a symmetrised cut, the ordinary ``cut`` function (see :ref:cut) is used with the appropriate symmetry
operations additionally passed into the function as an argument after the bin axes specification (see example
below). The ``cut`` operation will then use the symmetry operations to compute the transformations of the given
projection, accumulate the symmetrically-related pixels into the primary binning axes and transform their pixel
coordinates according to the symmetry operations as though the S(**Q**, w) had been wholly symmetrised.

::

   >> w1 = sqw(data);
   >> sym = SymopReflection([0 1 0], [0 0 1]);

   % Cut from 1 to 3 in X, accumulated with -1 to -3 reflected across the X-axis
   >> w2 = cut(w1, ortho_proj([1 0 0], [0 1 0]), [1 0.1 3], [-inf inf], [-inf inf], [-inf inf], sym);
   >> w3 = cut(w1, ortho_proj([1 0 0], [0 1 0]), [1 0.1 3], [1 0.1 3], [-inf inf], [-inf inf], sym)

Symmetrise entire SQW
=====================

``symmetrise_sqw``
------------------

It is possible to reduce an entire dataset at once by symmetry, transforming all pixels according to the symmetry
operations and accumulating the transformed pixels into the bins appropriately. This is done through the
``symmetrise_sqw`` function, the signature for which is below:

::

   >> w1 = sqw(data);
   >> sym = SymopReflection([0 1 0], [0 0 1]); % Reflect about X-axis
   >> w2 = symmetrise_sqw(w1, sym);

It is also possible to reduce data through a rotationally symmetric operation, this can be done in one of 2 ways:

::

   >> w1 = sqw(data);
   >> sym = SymopRotation([0 0 1], 60);  % Perform a 6-fold symmetric roation about Z
   >> w2 = symmetrise(w1, sym);
   >> sym = SymopRotation.fold(6, [0 0 1]); % Same as above
   >> w3 = symmetrise(w1, sym);
   >> equal_to_tol(w2, w3);

     ans =

       logical

        1

A ``SymopRotation`` attempts to map the data into the positive quadrant (though for angle > 90 degrees | folds < 4, this
will fill the positive quadrant and spill into a negative domain).

``gen_sqw``
-----------

If you need to symmetrise a large ``sqw`` object, it can be done during ``sqw`` generation, i.e. during generation of
the ``sqw`` file. The ``gen_sqw`` function has a special option ``transform_sqw`` which can be used with any method,
transforming an S(**q**, w) at generation time.

For example:

::

   sym = SymopReflection(v1, v2, offset);
   gen_sqw (spefile, par_file, sym_sqw_file, efix, emode, alatt, angdeg,...  u, v, psi, omega, dpsi, gl,
            gs, 'transform_sqw', @(x)(symmetrise_sqw(x,sym)))


or, more generally:

::

   gen_sqw (spefile, par_file, sym_sqw_file, efix, emode, alatt, angdeg,...  u, v, psi, omega, dpsi, gl,
            gs, 'transform_sqw', @user_symmetrisation_routine)


where ``spefile``, ``par_file``, etc... are the options used during initial *sqw* file generation (see :ref:`Generating
SQW files <manual/Generating_SQW_files:Generating SQW files>`). The first ``gen_sqw`` would build a ``.sqw`` file
reflected as in the example for the reflection above. In the second, more general, case the user defined function (in a
``.m``-file on the Matlab path) can define multiple symmetrisation operations that are applied sequentially to the entire
data. An example is as follows, which folds a cubic system so that all eight of the symmetrically equivalent (1,0,0)
type positions are folded on to each other:

::

   function wout = user_symmetrisation_routine(win)

   wout=symmetrise_sqw(win, SymopReflection([1,1,0], [0,0,1]));%fold about line (1,1,0) in HK plane
   wout=symmetrise_sqw(wout,SymopReflection([-1,1,0],[0,0,1]));%fold about line (-1,1,0) in HK plane
   wout=symmetrise_sqw(wout,SymopReflection([1,0,1], [0,1,0]));%fold about line (1,0,1) in HL plane
   wout=symmetrise_sqw(wout,SymopReflection([1,0,-1],[0,1,0]));%fold about line (1,0,-1) in HL plane


**Note 1**: When defining the function to apply the symmetrisation (as above) one can ONLY use
 symmetrisation operations, given by ``symmetrise_sqw``. Any other transformations may modify the data ranges in
 unexpected ways, making the resulting transformed *sqw* file into complete nonsense!

**Note 2**: MPI workers are normal Matlab sessions which inherit basic Matlab path and initiate Horace themselves if the
 Horace path is not stored by the user (It's not usually recommended and may be impossible for multiuser machines). The
 workers do not process Matlab's ``startup.m`` file. The user's symmetrisation routine has to be available on the worker's
 Matlab path. The best way to achieve this is to put the routine into current Matlab working folder -- the folder
 from which you run the symmetrisation. If this routine uses some additional user functions, located elsewhere
 on a custom user path, these routines have to be intialised by the user routine. This can be achieved by the following
 piece of code added to the beginning of your custom symmetrisation routine:

::

   if isempty(which('my_additional_user_routine')) addpath('/home/myFedID/path_to_my_additional_user_routine'); end


Alternatively with an array of ``Symop``s this could be done in one step as:

::

   sym = [SymopReflection([1,1,0], [0,0,1])
          SymopReflection([-1,1,0],[0,0,1])
          SymopReflection([1,0,1], [0,1,0])
          SymopReflection([1,0,-1],[0,1,0])];
   gen_sqw (spefile, par_file, sym_sqw_file, efix, emode, alatt, angdeg,...  u, v, psi, omega, dpsi, gl,
            gs, 'transform_sqw', @(x)(symmetrise_sqw(x,sym)))


Combining
=========

::

   wout=combine_sqw(win)


Combine two sqw objects (w1 and w2) of the SAME dimensionality into a single sqw object in order to improve
statistics. The output object will have a combined value for the integration range e.g. combining two 2d slices taken at
L=1 and L=2 will result in an output for which the stated value of L is L=1.5. Two objects which use different
projection axes can be combined. The output object will have the projection axes of w1.

Rebinning
=========

Resize the bin boundaries along one or more axes, and rebin the data accordingly. There are several possibilities for
the input format:

::

   wout = rebin_sqw(win,step1,step2,...)


Rebin the sqw object ``win`` with bins along the first axis that have width ``step1``, bins along the second axis (if
there is one) with width ``step2``, and so on. The original limits of the axes will be retained. To leave an axis
unaltered, the corresponding step argument can be set to 0.

::

   wout = rebin_sqw(win,[lo1,step1,hi1],[lo2,step2,hi2],...)


As above, but specifying new upper and lower limits along each of the axes to be rebinned.

::

   wout = rebin_sqw(win,w2)


Rebin the sqw object ``win`` with the boundaries (and projection axes) of the template object ``w2``.


Symmetrise data, then unfold back to original range
===================================================

**N.B.** For producing plots only, any analysis on these results will be invalid due to double / treble / etc. counting
 of data.

Below we show a script that uses the ``symmetrise_sqw`` and ``combine_sqw`` commands to fold a dataset and then
unfold. In the example we have a constant energy slice in the (h,k)-plane which we fold twice to obtain the positive
quadrant. We then unfold the result in the opposite direction and combine with the positive quadrant, then unfold this
and combine. This produces an image which covers all four quadrants with suitably folded versions of just one of the
quadrants.

::

   %The original data
   proj2 = ortho_proj([1,0,0], [0,1,0]);
   hkplane = cut_sqw(sqw_file,proj2,[-2,0.05,2],[-2,0.05,2],[-0.05,0.05],[13,16]);
   plot(smooth(d2d(hkplane)));

   %Fold twice to get into a quadrant. Note order of vectors
   sym = [SymopReflection([0,0,1],[0,1,0])
          SymopReflection([1,0,0],[0,0,1])];
   fold2 = symmetrise_sqw(hkplane,sym);

   %Check the result
   plot(smooth(d2d(fold2)));

   %Fold this back again (reverse order of vectors in first fold)
   sym = SymopReflection([0,1,0],[0,0,1]);
   fold2a = symmetrise_sqw(fold2,sym);
   plot(smooth(d2d(fold2a)))

   %Combine with what you started with
   combi1 = combine_sqw(fold2,fold2a);
   plot(smooth(d2d(combi1)));

   %Fold back again (reverse order of vectors in second fold)
   sym = SymopReflection([0,0,1],[1,0,0]);
   fold3a = symmetrise_sqw(combi1, sym);
   plot(fold3a)

   %Combine and plot
   combi2 = combine_sqw(combi1,fold3a);
   plot(smooth(d2d(combi2)));


Correcting for magnetic form factor
***********************************

Horace allows basic correction of scattering intensity from simple ions by adjusting it by the magnetic form factor
according to formulas provided in International Tables of Crystallography, Vol C. (see, for example `here
<https://www.ill.eu/sites/ccsl/ffacts/ffachtml.html>`__)

The class ``MagneticIons`` contains the tables of fitting parameters, used to calculate changes in scattering intensity
due to changes in magnetic form factor and defines the method ``correct_mag_ff``, which takes an ``sqw`` object as input
and returns a similar object, with intensities adjusted by the magnetic form factor:

::

   mff = MagneticIons('Fe0');
   w2_fixed = mff.correct_mag_ff(w2);


Where 'Fe0' is the name of the ion for which the magnetic form factor is calculated. **This method should be applied
only once**.

The auxiliary ``MagneticIons``'s method ``IonNames`` returns the cell array of ion names, which are currently tabulated in
Horace and for which scattering can be corrected using the expression above. Additional ``MagneticIons`` methods
``calc_mag_ff`` and ``apply_mag_ff`` allow one to calculate magnetic form factor on or apply magnetic form factor to the
dataset provided.


Commands for entire datasets
============================

**For application of symmetry operations to the entire sqw file when it is being generated, see** :ref:`above
 <manual/Symmetrising_etc:Symmetrise entire SQW>`

It is possible to make a new ``.sqw`` data file that has had a specified symmetrisation performed on it for a certain
data range. You specify which Brillouin zone you are interested in, and then tell Horace which Brillouin zones are
symmetrically equivalent to this one. Data are then cut from all of these zones and combined with the data from your
original choice. The result is output to a new file. For example:

::

   transf_list=combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile);


where ``data_source`` is the master .sqw file, ``proj`` is the projection structure array (the same format as that used
for ``cut_sqw``), ``pos`` is a 3-element vector [h,k,l] specifying the Brillouin zone of interest. ``qstep`` is a single
number specifying the desired step size along h, k, and l of the 4-dimensional output object ``wout``. ``erange`` is a
3-element vector specifying [lo,step,hi] for the energy range to be cut. Finally, ``outfile`` is the .sqw filename
(including path and .sqw extension) where the symmetrised data will be saved. ``transf_list`` is the cell array of
``cut_transf`` classes where each element describes a transformation, applied to particular zone. Note that the output
argument ``transf_list`` is optional.

For the basic case detailed above, data from all permutations of ``pos=[h,k,l]`` will be included in the output
file. The ``cut_transf`` objects in the ``transf_list`` array by default are reflections described by the transformation
matrix, specified by ``cut_transf.transf_matrix`` property.

If you wish to be more restrictive then you can either use:

::

   transf_list=combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile,keyword);


or

::

   transf_list=combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile,zonelist);


The keywords that can be used are as follows:

- ``-ab``
- ``-ac``
- ``-bc``
- ``-cyclic``
- ``-cycwithneg``

``-ab`` combines all equivalent zones with the same value of L (i.e. (H,K,L), (-H,K,L), (H,-K,L), (-H,-K,L),
(K,H,L), (-K,H,L), (K,-H,L), and (-K,-H,L)). ``-ac`` combines all equivalent zones with the same K, and
``-bc`` combines equivalent zones with the same H.

``-cyclic`` combines all equivalent zones that are cyclic permutations of (H,K,L) **with no sign changes**,
whereas ``-cycwithneg`` **does** include sign changes.

If you wish to specify which zones to combine manually, this can be done by specifying the argument
``zonelist``. This is a cell array, with each element a 3-element vector. For example you might have
``pos=[1,2,3]``, and ``zonelist={[1,2,3],[3,2,1],[2,3,1],[2,1,3],[3,1,2]}``.


Advanced usage
**************

By default ``combine_equivalent_zones`` generates a set of reflections, transforming equivalent zones into the
target one. For specified Brillouin zones the user can modify transformations to use symmetry, specific to his
or her problem. E.g, one can specify shifts, which use the symmetry of the reciprocal lattice to unite various
zones together. To combine zones, located at inequivalent hkl positions one may need to apply a correction
function. The script below gives the example of combining all equivalent zones and correcting for the magnetic
form factor. The shift transformation is defined by the **symmetry_type** keyword, and the function to apply
to each zone before combining is specified by the keyword **correct_fun**.

::

   data_source = fullfile(pwd,'Data','Fe_ei200.sqw');
   proj = ortho_proj([1,0,0], [0,1,0]);

   % move all zones into the centre.
   pos = [0,0,0];

   % define function to fix magnetic form-factor different for <1,1,0> and <2,0,0> zones.
   mff = MagneticIons('Fe0');
   fixer = @(ws)(mff.fix_magnetic_ff(ws));

   erange = [0,2,200];
   outfile = fullfile(pwd,'Data','Fe_ei200shift110allSymmetries.sqw');

   % all zones to combine
   zonelist = {[1,1,0],[1,-1,0],[-1,1,0], ...
               [0,1,1],[0,1,-1],[0,-1,1], ...
               [1,0,1],[1,0,-1],[-1,0,1], ...
               [2,0,0],[-2,0,0],[0,2,0], ...
               [0,-2,0],[0,0,2],[0,0,2]};

   transf_list = combine_equivalent_zones(data_source,proj,pos,...
                                          0.01,erange,outfile,zonelist,...
                                          'symmetry_type','shift','correct_fun',fixer);


``symmetry_type`` currently can be ``sigma`` (for reflections) or ``shift`` (for moving different zones).

The sample script above also generates duplicated pixels, as the [2,0,0] zones are moved into [0,0,0]
positions and the same zones at the edges of the cuts (e.g [1,1,0]+-1) will be accounted for twice. The
direction of the projection should be changed to avoid this.

Limitations
***********

- At present ``symmetrise_sqw``, ``combine_sqw``, and ``rebin_sqw`` work ONLY for sqw objects, since they
  require access to individual detector pixel information. The functions will work for any dimensionality
  of object, however.

- ``combine_equivalent_zones`` has to perform some memory and hdd-access intensive calculations, which
  should ideally be performed on `high performance computing cluster
  <http://www.isis.stfc.ac.uk/groups/excitations/data-analysis-computers/connecting-to-isiscomputendrlacuk-using-nomachine15120.html>`__. The
  amount of memory used by the code is controlled by ``hor_config`` parameter ``mem_chunk_size`` and is
  approximately 10 times larger then the amount, specified by this parameter.
