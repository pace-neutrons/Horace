#########################################
Script for correcting sample misalignment
#########################################

::

   %============= Correcting for sample misalignment ==============

   %Make a series of hk-slices at different l, in order to work out what Bragg positions we have.
   %Note because elastic we use relatively tight integration, and small step sizes
   alignment_slice1=cut_sqw(sqw_file,proj,[-8,0.03,8],[-8,0.03,8],[-0.05,0.05],[-2,2],'-nopix');
   alignment_slice2=cut_sqw(sqw_file,proj,[1.95,2.05],[-8,0.03,8],[-8,0.03,8],[-2,2],'-nopix');
   alignment_slice3=cut_sqw(sqw_file,proj,[-8,0.03,8],[-0.05,0.05],[-8,0.03,8],[-2,2],'-nopix');


   plot(compact(alignment_slice1)); keep_figure;
   plot(compact(alignment_slice2)); keep_figure;
   plot(compact(alignment_slice3)); keep_figure;


   %Our notional Bragg peaks
   bp=[6,0,0; 3,0,0; 2,1,0; 4,4,0; 2,0,2];


   %Get true Bragg peak positions
   [rlu0,width,wcut,wpeak]=bragg_positions(sqw_file, bp, 1.5, 0.06, 0.4,...
					1.5, 0.06, 0.4, 20, 'gauss','bin_ab');

   %Check how well the function did:
   bragg_positions_view(wcut,wpeak)


   %Determine corrections to lattice and orientation (in this example we choose to keep the lattice angles fixed,
   %but allow the lattice parameters to be refined, keeping a cubic structure by keeping ratios of lattice pars to be same):
   [rlu_corr,alatt,angdeg] = refine_crystal(rlu0, alatt, angdeg, bp,'fix_angdeg','fix_alatt_ratio');


   %Apply changes to sqw file
   change_crystal_horace(sqw_file, rlu_corr);


   %Check the outcome: Get Bragg peak positions and look at output: should be much better
   [rlu0,width,wcut,wpeak]=bragg_positions(sqw_file, bp, 1.5, 0.06, 0.4,...
					1.5, 0.06, 0.4, 20, 'gauss','bin_ab');
   bragg_positions_view(wcut,wpeak)
