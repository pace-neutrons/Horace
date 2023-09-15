##################
Input file formats
##################

.. |SQW| replace:: :math:`S(\mathbf{Q}, \omega{})`

To generate the ``.sqw`` file from which Horace reads |SQW|, neutron scattering
data for each individual run and needs to be provided in one of two formats:

- the legacy ASCII format ``.spe`` file, together with an ASCII detector
  parameter file (the ``.par`` file)

- their replacements, the HDF5 (Hierarchical Data Format) ``.nxspe`` file.

Two functions are available as part of Horace to create ``.sqw`` files from
these input files:

- ``gen_sqw`` (creates a new ``.sqw`` file)

- ``accumulate_sqw`` (accumulates data to an existing ``.sqw`` file).

.. note::

   The functions to generate ``.sqw`` files are described in detail :ref:`here
   <manual/Generating_SQW_files:Generating SQW files>`.

Generally, if Horace has been made available for that instrument by the
scientist(s) responsible, the input data files (``.spe`` or ``.nxspe`` format)
will be created by the data reduction code for the instrument you are
using. However, if you want to use Horace to analyse data from other instruments
you need to know how to create the input files from whatever format your data is
saved in.

``.nxspe`` file
===============

The recommended input data file for Horace is the ``.nxspe`` file, which holds both
the :math:`S(w)` data and errors for each detector, detector position and size
information, together with the crystal orientation angle :math:`\psi` and the
incident neutron energy :math:`E_i`.

.. note::

   The ``.nxspe`` file stores the information in a NeXus format file, which is a
   common data exchange format for neutron, X-ray and muon data that is built on
   top of the HDF5 (Hierarchical Data Format) scientific data format.


.. note::

   Data files in the ``.nxspe`` format are produced by the `Mantid data analysis
   software <http://www.mantidproject.org>`__. They are directly produced by the
   data reduction algorithms within Mantid for the direct geometry spectrometers
   at both the ISIS spallation neutron source at the Rutherford Appleton
   Laboratory in the UK and the SNS spallation neutron source at Oak Ridge
   National Laboratory in the USA.


   Mantid is an open source data manipulation and analysis framework for neutron
   and muon data analysis. If Mantid is used to perform the data corrections for
   a neutron spectrometer, then the Mantid algorithm ``SaveNXSPE`` can be used
   to output ``.nxspe`` files. Full details of how to use Mantid and the
   input/output for each algorithm are available at the `Mantid web site
   <http://www.mantidproject.org/>`__.


gen_nxspe
*********

More suitable for a 'quick start', is if you can read corrected scattering data,
associated estimated errors, and detector parameters into Matlab arrays. You can
then use the Horace utility function ``gen_nxspe`` to create ``.nxspe`` files.

This is a flexible to repackage and save |SQW| and detector information to
file. To write a single ``.nxspe`` file the syntax is as follows:

::

   gen_nxspe(S,ERR,en,par,nxspefile_name,efix,emode,psi)


The input parameters are defined as follows:

.. note::

   Hereon, ``ne`` is the number of energy bins and ``nd`` is the number of detector
   elements.


- ``S`` - An ``ne`` x ``nd`` array of signal strength.

- ``ERR`` - An ``ne`` x ``nd`` array of estimated standard errors.

- ``en`` - An ``ne+1`` array of energy bin boundaries.

- ``par`` - A ``6`` x ``nd`` array of detector parameters. Each column of the
  array contains information for a detector element:

.. _det_info:

  - ind: Detector index number. The detectors can be numbered ``1, 2, ..., nd``

  - L2: Distance (m) from the sample to detector.

  - phi: Scattering angle (degrees), i.e. angle between the incident beam
    direction and a line connecting the sample to the detector.

  - azim: Azimuthal angle (degrees).

  .. note::

     In spherical polar coordinates where the conventional z-axis
     (:math:`\vec{u}`) points in the direction of the incident beam and with the
     conventional y-axis (:math:`\vec{v}`) pointing vertically upwards:

     - ``phi`` is the conventional polar angle :math:`\theta`.

     - ``azim`` is the conventional azimuthal angle :math:`\phi`.

  - width: Width (m) of the detector perpendicular to the Debye-Scherrer ring
    through the detector.

  - length: Length (m) of the detector tangential to the Debye-Scherrer ring
    through the detector.

.. note::

   The width and length of the detector are not actually used by Horace, but
   dummy values need to be provided.

- ``nxspefile_name`` - The name of the file to which the data will be saved.

