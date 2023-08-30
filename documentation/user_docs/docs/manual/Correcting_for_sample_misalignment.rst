##################################
Correcting for sample misalignment
##################################

When mounting your sample on a spectrometer, it can often be the case that it is slightly misaligned compared the to the
'perfect' alignment assumed when generating the SQW file (the **u** and **v** vectors provided in ``gen_sqw`` and
``accumulate_sqw``). It is straightforward to correct this misalignment, once enough data have been accumulated, by
comparing the positions of Bragg peaks with what they are expected to be.

Alignment correction is a two-step process:

1. First, the misalignment must be determined and checked.
2. Then, the correction must be applied to the data.


Step 1 - determining the true Bragg peak positions
==================================================

Bragg Positions
---------------

First you should identify several Bragg peaks which are strong and not parallel along :math:`\{p \in{} P:
\Gamma{}\rightarrow{}p\}` in your data, where :math:`\{P\}` is the set of Bragg peaks, where
:math:`\Gamma{}\rightarrow{}p` is the path from the gamma point to the point :math:`p`.

Henceforth, we define :math:`\{\vec{Q}\}` as the set of :math:`\{p \in{} P: \vec{\Gamma{}p}\}`.

The following routine generates radial and transverse cuts around specified Bragg peaks and calculates the deviation
from the expected values.

::

   [rlu0, widths, wcut, wpeak] = bragg_positions (sqw, bragg_positions, ...
                   radial_cut_length, radial_bin_width, radial_thickness,...
                   trans_cut_length, trans_bin_width, trans_thickness, ...
                   energy_window, <keyword options>)


The inputs are:

- ``sqw`` - the uncorrected data

- ``bragg_positions`` - an n-by-3 array specifying the expected Bragg positions

- ``radial_cut_length`` - lengths of the various cuts along each of :math:`\{\vec{Q}\}`.

- ``radial_bin_width`` - bin (step) sizes along the radial cuts

- ``radial_thickness`` - integration thickness along the axes perpendicular to the radial cut direction

- ``trans_cut_length`` - lengths of cuts of each cut orthogonal to :math:`\vec{Q}`.

- ``trans_bin_width`` - bin (step) sizes along the transverse cuts

- ``trans_thickness`` - integration thickness along the two perpendicular directions to the transverse cuts

- ``energy_window`` - Energy integration window around elastic line (meV). Choose according to the instrument
  resolution. A good value is 2 x full-width half-height. Note that this is the full energy window, e.g. for -1meV to +1
  meV, set energy_window=2

The following **keyword options** are available:

For **binning** choose either ``'bin_absolute'``, which denotes that the radial and transverse cut lengths, bin sizes,
and thicknesses are in inverse Angstroms [Default]; or choose ``'bin_relative'``, which denotes that cut lengths, bin
sizes and thicknesses are fractions of \|**Q**\| for radial cuts and degrees for transverse cuts.

For **fitting** options choose ``'outer'``, which determines peak position from centre of peak half-height by finding
the peak width moving inwards from the limits of the data - useful if there is known to be a single peak in the data as
it is more robust to too finely binned data. [Default]; ``'inner'`` determines the peak position from centre of peak
half height by finding the peak width moving outwards from peak maximum; ``'gaussian'`` fits a Gaussian on a linear
background.

The **outputs** are:

- ``rlu0`` - the actual peak positions as an n-by-3 matrix of h,k,l as indexed with the current lattice parameters.

- ``widths`` - an array of size n-by-3 containing the FWHH in Ang^-1 of the peaks along each of the three projection axes

