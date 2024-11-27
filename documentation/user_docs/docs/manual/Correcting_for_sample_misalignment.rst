##################################
Correcting for sample misalignment
##################################


.. |deg| replace:: :math:`^\circ`


When mounting your sample on a spectrometer, it can often be the case that it is slightly misaligned with respect to the
'perfect' alignment assumed when generating the SQW file (the direction of ``u`` and ``v`` vectors provided in ``gen_sqw`` and
``accumulate_sqw``, where ``u`` is parallel to the beam and ``v`` defines the sample rotation plain).
It is straightforward to correct this misalignment, once enough data have been accumulated, by
comparing the positions of Bragg peaks with what they are expected to be.

.. _Core Alignment:

Alignment correction is based on a three-step process:

1. First, the misalignment must be determined from known theoretical diffraction patterns expected from the crystal and 
   actual diffraction patterns measured in the experiment.
2. Second, the corrections, which would bring actual diffraction patterns as close as possible to the actual patterns
   should be identified.
3. Then, the correction must be applied to the data.

In practice, these steps usually applied iteratively. Namely:

.. _StepA:

A. Evaluate actual diffraction pattern taking number of cuts and slices in different directions. The directions should cover
   whole 3D Q-space. Select actual diffraction patterns which demonstrate misalignment best and are least affected by experimental
   inefficiencies (e.g. edges of detectors covered areas, twinning reflections, can reflections etc...)

.. _StepB:

B. Perform :ref:`three-step process<Core Alignment>` above using actual diffraction patterns, identified at :ref:`Step A<StepA>`.

.. _StepC:

C. Evaluate result of alignment observing modified diffraction patterns.

.. _StepD:

D. Revert alignment corrections and go to :ref:`Step A<StepA>` with modified actual diffraction patterns. Finish when sure that selected 
   representative diffraction patters and resulting alignment looks correct and not affected by selecting slightly
   different set of representative diffraction patters.

Let's consider all these steps in more details. 


Step 1 - determining the true Bragg peak positions
==================================================

Bragg Positions
---------------

First you should identify several Bragg peaks which are strong and not parallel along :math:`\{p \in{} P:
\Gamma{}\rightarrow{}p\}` in your data, where :math:`\{P\}` is the set of Bragg peaks, where
:math:`\Gamma{}\rightarrow{}p` is the path from the gamma point (:math:`[0,0,0]`) to the point :math:`p`.

Henceforth, we define :math:`\{\vec{Q}\}` as the set of vectors from the gamma point to each Bragg point :math:`\{p
\in{} P: \vec{\Gamma{}p}\}`.

From the accuracy point of view it is also reasonable not to have them all on one plane which means that more then 3 Bragg peaks
should be used.

The following routine generates radial and transverse cuts around specified Bragg peaks and calculates the deviation
from the expected values.

::

   [rlu_actual, widths, wcut, wpeak] = bragg_positions (sqw_obj, bragg_expected, ...
                   radial_cut_length, radial_bin_width, radial_thickness,...
                   trans_cut_length, trans_bin_width, trans_thickness, ...
                   energy_window, <keyword options>)


The inputs are:

- ``sqw_obj`` - ``sqw`` object with misaligned data

- ``bragg_expected``   - an n-by-3 array specifying the Bragg positions expected from aligned crystal.

- ``radial_cut_length`` - lengths of the various cuts along each :math:`\vec{Q}`-direction in Bragg peaks set :math:`\{P\}`. Length is in :math:`{Å}^{-1}` or relative units, see below --``bin_absolute`` or ``bin_relative`` keywords.

- ``radial_bin_width`` - bin (step) sizes along the radial cuts

- ``radial_thickness`` - integration thickness along the axes perpendicular to the radial cut direction

- ``trans_cut_length`` - lengths of cuts of each cut perpendicular to :math:`\{\vec{Q}\}`.

- ``trans_bin_width`` - bin (step) sizes along the transverse cuts

- ``trans_thickness`` - integration thickness along the two perpendicular directions to the transverse cuts

- ``energy_window`` - Energy integration window around elastic line (meV). Choose according to the instrument resolution.