- ``efix`` - Fixed energy (meV). If emode=1 (direct geometry) this is the fixed
  incident energy, if emode=2 (indirect geometry) it is the fixed final energy.

- ``psi`` Rotation about the vertical axis. This is the angle between the vector
  :math:`\vec{u}` of the pair of vectors :math:`\vec{u}` and :math:`\vec{v}` that
  define the horizontal scattering plane of the crystal.


``.spe`` file and ``.par`` file
===============================

These files may be encountered if you are using Horace to analyse older
data. The ASCII ``.spe`` format file stores S(w) and associated error bars as a
function of energy transfer and :math:`\hbar{}W`, for each detector in turn.

In addition to the set of ``.spe`` files, Horace requires an accompanying ASCII
file which contains information about the location of the detectors in the
spectrometer's reference frame, the ``.par`` file.

Although these ASCII format files have largely been superseded in favour of the
``.nxspe`` format described above, these files are ubiquitous as the format in
which historic data is saved, and are recognised by several other neutron
visualisation and analysis programs.

Some programs can also write their own output as ``.spe`` files, and
consequently the ``.spe`` file is sometimes used as a transportable format data
file for time-of-flight neutron spectrometers.

The format of these two files is described here. However, it is not recommended
to create new ``.spe`` files as it is now an obsolete file format.

``.spe`` file format
********************

The ``.spe`` file contains the intensity and estimated standard deviation on those
intensities for each detector element in turn, with header blocks that give the
number of detectors and energy bins, and the scattering angle and energy
transfer bin boundaries. These blocks are all separated by character strings
that begin with '###'. In full:

::

   nd ne

   ### Phi Grid

   phi(1) phi(2)    phi(3)  phi(4)  phi(5)  phi(6)  phi(7)  phi(8)
   phi(9) phi(10)   phi(11) phi(12) phi(13) phi(14) phi(15) phi(16)
   :
   ...    phi(nd+1)

   ### Energy Grid

   en(1) en(2)    en(3)  en(4)  en(5)  en(6)  en(7)  en(8)
   en(9) en(10)   en(11) en(12) en(13) en(14) en(15) en(16)
   :
   ...   en(ne+1)

   ### S(Phi,w)

   S(1) S(2)  S(3)  S(4)  S(5)  S(6)  S(7)  S(8)
   S(9) S(10) S(11) S(12) S(13) S(14) S(15) S(16)
   :
   ...  S(ne)

   ### Errors ERR(1)  ERR(2)  ERR(3)  ERR(4)  ERR(5)  ERR(6)  ERR(7)  ERR(8)
   ERR(9)     ERR(10) ERR(11) ERR(12) ERR(13) ERR(14) ERR(15) ERR(16)
   :
   ...        ERR(ne)

   ### S(Phi,w)
   :
   ### Errors
   :


Here ``nd`` is the number of detectors, ``ne`` is the number of energy bins,
``phi`` contains scattering angles, ``en`` contains the energy transfer bin
boundaries, and ``S`` and ``ERR`` contain the signal and standard error on the
signal for each detecetor in turn.

.. warning::

   The values in ``phi`` are conventionally ignored by neutron analysis
   applications, including Horace, by default they are set to ``1, 2 ,3
   ... (nd+1)``


.. note::

   On the first line, ``nd`` and ``ne`` need only to be separated by white
   space.

   In the blocks containing the signal and error the format is strongly
   prescribed:

   - each line must contain 8 real numbers, apart from the last line in each
     block

   - each number must occupy a field of precisely 10 spaces.

   - No white space is necessary. (This is a frequent source of problem when
     writing the files.)

   **N.B.** This corresponds roughly with the format specifiers:

   - Fortran: ``8(F10.0)``
   - C: ``%f10%f10%f10%f10%f10%f10%f10%f10``


.. warning::

   It is strongly recommended that you do not try to create your own
   ``.spe`` format files. This is an obsolete format.


``.par`` file format
********************

The ``.par`` file contains the position information of the detectors and their
sizes. The format is:


======== ========= ========== =========== ============
ndet
L2(1)    phi(1)    azim(1)    width(1)    length(1)
L2(2)    phi(2)    azim(2)    width(2)    length(2)
:        :         :          :           :
L2(ndet) phi(ndet) azim(ndet) width(ndet) length(ndet)
======== ========= ========== =========== ============

`See here <det_info_>`_ for the meanings of these parameters.


.. note::

   The parameters need to be separated by white space, but otherwise there are
   no constraints on the format.

.. NIMA_834_132_Horace_Paper.

.. warning::

   The width and length of the detector are not actually used by Horace, but
   dummy values need to be present in the file.
