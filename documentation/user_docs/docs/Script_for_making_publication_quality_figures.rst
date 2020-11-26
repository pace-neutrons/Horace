#############################################
Script for making publication quality figures
#############################################

::

   %Customising plots (mostly using Matlab tools to edit figures)

   proj.u=[1,0,0]; proj.v=[0,1,0]; proj.uoffset=[0,0,0,0]; proj.type='rrr';

   %=============================================
   %Make slice to plot
   my_slice=cut_sqw(sqw_file,proj,[-5,0.1,5],[-1,1],[-1,1],[0,10,900]);

   plot(smooth(compact(d2d(my_slice))));%default smoothing applied, compact function makes the axes tight around the data

   %Set the axes limits using lx, ly, lz commands


   %Make a nicer title
   title('QE slice');

   %Label the axes with something nicer
   xlabel('(h,0,0) (r.l.u.)');
   ylabel('Energy (meV)');

   %Get rid of the colour slider, but keep the colour bar (have to delete the slider, then replace with just the bar)
   colorslider('delete');
   colorbar

   %Make the above labels with a different font size to the default
   title('QE slice','FontSize',20);
   xlabel('(h,0,0) (r.l.u.)','FontSize',20);
   ylabel('Energy (meV)','FontSize',20);

   %Use the Matlab graphics handle to find out the font size of axes and associated properties
   get(gca,'FontSize');

   %or
   get(gca)
   %for a full list of properties

   %You can set a property of the figure using
   %set(gca,'PropertyName',Value)


   %Put some text on the figure (position in terms of the plot's units are the first two arguments)
   text(-0.5,220,'Ei = 1200 meV','FontSize',20);

   %Some fancier text to label the colour bar:
   tt=text(6.9,550,'Intensity (mb sr^-^1 meV ^-^1 f.u.^-^1)','FontSize',20);
   set(tt,'Rotation',-90);%Flip the text around so that it reads from top to bottom

   %Save as jpg and eps (colour)
   print('-djpeg ','/my_path/etc/fig_1a.jpg');
   print('-depsc ','/my_path/etc/fig_1a.eps');


   %=======================================

   %Make an array of 1d cuts to plot together:

   energy_range=[100:50:300];
   for i=1:numel(energy_range)
       my_cut(i)=cut_sqw(sqw_file,proj,[-5,0.1,5],[-1,1],[-1,1],[energy_range(i)-50,energy_range(i)+50]);
   end

   %plot them individually, to see what they look like first
   for i=1:numel(energy_range)
       plot(my_cut(i)); keep_figure;
   end

   %We want to plot them all on the same axes, with different colours and
   %markers.
   my_col={'black','red','blue','green','yellow'};
   my_mark={'+', 'o', '', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};%note these are all possible choices!

   for i=1:numel(my_cut)
       acolor(my_col{i})
       amark(my_mark{i});
       if i==1
	   plot(my_cut(i));
       else
	   pp(my_cut(i));%note the pp command overplots (markers and errorbars) on existing 1d axes
       end
   end

   %this is a bit messy. Let's add a constant offset between each cut, and make
   %the markers bigger
   my_offset=[0:0.3:1.2];


   for i=1:numel(my_cut)
       acolor(my_col{i})
       amark(my_mark{i},6);%second argument to amark is the size of the marker
       if i==1
	   plot(my_cut(i)+my_offset(i));
       else
	   pp(my_cut(i)+my_offset(i));
       end
   end

   %Further modification (e.g. axes, font sizes, etc) can be added in the same manner as for the 2d slice example above
