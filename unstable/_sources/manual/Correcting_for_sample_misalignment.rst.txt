##################################
Correcting for sample misalignment
##################################

.. |deg| replace:: :math:`^\circ`


When mounting your sample on a spectrometer, it can often be the case that it is slightly misaligned with respect to the
'perfect' alignment assumed when generating the SQW file (the ``u`` and ``v`` vectors provided in ``gen_sqw`` and
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
:math:`\Gamma{}\rightarrow{}p` is the path from the gamma point (:math:`[0,0,0]`) to the point :math:`p`.

Henceforth, we define :math:`\{\vec{Q}\}` as the set of vectors from the gamma point to each Bragg point :math:`\{p
\in{} P: \vec{\Gamma{}p}\}`.

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

- ``trans_cut_length`` - lengths of cuts of each cut perpendicular to :math:`\{\vec{Q}\}`.

- ``trans_bin_width`` - bin (step) sizes along the transverse cuts

- ``trans_thickness`` - integration thickness along the two perpendicular directions to the transverse cuts

- ``energy_window`` - Energy integration window around elastic line (meV). Choose according to the instrument
  resolution.

.. note::

   This is the full energy window.  A good value for ``energy_window`` is 2 x full-width half-height,
   e.g. for -1meV to +1 meV, set ``energy_window=2``

The following keyword options are available:

For binning:

- ``'bin_absolute'`` [Default] - denotes that the radial and transverse cut lengths, bin sizes, and thicknesses are in
  inverse Angstroms

- ``'bin_relative'`` - denotes that cut lengths, bin sizes and thicknesses are fractions of :math:`\left|\mathbf{Q}\right|` for radial
  cuts and degrees for transverse cuts.

For fitting:

- ``'outer'`` [Default] - determines peak position from centre of peak half-height by finding the peak width moving inwards from
  the limits of the data

.. note::

   Useful if there is known to be a single peak in the data as it is more robust to too finely binned data.

- ``'inner'`` - determines the peak position from centre of peak half height by finding the peak width moving outwards
  from peak maximum

- ``'gaussian'`` - fits a Gaussian on a linear background.

The outputs are:

- ``rlu0`` - the actual peak positions as an n-by-3 matrix in :math:`h,k,l` as indexed with respect to the current
  lattice parameters.

- ``widths`` - an n-by-3 array containing the FWHH in Ang^-1 of the peaks along each of the three projection axes

- ``wcut`` - an n-by-3 array of cuts, along three orthogonal directions through each Bragg point from which the
  peak positions were determined.

.. note::

   These cuts are ``IX_dataset_1d`` objects and can be plotted using the plot functions.

- ``wpeak`` - an n-by-3 array of spectra, that summarise the peak analysis.

.. note::

   These cuts are ``IX_dataset_1d`` objects and can be plotted using the plot functions.

.. note::

   ``wcut`` and ``wpeak`` can be passed to ``bragg_positions_view`` to view the output.



Step 2 - check the Bragg positions fits worked properly
-------------------------------------------------------

You can make plots of the cuts and fits of your predicted Bragg peaks to check that the program has correctly fitted
everything, using outputs from ``bragg_positions`` described above.

::

   bragg_positions_view(wcut,wpeak)


You will be prompted in the Matlab command window as to which plot and fit you wish to view.

.. note::

   Press ``'q'`` to exit this interactive mode.


.. warning::

   It is important to use this function to scrutinise the peaks and the fits because there many parameters that may need
   adjusting depending on the degree of misalignment of your crystal: the length, binning and thicknesses of the cuts
   you specified in ``bragg_positions``, the quality of the cuts (for example the Bragg peaks may be near gaps in the
   detectors so the cuts are poorly defined), the Bragg peaks may have strange shapes which can confuse the automatic
   fitting, etc.


Step 3 - calculate the misalignment correction
----------------------------------------------

Using the outputs of ``bragg_positions``, you can determine a transformation matrix to go from the original
misaligned frame to the aligned frame.

::

   al_info = refine_crystal(rlu0, alatt, angdeg, bragg_peaks, <keyword options>);


The inputs are:

- ``rlu0`` - the an n-by-3 matrix of actual peak positions as in :math:`h,k,l` as indexed with the current lattice parameters

- ``alatt, angdeg`` - the lattice parameters and angles used in the original sqw file.

- ``bragg_peaks`` - the predicted (integer) Bragg peaks corresponding to ``rlu0``

The keyword options are:

- ``fix_lattice`` - Fix all lattice parameters :math:`[a,b,c,\alpha,\beta,\gamma]`, i.e. only allow crystal orientation
  to be refined

- ``fix_alatt`` - Fix :math:`[a,b,c]`, but allow lattice angles :math:`[\alpha,\beta,\gamma]` to be refined together with
  the crystal orientation

- ``fix_angdeg`` - Fix :math:`[\alpha,\beta,\gamma]`, but allow the lattice parameters :math:`[a,b,c]` to be refined together with crystal orientation

- ``fix_alatt_ratio`` Fix the ratio of the lattice parameters as given by the values in the inputs, but allow the
  overall scale of the lattice to be refined together with crystal orientation

- ``fix_orient`` - Fix the crystal orientation i.e. only refine the lattice parameters

- ``free_alatt`` - Array length 3 of booleans, 1=free, 0=fixed

  e.g. ``'free_alatt',[0,1,0],...`` allows only lattice parameter :math:`b^{*}` to vary

- ``free_angdeg`` - Array length 3 of booleans, 1=free, 0=fixed.

  e.g. ``'free_angdeg',[1,1,0],...`` fixes lattice angle gamma buts allows :math:`\alpha` and :math:`\beta` to vary

.. note::

   To achieve finer control of the refinement of the lattice parameters, use ``free_alatt`` and ``free_angdeg``

The output is an ``crystal_alignment_info`` object which contains all the relevant data for crystal realignment.

Step 4 - apply the correction to the data
-----------------------------------------

There are different to do this, for different circumstances:

- When you have a completed scan and an existing ``sqw`` file:

  Apply the correction to an existing file

- When you have a loaded ``sqw`` object:

  Apply the correction to the object

- When you are still accumulating data (e.g. on the beamline):

  Calculate what the goniometer offsets for regeneration


Option 1 : apply the correction to an existing sqw file
=======================================================

There is a simple routine to apply the changes to an existing file, without the need to regenerate it from raw data

::

   change_crystal(win, alignment_info)

where ``alignment_info`` was determined in the steps described above. From this point out the alignment will be applied whenever pixels are loaded or manipulated (e.g. loading, cutting, plotting, etc.).

Once you have confirmed that the alignment you have is the correct one, it is possible to fix the alignment to avoid this calculation step.

This is done through the ``apply_alignment`` function:

::

   [wout, rev_corr] = apply_alignment(win, ['-keep_original'])

.. warning::

   You must have attached the alignment to the ``sqw`` through the ``change_crystal`` function prior to applying it.

Where:

- ``win`` - Input filename or ``sqw`` object to update.

- ``'-keep_original'`` - In the case of a file-backed ``sqw`` object, this will avoid overwriting the original datafile and retain the temporary file created as part of the calculation process

.. note::

   If you use ``'-keep_original'`` you may wish to ``save`` your object as the temporary file will be cleared when the object is. (see: file_backed_objects)

- ``wout`` - Resulting ``sqw`` object or the filename to which the alignment was applied.

- ``rev_corr`` - A corresponding ``crystal_alignment_info`` to be able to reverse the application.


Option 2 : calculate goniometer offsets for regeneration of sqw file(s)
=======================================================================

In this case there is a single routine to calculate the new goniometer offsets, that can then be used in future sqw file generation.

::

   [alatt, angdeg, dpsi_deg, gl_deg, gs_deg] = crystal_pars_correct(u, v, alatt0, angdeg0, omega0_deg, dpsi0_deg, gl0_deg, gs0_deg, al_info, <keyword options>)


The inputs are:

- ``u``, ``v`` - Two 3-vectors which were used to define the notional scattering plane before any alignment corrections
  were performed.

.. note::

   ``u`` is usually defined as the vector of the incident beam and ``v`` is coplanar with respect to the instrument.

- ``alatt0``, ``angdeg0`` - The initial sample lattice parameters, before refinement

- ``omega0_deg``, ``dpsi0_deg``, ``gl0_deg``, ``gs0_deg`` - The initial goniometer offsets, before refinement (all in
  |deg|)

.. note::

   :math:`\text{d}\psi`, :math:`g_l` and :math:`g_s` refer to the Euler angles relative to the scattering plane. Naming
   conventions may differ in other notations, e.g. :math:`\theta, \phi, \chi`.

- ``al_info`` - The ``crystal_alignment_info`` object determined above.

The keywords options are:

.. warning::
   Normally these need not be given and the inputs ``u``, ``v`` and ``omega`` will be used.

- ``u_new``, ``v_new`` - :math:`\vec{u}`, :math:`\vec{v}` that define the scattering plane. :math:`d\psi`,
  :math:`g_{l}`, :math:`g_{s}` will be calculated with respect to these vectors. (Default: ``u``, ``v`` respectively)


- ``omega_new`` - Value for the orientation of the virtual goniometer arcs. :math:`d\psi`,
  :math:`g_{l}`, :math:`g_{s}` will be calculated with respect to this offset angle. (Default: ``omega``) (|deg|)


The outputs are:

- ``alatt, angdeg`` - The true lattice parameters: :math:`[a_{true},b_{true},c_{true}]`,
  :math:`[\alpha_{true},\beta_{true},\gamma_{true}]` (in Å and |deg| respectively)

- ``dpsi_deg, gl_deg, gs_deg`` - Misorientation angles of the vectors ``u_new`` and ``v_new`` (all in |deg|)


Option 2a (for use with e.g. Mslice): calculate the true u and v for your misaligned crystal
============================================================================================

Following option 2 above, you can recalculate the true ``u`` and ``v`` vectors with the following method:

::

   [u_true, v_true, rlu_corr] = uv_correct(u, v, alatt0, angdeg0, omega_deg, dpsi_deg, gl_deg, gs_deg, alatt_true, angdeg_true)


The inputs are:

- ``u``, ``v`` - the orientation of the correctly aligned crystal.

- ``alatt``, ``angdeg`` - the lattice parameters of the aligned crystal, i.e. the output of ``crystal_pars_correct``.

- ``omega_deg``, ``dpsi_deg``, ``gl_deg``, ``gs_deg`` - the calculated misorientation angles, i.e. the output of
  ``crystal_pars_correct``.

- ``alatt_true``, ``angdeg_true`` - similarly, the calculated correct lattice parameters


The outputs are:

- ``u_true, v_true`` - the corrected :math:`\vec{u}` and :math:`\vec{v}` for e.g. Mslice.

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

   [rlu0,width,wcut,wpeak] = bragg_positions(w, rlu, radial_cut_length, radial_bin_width, radial_thickness,...
                                             trans_cut_length, trans_bin_width, trans_thickness)

Get actual Bragg peak positions, given initial estimates of their positions, from an sqw object or file

bragg_positions_view
====================

::

   bragg_positions_view(wcut, wpeak)

View the output of fitting to Bragg peaks performed by ``bragg_positions``

crystal_pars_correct
====================

::

   [alatt, angdeg, dpsi_deg, gl_deg, gs_deg] = crystal_pars_correct(u, v, alatt0, angdeg0, omega0_deg, dpsi0_deg, gl0_deg, gs0_deg, al_info)

Return correct lattice parameters and crystal orientation for gen_sqw from a matrix that corrects the r.l.u.

refine_crystal
==============

::

   al_info = refine_crystal(rlu0, alatt0, angdeg0, bragg_peaks, [fix_])

Refine crystal orientation and lattice parameters

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

rlu_corr_to_lattice
===================

::

   [alatt,angdeg,rotmat,ok,mess]=rlu_corr_to_lattice(rlu_corr,alatt0,angdeg0)

Extract lattice parameters and orientation matrix from r.l.u correction matrix and reference lattice parameters


..
   calc_proj_matrix
   ================

   ::

      [spec_to_u, u_to_rlu, spec_to_rlu] = calc_proj_matrix(alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)


   Calculate matrix that convert momentum from coordinates in spectrometer frame to projection axes defined by :math:`u1 \| a^*`,
   :math:`u2` in plane of :math:`a^*` and :math:`b^*` i.e. crystal Cartesian axes. Allows for correction scattering plane (omega, dpsi, gl, gs) -
   see Tobyfit for conventions
