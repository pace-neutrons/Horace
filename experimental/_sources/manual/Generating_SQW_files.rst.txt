####################
Generating SQW files
####################

This page tells you how to generate an SQW file. There are two different situations when you will want to do this:

- During an experiment, when you want to accumulate data files into an SQW file as they are collected - use
  ``accumulate_sqw``

- When you have a full set of data files already that you want to process in one go - use ``gen_sqw``

The two functions have almost identical syntax, as is explained in the sections below.

To generate the SQW file neutron data for each individual run needs to be provided in one of two formats: the legacy
ASCII format SPE file, together with an ASCII detector parameter file (the PAR file), or their replacements the HDF
(hierarchical Data Format) NXSPE file. More details about these files and how to create them can be found :ref:`here
<manual/Input_file_formats:Input file formats>`.


accumulate_sqw
==============

This is a way of generating data 'on the fly' during an experiment. It saves time by appending new data to an already
existing SQW file.

The syntax is as follows:

::

   spe_dir='/home/maps/maps_users/Gruenwald/SPE/';  % directory where spe files are found
   runno=[19780:19960];  % anticipated list of files (we do not need all of them to exist yet)

   spe_file=cell(1,numel(runno));
   for i=1:numel(runno)
       spe_file{i}=[spe_dir,'map',num2str(runno(i)),'_ei100.spe'];  % filenames of runs
   end

   psi=[0:2:180 1:2:179];  % list of anticipated scan angles

   par_file='/usr/local/mprogs/Libisis/InstrumentFiles/maps/4to1_124.par';  % detector parameter file

   sqw_file='/home/maps/maps_users/Gruenwald/data_accumulation.sqw';        % name of output file

   efix=100;  % incident energy
   emode=1;   % indicates direct geometry

   alatt=[5.7,5.7,5.7];  % lattice parameters
   angdeg=[90,90,90];    % lattice angles

   u=[1,1,0]; v=[0,0,1]; % orientation of sample (u//ki when psi=0, v another vector in horizontal plane)

   omega=0; dpsi=0; gl=0; gs=0;  % offset angles for sample misalignment

   accumulate_sqw(spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
       u, v, psi, omega, dpsi, gl, gs, <optional input parameters>);


The input parameters are defined as follows:

- ``spe_file`` is a cell array, each element of which is a string specifying the full file name of the input SPE or
  NXSPE files (e.g. ``spe_file{1} = 'C:\\data\\mer12345.spe'``).

- ``par_file`` is a string giving the full file name of the parameter file for the instrument on which the data were
  taken. This is required for SPE files. For NXSPE files you do not need to specify an instrument parameter file
  (Provide empty string '' instead), as detector information will be picked up from NXSPE files themselves. If you do
  specify ``par_file``, the detector info is taken from there and overrides the information contained within the NXSPE
  files. ``sqw_file`` is a string giving the full file name of the sqw output file you wish to generate.

- ``efix`` is the incident neutron energy for each SPE file. If a single incident energy was used for all runs then this
    number is a scalar, otherwise it must be a vector with the same number of elements are there are SPE files.

- ``emode`` is either 1 for direct geometry instruments, or 2 for indirect geometry.

- ``alatt`` is a vector with 3 elements, specifying the lengths in Angstroms of the crystal lattice parameters.

- ``angdeg`` is a vector with 3 elements, specifying the crystal lattice angles in degrees.

- ``u`` and ``v`` are both 3-element vectors. These specify how the crystal's axes were oriented relative to the
  spectrometer in the setup for which you define ``psi`` to be zero. ``u`` specifies the lattice vector that is parallel
  to the incident neutron beam, whilst ``v`` is a second vector in the horizontal plane. It is not necessary for ``v``
  to be perpendicular to ``u``.

- ``psi`` specifies the angle of the crystal relative to the setup described in the above paragraph (i.e. the angle
  about the vertical axis through which the sample has been rotated). If a single orientation of the crystal was used
  for all measurements then this number can be a scalar, otherwise it is a vector. For the case of it use in
  ``accumulate_sqw`` it is a vector listing the **expected** values of ``psi`` that will be used. It is important to get
  this about right, as it ensures that the underlying reciprocal space grid in the SQW file is big enough to encompass
  all of the data you plan to collect. If it is not, then you lose all the time-saving and the file has to be generated
  from scratch!

- ``omega``, ``dpsi``, ``gl``, and ``gs`` specify the offsets (in degrees of various angles). ``gl`` and ``gs`` describe
  the settings of the large and small goniometers. ``omega`` is the offset of the axis of the small goniometer with
  respect to the notional ``u``. Finally ``dpsi`` allows you to specify an offset in ``psi``, should you wish. These
  angle definitions are shown below:


.. image:: ../images/Gonio_angle_definitions.jpg
   :width: 300px
   :alt: Virtual goniometer angle definitions


The optional input arguments are as follows:

- ``grid_size_in``: A scalar or row vector of grid dimensions. If it is not given, or is left blank (i.e. set to []),
  the default value will be determined on the number and size of the contributing SPE or NXSPE files.

- ``urange_in``: The range of data grid for output along each Q and E direction as a 2x4 matrix -
  [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]. The default if not given or set to [] is the smallest hypercuboid
  that encloses the whole data range.

- ``instrument``: A free-format structure or object containing instrument information [scalar or array length nfile]

- ``sample``: A free-format structure or object containing sample geometry information [scalar or array length nfile]

- ``'replicate'``: Normally the function forbids an SPE or NXSPE file from appearing more than once. This is to trap
  common typing errors. However, sometimes you might want to create an sqw file using, for example, just one SPE file as
  the source of data for all crystal orientations in order to construct a background from an empty piece of sample
  environment. In this case, use the keyword 'replicate' to override the uniqueness check.

- ``'clean'``: Create the SQW file from fresh. This option deletes existing SQW file (if any) and forces fresh
  generation of SQW file from the list of data files provided. It is possible to get confused about what data has been
  included in an SQW file if it is built up slowly over an experiment. Use this option to start afresh.


gen_sqw
=======

This is the main function you will use to turn the data accumulated in multiple SPE files into a single SQW file that
will be used by the rest of the Horace functions. An introduction to its use is given in the :ref:`getting started
<user_guide/Getting_started:Creating an SQW file>` section. The syntax is the same as for ``accumulate_sqw``; the only
difference is that you give a list of existing input datasets rather than the anticipated list.

The essential inputs take the following form:

::

   gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
                                                   u, v, psi, omega, dpsi, gl, gs);