.. note::
   This is the full energy window.  A good value for ``energy_window`` is 2 x full-width half-height,
   e.g. for -1meV to +1 meV, set ``energy_window=2``

The following keyword options are available:

For binning:

- ``'bin_absolute'`` [Default] - denotes that the radial and transverse cut lengths, bin sizes, and thicknesses are in inverse Angstroms (:math:`{Å}^{-1}`)

- ``'bin_relative'`` - denotes that cut lengths, bin sizes and thicknesses are fractions of each  :math:`\{\vec{Q}\}` length (``radial_cut_length``) for radial cuts and degrees for transverse cuts.

For fitting:

- ``'outer'`` [Default] - determines peak position from centre of peak half-height by finding the peak width moving inwards from
  the limits of the data

.. note::

   Useful if there is known to be a single peak in the data as it is more robust to too finely binned data.

- ``'inner'`` - determines the peak position from centre of peak half height by finding the peak width moving outwards
  from peak maximum

- ``'gaussian'`` - fits a Gaussian on a linear background.

The outputs are:

- ``rlu_actual`` - the actual peak positions as an n-by-3 matrix in :math:`h,k,l` as indexed with respect to the current
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



Check the Bragg positions fits worked properly
------------------------------------------------

You can make plots of the cuts and fits of your predicted Bragg peaks to check that the program has correctly fitted
everything, using outputs from ``bragg_positions`` described above.

::

   bragg_positions_view(wcut,wpeak)


You will be prompted in the MATLAB command window as to which plot and fit you wish to view, e.g.:

::

  Enter one of the following:
    - peak number (1-N) and scan number (1-3) e.g. N,3
    - <CR> to continue from present peak and scan (p,n)
    - Q or q to quit

where N is the total number of peaks (e.g. 9 for 9 Bragg peaks) and (p,n) are current peak and scan numbers (e.g. (1,1) for first peak and scan)

.. note::

   Press ``'q'`` to exit this interactive mode.


.. warning::

   It is important to use this function to scrutinise the peaks and the fits because there many parameters that may need
   adjusting depending on the degree of misalignment of your crystal: the length, binning and thicknesses of the cuts
   you specified in ``bragg_positions``, the quality of the cuts (for example the Bragg peaks may be near gaps in the
   detectors so the cuts are poorly defined), the Bragg peaks may have strange shapes which can confuse the automatic
   fitting, etc.

.. _Step_2_misalignment_correction:

Step 2 - calculate the misalignment correction
==============================================

Using the outputs of ``bragg_positions``, you can determine a transformation to go from the original
misaligned frame to the aligned frame.

::

   alignment_info = refine_crystal(rlu_actual, alatt0, angdeg0, rlu_expected, <keyword options>);


The inputs are:

- ``rlu_actual``  - the an n-by-3 matrix of actual peak positions as in :math:`h,k,l` as indexed with the current lattice parameters

- ``alatt0, angdeg0`` - the lattice parameters and angles used in the original (misaligned) sqw file.

- ``rlu_expected`` - the predicted (integer) Bragg peaks corresponding to ``bragg_expected``

The keyword options are:

- ``fix_lattice`` - Fix all lattice parameters :math:`[a,b,c,\alpha,\beta,\gamma]`, i.e. only allow crystal orientation
  to be refined

- ``fix_alatt`` - Fix :math:`[a,b,c]`, but allow lattice angles :math:`[\alpha,\beta,\gamma]` to be refined together with
  the crystal orientation

- ``fix_angdeg`` - Fix :math:`[\alpha,\beta,\gamma]`, but allow the lattice parameters :math:`[a,b,c]` to be refined together with crystal orientation

- ``fix_alatt_ratio`` Fix the ratio of the lattice parameters as given by the values in the inputs, but allow the
  overall scale of the lattice to be refined together with crystal orientation

- ``fix_orient`` - Fix the crystal orientation i.e. only refine the lattice parameters

- ``free_alatt`` - keyword followed by array of 3 of booleans, 1=free, 0=fixed

  e.g. ``'free_alatt',[0,1,0],...`` allows only lattice parameter :math:`b^{*}` to vary

