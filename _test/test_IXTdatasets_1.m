%   IXTbase             IXTbase
% 	title				char			Title of dataset for plotting purposes
% 	signal				real    		Signal
% 	error				real    		Standard error
% 	s_axis				IXTaxis			S axis object containing caption and units codes
% 	x					real        	values of bin boundaries along x-axis(if histogram data)
% 						real            values of data point positions along x-axis(if point data)
% 	x_axis				IXTaxis			x axis object containing caption and units codes
% 	x_distribution      logical         x-data distribution data flag
% 	y					real        	values of bin boundaries along y-axis(if histogram data)
% 						real            values of data point positions along y-axis(if point data)
% 	y_axis				IXTaxis			y axis object containing caption and units codes
% 	y_distribution      logical         z-data distribution data flag
% 	z					real        	values of bin boundaries along z-axis(if histogram data)
% 						real            values of data point positions along z-axis(if point data)
% 	z_axis				IXTaxis			z axis object containing caption and units codes
% 	z_distribution      logical         z-data distribution data flag

nx=10;ny=15;nz=20;

x=1:nx;
y=1:ny;
z=1:nz;
signal=5*rand(10,15,20);
error=0.5*rand(10,15,20);

title='The Tiltle';
s_axis=IXTaxis('Hello');
x_axis=IXTaxis('x Hello');
y_axis=IXTaxis('y Hello');
z_axis=IXTaxis('z Hello');

x_distribution=true;
y_distribution=true;
z_distribution=true;

w3=IXTdataset_3d(IXTbase,title,signal,error,s_axis,x,x_axis,x_distribution,y,y_axis,y_distribution,z,z_axis,z_distribution);

%-----------------
sliceomatic(ux, uy, uz, w.signal, keyword.x_axis, keyword.y_axis, keyword.z_axis,...
                        xlabel, ylabel, zlabel, clim, keyword.isonormals);
%-----------------
pax = win.data.pax;
dax = win.data.dax;                 % permutation of projection axes to give display axes
ulabel = win.data.ulabel(pax(dax)); % labels in order of the display axes
ulen = win.data.ulen(pax(dax));     % unit length in order of the display axes

clim = [min(w.signal(:)) max(w.signal(:))];
[title_main, title_pax] = plot_titles (win);    % note: axes annotations correctly account for permutation in w.data.dax

title_main={'hello','Mister Cat'};
title_pax={'The first axis','The second axis','The third axis'};
[figureHandle_, axesHandle_, plotHandle_]=sm(w3, 'clim', clim, ...
    'title', title_main, 'xlabel', title_pax{1}, 'ylabel', title_pax{2}, 'zlabel', title_pax{3},...
    'x_sliderlabel', ['axis 1: '], 'y_sliderlabel', ['axis 2: '],  'z_sliderlabel', ['axis 3: '],...
    );

% Resize the box containing the data
% set(gca,'Position',[0.225,0.225,0.55,0.55]);
set(gca,'Position',[0.2,0.2,0.6,0.6]);
axis normal