There are additional (optional) input and output arguments, just as for ``accumulate_sqw``:

::

   [tmp_file,grid_size,urange] = gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
                                                   u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in,'replicate');


Optional input arguments:

- ``grid_size_in``: A scalar or row vector of grid dimensions. If it is not given, or is left blank (i.e. set to []),
  the default value will be determined on the number and size of the contributing SPE or NXSPE files.

- ``urange_in``: The range of data grid for output along each Q and E direction as a 2x4 matrix -
  [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]. The default if not given or set to [] is the smallest hypercuboid
  that encloses the whole data range.

- ``instrument``: A free-format structure or object containing instrument information [scalar or array length nfile]

- ``sample``: A free-format structure or object containing sample geometry information [scalar or array length nfile]

- ``'replicate'``: Normally the function forbids an SPE or NXSPE file from appearing more than once. This is to trap
  common typing errors. However, sometimes you might want to create an sqw file using, for example, just one SPE file as
  the source of data for all crystal orientations in order to construct a background from an empty piece of sample
  environment. In this case, use the keyword 'replicate' to override the uniqueness check.

Optional output arguments:

- ``tmp_file``: A cell array containing the full file names of the temporary files that were created by
  ``gen_sqw``. These will be deleted if the function ran correctly, but if there was a problem, then they will still
  exist and it can be useful to know their names so that they can be deleted manually.

- ``grid_size`` is a vector with 4 elements which specifies the actual grid size of the output SQW file that was
  created. For example, if every data point has the same value of Qz then the third element will be 1.

- ``urange`` gives the range in reciprocal space of the data. If ``urange_in`` was specified then this will be the same,
  but if not then it tells you the calculated range of the 4-dimensional hypercuboid which encompasses all of the data.


Applying symmetry operations to an entire dataset
=================================================

In the explanation below, we wish to apply symmetrisation to the entire data file. Under the hood, what happens is that
the data for each run is symmetrised, and then these symmetrised data are combined to make the sqw file. This avoids the
problem of running out of memory when attempting to symmetrise large sections of the unfolded sqw file / object.

To use this functionality, call ``gen_sqw`` or ``accumulate_sqw`` as above, with the following additional arguments:

::

   gen_sqw (spefile, par_file, sym_sqw_file, efix, emode, alatt, angdeg,...
       u, v, psi, omega, dpsi, gl, gs,'transform_sqw',@(x)(symmetrise_sqw(x,v1,v2,v3)))


or more generally

::

   gen_sqw (spefile, par_file, sym_sqw_file, efix, emode, alatt, angdeg,...
       u, v, psi, omega, dpsi, gl, gs,'transform_sqw',@(x)(user_symmetrisation_routine(x))


The first example above would build a sqw file reflected as in the example for the reflection in memory, but with the
transformation applied to the entire dataset. In the second, more general, case the user defined function (in a m-file
on the Matlab path) can define multiple symmetrisation operations that are applied sequentially to the entire data. An
example is as follows, which folds a cubic system so that all six of the symmetrically equivalent (1,0,0) type positions
are folded on to each other:

::

   function wout = user_symmetrisation_routine(win)

   wout=symmetrise_sqw(win,[1,1,0],[0,0,1],[0,0,0]);   % fold about line (1,1,0) in HK plane
   wout=symmetrise_sqw(wout,[-1,1,0],[0,0,1],[0,0,0]); % fold about line (-1,1,0) in HK plane
   wout=symmetrise_sqw(wout,[1,0,1],[0,1,0],[0,0,0]);  % fold about line (1,0,1) in HL plane
   wout=symmetrise_sqw(wout,[1,0,-1],[0,1,0],[0,0,0]); % fold about line (1,0,-1) in HL plane


see very important notes on the technical details of symmeterising a whole dataset in
:ref:`manual/Symmetrising_etc:Commands for entire datasets`.
