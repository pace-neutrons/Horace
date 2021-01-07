#########################
Script for data treatment
#########################

::

   proj.u=[1,0,0]; proj.v=[0,1,0]; proj.uoffset=[0,0,0,0]; proj.type='rrr';


   %==Background subtraction (including cuts, replication, binary operation)==

   my_slice=cut_sqw(sqw_file,proj,[2,0.1,6],[-1.1,-0.9],[-0.1,0.1],[0,10,1000]);%make a slice from which you wish to subtract a background
   %this makes most sense for QE slices, but can be done for QQ slices too.
   plot(my_slice);

   my_bg=cut(my_slice,[5,6],[]);%take a cut from this slice, going along the energy axis
   plot(my_bg);

   %Now replicate this 1d background into a 2d slice. Note that we must operate on dnd data objects now, because by doing this subtraction we lose
   %contact with the true original data
   my_bg_rep=replicate(d1d(my_bg),d2d(my_slice));%we replicate the 1d cut to 2d using the original slice as the template (for Q range etc)

   plot(my_bg_rep)

   my_slice_subtracted=d2d(my_slice) - my_bg_rep;%Just use the binary operation '-' to subtract the background slice
   plot(my_slice_subtracted);


   %=========== Symmetrisation =============================

   my_slice2=cut_sqw(sqw_file,proj,[-5,0.1,3],[-3,0.1,3],[-0.1,0.1],[500,600]);
   plot(my_slice2);

   %Fold along vertical (look at the proj axes above) - we specify the fold using a plane. The plane is specified by providing two non-parallel vectors that lie in it
   %the cross-product of the vectors define the plane normal. The position of the plane w.r.t. the origin is given by the 3rd vector argument
   %in this case (and most cases) it is not offset from the origin

   my_sym=symmetrise_sqw(my_slice2,[0,1,0],[0,0,1],[0,0,0]);
   plot(my_sym);

   %Two folds along diagonals
   my_sym2=symmetrise_sqw(my_slice2,[1,1,0],[0,0,1],[0,0,0]);
   my_sym2=symmetrise_sqw(my_sym2,[-1,1,0],[0,0,1],[0,0,0]);
   plot(my_sym2);

   %========== Bose factor correction ==============

   my_slice_bose=bose(my_slice,300);%data taken at 300K

   plot(my_slice_bose);
