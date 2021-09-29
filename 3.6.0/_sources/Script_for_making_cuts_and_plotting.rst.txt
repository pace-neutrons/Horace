###################################
Script for making cuts and plotting
###################################

::

   %Make different kinds of cuts and slices, and make basic plots of them

   %===============================
   %First define the viewing axes that you wish to use. These do not need to have any particular relation to the
   %spectrometer axes
   proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.uoffset=[0,0,0,0]; proj.type='rrr';
   proj2.u=[1,0,0]; proj2.v=[0,1,0]; proj2.uoffset=[0,0,0,0]; proj2.type='rrr';
   proj3.u=[1,1,1]; proj3.v=[-1,1,0]; proj3.uoffset=[0,0,0,0]; proj3.type='rrr';

   %The u and v fields of proj define the first two viewing axes, and the third Q dimension is the cross-product
   %of them. The uoffset is if you wish to explicitly give an offset from the origin for your cuts / slices.
   %The type field (the best choice is 'rrr') is to say that all 3 Q axes should be in reciprocal lattice units.
   %If you prefer inverse Angstroms then use 'aaa'

   %================================

   %3d volume slice and plot
   my_vol=cut_sqw(sqw_file,proj,[0,0.1,8],[2,0.05,6],[-2,-1],[0,10,1000],'-nopix');%Makes a Q,Q,E volume plot
   %the -nopix option ensures that the output is a "d3d", which takes less memory on your computer

   plot(my_vol);%default style plot of the 3d volume - opens a new sliceomatic window


   %================================

   %2d slice and plot
   my_slice=cut_sqw(sqw_file,proj,[0,0.1,8],[4,5],[-2,-1],[0,10,10000]);%Make as Q,E slice
   %this time we did not use the nopix option, so the output is an "sqw", in which all contributing detector pixel information is retained

   plot(my_slice);%default style plot of 2d slice

   %Customise the slice plot:

   %Make axes tight
   plot(compact(my_slice));

   %Default style smoothing (notice conversion to d2d first, since smoothing of sqw objects is not allowed, due to their strong connection to the raw data)
   plot(smooth(d2d(my_slice)));

   %Smoothing options
   plot(smooth(d2d(my_slice),[2,2],'gaussian'));

   %Set colour scale and other axes scales in script:
   lz 0 0.5; %colour scale
   ly 50 250
   lx -1.5 1.5

   %Reset a limit
   lx

   %Make a plot, and retain the figure window so that the next plot appears in a new window, and does not replace this one
   plot(my_slice);
   keep_figure;


   %================================

   %1d cut

   my_cut1=cut_sqw(sqw_file,proj,[0,0.1,8],[5,6],[-0.1,0.1],[130,150]);

   plot(my_cut1);%the lx and ly axes adjustment can be used here too

   %Specify the colour, marker and other characteristics of the plot. Note you must set these first, then make the plot
   acolor red
   amark s
   plot(my_cut1);

   %Overplot another cut on the same set of axes (in this example just the first cut plus a constant):
   acolor black
   amark o
   pp(my_cut1+3); %the pp command overplots a "plot"

   %you can overplot a line using "pl", just markers using "pm", just errorbars using "pe".


   %================================

   %Taking a cut from a cut (CAN GIVE BIG SPEED SAVINGS):

   %If you have a volume or slice, you can take a lower dimensional cut from it. Because the data are already in memory this
   %is much faster than going back to the data file on disk

   my_cut2=cut(my_slice,[],[130,150]);
   %note you do not need to specify all 4 axes, because some (in this case 2) have already been integrated
   %the empty array [] specifies that you want to keep the same binning as that used in my_slice