- ``free_angdeg`` - keyword followed by array of 3 of booleans, 1=free, 0=fixed.

  e.g. ``'free_angdeg',[1,1,0],...`` fixes lattice angle gamma buts allows :math:`\alpha` and :math:`\beta` to vary

.. note::

   To achieve finer control of the refinement of the lattice parameters, use ``free_alatt`` and ``free_angdeg``

The output is an ``crystal_alignment_info`` object which contains all the relevant data for crystal realignment, namely
the rotation matrix which aligns Crystal Cartesian frame into correct position and modified lattice parameters, if
``refine_crystal`` modified them. 

.. Warning::

   You are defining 3 rotation angles and may be fitting 3 lattice parameters and 3 angular parameters. You need at least 9 variables (dimensions) to define 9 parameters. 3 Bragg peaks
   in 3D space would provide you with at least 9 parameters, so this is the minimal number of 
   inputs for the algorithm to work. In practice, it is better to have more actual Bragg positions to build over-defined system of equations. Changing allowed rotation and lattice parameters algorithm minimizes the difference between actual and theoretical Bragg positions.

At this stage it would be useful to store inverse alignment transformation to be able to perform :ref:`step D<StepD>` without the need to regenerate
your sqw object from the initial misaligned results of the experiment:

::

    >>reverse_transf = crystal_alignment_info(alatt0,angdeg0);
    >>reverse_transf.rotmat = alignment_info.rotmat';

i.e. create crystal alignment info class with your initial lattice parameters and assign inverse rotation matrix defining rotation
which is opposite to the rotation, necessary for corrections you will be applying to your data on the following step.

Step 3 - apply the correction to the data
==========================================

There are different ways to do this, to be preferred in different circumstances.

1. Initially you want to be sure that you have selected correct Bragg peaks, 
that adding new peaks would not improve accuracy of your alignment, and that the resulting alignment is satisfactory.
In other words, you are following :ref:`the iterative process<StepA>` above.
You want to get your results quickly and possibly experiment with them, modify them and apply or undo your a quickly. 
In this case you apply correctios to existing ``sqw`` file or ``sqw`` object loaded in memory.

2. When you are satisfied with the result of alignment you may want to regenerate your ``sqw`` file after calculating goniometer
offsets, which define actual crystal position. You have to do this step if you want to apply various symmetry 
transformations to the whole ``sqw`` file during generation. Alternatively, you may want to "finalize" alignment corrections
applied initially.

Both ways result in an sqw file; the resulting files are identical from a physical point of view.
Minor differences occurs in the data, stored in an sqw file. These differences do not generally affect the results of operations, performed on the file but may affect the performance of following operations. These differences are explained in more details below.


Option 1 : apply the correction to an existing sqw file or object
-----------------------------------------------------------------

There is a simple and fast routine ``change_crystal`` to apply the changes to an existing file, without the need to regenerate it from raw data.

::

   >>change_crystal(win, alignment_info);
   or 
   >>wout = change_crystal(win, alignment_info);

The second form of this routine returns aligned ``sqw`` object. The object is filebacked if pixels data are too big to be loaded in memory.
The second form is mandatory if you are applying alignment to ``sqw`` object in memory.

Here ``win`` is a file containing misaligned ``sqw`` object or filebacked/memory-based ``sqw`` object and ``alignment_info`` was determined on the :ref:`Step 2<Step_2_misalignment_correction>` described above.

.. Note::

   If you use second form of ``change_crystal``, regardless of ``sqw`` object being file-backed or memory based, you need to :ref:`save<manual/Save_and_load:save>` your result if you want your changes to be permanent. The changes to memory based and file-backed objects disappear if object gets deleted from memory.

Majority of Horace users may work with files or objects realigned using ``change_crystal`` without any noticeable hindrance. When ``change_crystal`` 
is applied to object in memory the resulting object is fully aligned and no other actions is necessary to finish alignment. When ``change_crystal`` applied to file, you may want to do :ref:`final alignment step<Finalize_alignment>`, but for majority of practical reasons it is unnecessary.