- ``wcut`` - an array of cuts, size n-by-3, along three orthogonal directions through each Bragg point from which the
  peak positions were determined. (Note that this can be passed to ``bragg_positions_view`` together with ``wpeak`` to
  view the output. [Note: the cuts are IX_dataset_1d objects and can be plotted using the plot functions for these
  methods.]

- ``wpeak`` - an array of spectra, size n-by-3, that summarise the peak analysis. Pass to ``bragg_positions_view``
  together with ``wcut`` to view the output. [Note: for aficionados: the cuts are IX_dataset_1d objects and can also be
  plotted using the plot functions for these objects.]


Step 2 - check the Bragg positions fits worked properly
-------------------------------------------------------

You can make plots of the cuts and fits of your notional Bragg peaks to check that the program has correctly fitted
everything, using outputs from the ``bragg_positions`` describe above.

::

   bragg_positions_view(wcut,wpeak)


You will be prompted in the Matlab command window as to which plot and fit you wish to view. Press 'q' to exit this
interactive mode. It is important to use this function to scrutinise the peaks and the fits because there many
parameters that may need adjusting depending on the degree of misalignment of your crystal: the length, binning and
thicknesses of the cuts you specified in ``bragg_positions``, the quality of the cuts (for example the Bragg peaks may
be near gaps in the detectors so the cuts are poorly defined), the Bragg peaks may have strange shapes which deceived
the automatic fitting etc.


Step 3 - calculate the misalignment correction
----------------------------------------------

Using the outputs of ``bragg_positions``, together with certain optional keyword arguments, you can determine a
transformation matrix that goes from the original misaligned frame to the correct aligned frame.

::

   [rlu_corr,alatt,angdeg] = refine_crystal(rlu0, alatt, angdeg, bragg_peaks,<keyword options>);


The **inputs** are;

- ``rlu0`` - the actual peak positions as an n-by-3 matrix of h,k,l as indexed with the current lattice parameters (see above)

- ``alatt, angdeg`` - the lattice parameters and angles used in the original sqw file.

- ``bragg_peaks`` - the notional (integer) Bragg peaks corresponding to ``rlu0``

The **keyword options** for defining exactly what is and is not-corrected for are as follows:

- ``fix_lattice`` - Fix all lattice parameters [a,b,c,alpha,beta,gamma], i.e. only allow crystal orientation to be refined

- ``fix_alatt`` - Fix [a,b,c] but allow lattice angles alpha, beta and gamma to be refined together with the crystal orientation

- ``fix_angdeg`` - Fix [alpha,beta,gamma] but allow the lattice parameters [a,b,c] to be refined together with crystal orientation

- ``fix_alatt_ratio`` Fix the ratio of the lattice parameters as given by the values in the inputs, but allow the
  overall scale of the lattice to be refined together with crystal orientation

- ``fix_orient`` - Fix the crystal orientation i.e. only refine the lattice parameters

NB: To achieve finer control of the refinement of the lattice parameters: instead of ``fix_lattice``, ``fix_angdeg``, etc. use the following:

- ``free_alatt`` - Array length 3 of zeros or ones, 1=free, 0=fixed

e.g. 'free_alatt',[0,1,0],... allows only lattice parameter b to vary

- ``free_angdeg`` - Array length 3 of zeros or ones, 1=free, 0=fixed.

e.g. 'free_angdeg',[1,1,0],... fixes lattice angle gamma buts allows alpha and beta to vary

The **outputs** are:

- ``rlu_corr`` - Conversion matrix to relate notional rlu to true rlu, accounting for the the refined crystal lattice
  parameters and orientation qhkl(i) = rlu_corr(i,j) \* qhkl_0(j)

- ``alatt`` - Refined lattice parameters [a,b,c] (Angstroms)

- ``angdeg`` - Refined lattice angles [alpha,beta,gamma] (degrees)

- ``rotmat`` - Rotation matrix that relates crystal Cartesian coordinate frame of the refined lattice and orientation as
  a rotation of the initial crystal frame. Coordinates in the two frames are related by v(i)= rotmat(i,j)v0(j)

- ``distance`` - Distances between peak positions and points given by true indexes, in input argument rlu, in the refined crystal lattice. (Ang^-1)

- ``rotangle`` - Angle of rotation corresponding to rotmat (to give a measure of the misorientation) (degrees)

Step 4 - apply the correction to the data
-----------------------------------------

There are two ways to do this, either to apply the correction to an existing file without regenerating (good for when
you have a complete scan). Or you can calculate what the goniometer offsets ``gl, gs, dpsi`` are, and then use these
when you regenerate the sqw file (good for situations when you are still accumulating data, such as on the beamline
during an experiment).


Option 1 : apply the correction to an existing sqw file
=======================================================

There is a simple routine to apply the changes to an existing file, without the need to regenerate;

::

   change_crystal_horace(sqw_file, rlu_corr)


where ``rlu_corr`` was determined in the steps described above


Option 2 : calculate goniometer offsets for regeneration of sqw file(s)
=======================================================================

In this case there is a single routine to calculate the new goniometer offsets, that can then be used in future sqw file generation.

::

   [alatt, angdeg, dpsi_deg, gl_deg, gs_deg] = crystal_pars_correct (u, v, alatt0, angdeg0, omega0_deg, dpsi0_deg, gl0_deg, gs0_deg, rlu_corr, <keyword options>)


The **inputs** are:

- ``u, v`` - The notional scattering plane (used when the sqw file was initially generated, before any alignment corrections were performed)

- ``alatt0, angdeg0`` - The initial lattice parameters used in the first sqw file generation, before refinement

- ``omega0_deg, dpsi0_deg, gl0_deg, gs0_deg`` - The initial goniometer offsets used in the first sqw file generation, before refinement (all in degrees)

- ``rlu_corr`` - The correction matrix determined above.

The following **optional keywords** can be provided:

- ``u_new, v_new`` - Replacement vectors u, v that define the scattering plane. Normally these would not be given, and
  the input u and v will be used. The extent to which u_new and v_new do not correctly give the true scattering plane
  will be accommodated in the output misorientation angles dpsi, gl and gs below. (Default: input arguments u and v)

- ``omega_new`` - Replacement value for the orientation of the virtual goniometer arcs with reference to which dpsi, gl,
  gs will be calculated. (Default: input argument omega) (deg)


The **outputs** are:

- ``alatt, angdeg`` - The true lattice parameters: [a_true,b_true,c_true], [alpha_true,beta_true,gamma_true] (in Ang and deg)

- ``dpsi, gl, gs`` - Misorientation angles of the vectors u_new and v_new (deg)



Option 2a (for use with e.g. Mslice): calculate the true u and v for your misaligned crystal
============================================================================================

Following option 2 above, you can recalculate the true **u** and **v** vectors using the following method.

::

   [u_true, v_true, rlu_corr] = uv_correct (u, v, alatt0, angdeg0, omega_deg, dpsi_deg, gl_deg, gs_deg, alatt_true, angdeg_true)


The **inputs** are:

- ``u`` and ``v`` - the notional orientation of a correctly aligned crystal.

- ``alatt`` and ``angdeg`` - the notional lattice parameters of the aligned crystal. These are the same as in ``crystal_pars_correct`` above..

- ``omega_deg, dpsi_deg, gl_deg, gs_deg`` - the calculated misorientation angles, i.e. the output of ``crystal_pars_correct``.

- ``alatt_true, angdeg_true`` - similarly, the calculated correct lattice parameters


The **outputs** are:

- ``u_true, v_true`` - the corrected **u** and **v** vectors required for e.g. Mslice.

- ``rlu_corr`` - the orientation correction matrix to go from the notional to the real crystal (see above)


List of alignment correction routines
-------------------------------------

Below we provide a brief summary of the routines available for different aspects of alignment corrections. For further information type

::

   help <function name>


in the Matlab command window.

bragg_positions
===============

::

   [rlu0,width,wcut,wpeak]=bragg_positions(w, rlu, radial_cut_length, radial_bin_width, radial_thickness,...
                                                               trans_cut_length, trans_bin_width, trans_thickness)


Get actual Bragg peak positions, given initial estimates of their positions, from an sqw object or file

bragg_positions_view
====================

::

   bragg_positions_view(wcut,wpeak)


View the output of fitting to Bragg peaks performed by ``bragg_positions``

calc_proj_matrix
================

::

   [spec_to_u, u_to_rlu, spec_to_rlu] = calc_proj_matrix (alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)


Calculate matrix that convert momentum from coordinates in spectrometer frame to projection axes defined by u1 \|\| a*,
u2 in plane of a\* and b\ i.e. crystal Cartesian axes. Allows for correction scattering plane (omega, dpsi, gl, gs) -
see Tobyfit for conventions

crystal_pars_correct
====================

::

   [alatt, angdeg, dpsi_deg, gl_deg, gs_deg] = crystal_pars_correct (u, v, alatt0, angdeg0, omega0_deg, dpsi0_deg, gl0_deg, gs0_deg, rlu_corr)


Return correct lattice parameters and crystal orientation for gen_sqw from a matrix that corrects the r.l.u.

refine_crystal
==============

::

   [rlu_corr,alatt,angdeg,rotmat,distance,rotangle] = refine_crystal(rlu0,alatt0,angdeg0)


Refine crystal orientation and lattice parameters

rlu_corr_to_lattice
===================

::

   [alatt,angdeg,rotmat,ok,mess]=rlu_corr_to_lattice(rlu_corr,alatt0,angdeg0)


Extract lattice parameters and orientation matrix from rlu correction matrix and reference lattice parameters

ubmatrix
========

::

   [ub, mess, umat] = ubmatrix (u, v, b)


Calculate UB matrix that transforms components of a vector given in r.l.u. into the components in an orthonormal frame
defined by the two vectors u and v (each given in r.l.u)

uv_correct
==========

::

   [u_true, v_true, rlu_corr] = uv_correct (u, v, alatt0, angdeg0, omega_deg, dpsi_deg, gl_deg, gs_deg, alatt_true, angdeg_true)


Calculate the correct u and v vectors for a misaligned crystal, for use e.g. with Mslice.