Advanced users may want to know, that ``change_crystal`` procedure modifies lattice parameters and adds alignment matrix to the pixels data in file.
Pixels themselves are not modified so the alignment procedure is very fast. Pixels will be aligned whenever they are loaded or manipulated 
(e.g. accessing pixel data, cutting, doing unary and binary operations, etc.).
The pixels alignment is combined with other transformations, usually performed during pixels manipulations, so the speed of majority of such operations is not affected.
The actual slow-down in operations with aligned file occurs when some advanced algorithms use pixels range (e.g. ``mask_pixels`` based on a range).
Pixels range is invalidated when pixels are realigned by ``change_crystal``, so such algorithms have to calculate this range first. This may take substantial time.


If you are following :ref:`iterative process<StepA>` above, after validating your alignment revert your alignment at :ref:`Step D <StepD>` applying:

::

   >>change_crystal(win, reverse_transf);
   or 
   >>wout = change_crystal(wout, reverse_transf);


If you performed multiple alignment and ``change_crystal`` operations on filebacked object without reverting them, you may recover resulting reverse (or direct) transformation from filebacked object's pixels alignment matrix:

::

    >>reverse_transf = crystal_alignment_info(alatt0,angdeg0);
    >>reverse_transf.rotmat = wout.pix.alignment_matr';

This is possible because resulting alignment (and de-alignment) matrix is the result of multiplication of sequence of rotation operations.

There is no possibility to retrieve lost initial lattice parameters ``alatt0``; ``angdeg0`` from any ``sqw`` object and alignment matrix from memory based aligned ``sqw`` object.
This is why it is recommended to revert the alignment first each time you want to realign your ``sqw`` object. It is not the critical recommendation, as you can always rebuild your misaligned ``sqw`` object from the initial experimental results.

.. Note::

   ``SQW`` file de-alignment procedure, which works regardless of the previous alignment attempts is performed using the following code.
   The procedure works only on filebacked objects, as memory based objects do not have alignment matrix attached to the pixels. If you are 
   investigating your crystal to find most suitable Bragg peaks, you may want to put this procedure at the beginning of each 
   :ref:`alignment iteration<Core Alignment>`. 
        
::

        % de-align crystal if aligned previously and set lattice to its theoretical value;
        rlu_rev_corr = crystal_alignment_info([a_theoretical,b_theoretical,c_theoretical],[alpha_theor,beta_theor,gama_theor]);
        sqw_obj = sqw(sqw_file_name,'file_backed',true); % build filebacked object to get access to pixels metadata
        if sqw_obj.pix.is_corrected
            rlu_rev_corr.rotmat = sqw_obj.pix.alignment_matr'; % retrieve alignment matrix and revert it.
        end
        clear sqw_obj;
        change_crystal(sqw_file_name,rlu_rev_corr); % apply original lattice and inverse orientation matrix to sqw file.



Once you have confirmed that the alignment you have is the correct one, it is possible to fix the alignment to avoid pixel ranges calculation step mentioned above.

.. _Finalize_alignment:

This is done using the ``finalize_alignment`` function:

::

   [wout, rev_corr] = finalize_alignment(win, ['-keep_original'])

Where:

- ``win`` - Input filename or ``sqw`` object to update.

- ``'-keep_original'`` - In the case of a file-backed ``sqw`` object, this will avoid overwriting the original datafile and retain the temporary
  file created as part of the calculation process.

- ``wout`` - Resulting ``sqw`` object to which the alignment was applied. If input was kept in file or was filebacked, the object will be filebacked.

- ``rev_corr`` - A corresponding ``crystal_alignment_info`` to be able to reverse the alignment excluding lattice changes. It contains inverted pixels alignment matrix and new lattice
  because you can not retrieve this information from pixels alignment matrix after applying ``change_crystal``.


.. Note::

   You must have attached the alignment to the ``sqw`` through the ``change_crystal`` function prior to applying it, as it will do nothing otherwise.


.. note::

   If you use ``'-keep_original'`` you may wish to ``save`` your resulting file-backed object as the temporary file will be cleared when the
   ``wout`` object goes out of scope. (see: file_backed_objects)


.. note::
   
   Finalize alignment of large ``sqw`` object may take substantial time. The time may be even bigger than regenerating this file from scratch as parallel 
   generation is currently possible for ``sqw`` files generation but not yet implemented for ``finalize_alignment`` algorithm. Option 2 below is recommended to use
   to finalize alignment in Horace-4.

Option 2 : calculate goniometer offsets for regeneration of sqw file(s)
-----------------------------------------------------------------------

In this case there is a single routine to calculate the new goniometer offsets, that can then be used in future sqw file generation.

::

   [alatt, angdeg, dpsi_deg, gl_deg, gs_deg] = crystal_pars_correct(u, v, alatt0, angdeg0, omega0_deg, dpsi0_deg, gl0_deg, gs0_deg, alignment_info, <keyword options>)


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

- ``alignment_info`` - The ``crystal_alignment_info`` object determined above.

The keywords options are:

.. warning::
   Normally keywords options need not be given and the inputs ``u``, ``v`` and ``omega`` will be used.

- ``u_new``, ``v_new`` - :math:`\vec{u}`, :math:`\vec{v}` that define the scattering plane. :math:`d\psi`,
  :math:`g_{l}`, :math:`g_{s}` will be calculated with respect to these vectors. (Default: ``u``, ``v`` respectively)


- ``omega_new`` - Value for the orientation of the virtual goniometer arcs. :math:`d\psi`,
  :math:`g_{l}`, :math:`g_{s}` will be calculated with respect to this offset angle. (Default: ``omega``) (|deg|)


The outputs are:

- ``alatt, angdeg`` - The true lattice parameters: :math:`[a_{true},b_{true},c_{true}]`,
  :math:`[\alpha_{true},\beta_{true},\gamma_{true}]` (in Å and |deg| respectively)

- ``dpsi_deg, gl_deg, gs_deg`` - Misorientation angles of the vectors ``u_new`` and ``v_new`` (all in |deg|)


Use the information, obtained from this routine as additional input to ``gen_sqw`` algorithm.


Option 2a : calculate the true u and v for your misaligned crystal
---------------------------------------------------------------------------------------------

This option is not recommended for use with Horace as goniometer offsets is preferred option to align ``sqw`` data. Some older programs (e.g. Mslice) may not give access to goniometer, so changing ``u`` and ``v`` may be the only way to align the data, or you may be just interested in actual beam direction with respect to crystal orientation.

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
======================================

Below we provide a brief summary of the routines available for different aspects of alignment corrections. For further information type

::

   help <function name>

in the Matlab command window.

bragg_positions
----------------

::

   [rlu0,width,wcut,wpeak] = bragg_positions(w, rlu, radial_cut_length, radial_bin_width, radial_thickness,...
                                             trans_cut_length, trans_bin_width, trans_thickness)

Get actual Bragg peak positions, given initial estimates of their positions, from an sqw object or file

bragg_positions_view
---------------------

::

   bragg_positions_view(wcut, wpeak)

View the output of fitting to Bragg peaks performed by ``bragg_positions``

crystal_pars_correct
---------------------

::

   [alatt, angdeg, dpsi_deg, gl_deg, gs_deg] = crystal_pars_correct(u, v, alatt0, angdeg0, omega0_deg, dpsi0_deg, gl0_deg, gs0_deg, al_info)

Return correct lattice parameters and crystal orientation for gen_sqw from a matrix that corrects the r.l.u.

refine_crystal
---------------------

::

   al_info = refine_crystal(rlu0, alatt0, angdeg0, bragg_peaks, [fix_])

Refine crystal orientation and lattice parameters

ubmatrix
---------------------

::

   [ub, mess, umat] = ubmatrix (u, v, b)


Calculate UB matrix that transforms components of a vector given in r.l.u. into the components in an orthonormal frame
defined by the two vectors u and v (each given in r.l.u)

uv_correct
---------------------

::

   [u_true, v_true, rlu_corr] = uv_correct (u, v, alatt0, angdeg0, omega_deg, dpsi_deg, gl_deg, gs_deg, alatt_true, angdeg_true)


Calculate the correct u and v vectors for a misaligned crystal, for use e.g. with Mslice.

rlu_corr_to_lattice
---------------------

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
