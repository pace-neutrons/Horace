function [hh_gau,hp_gau,pp_gau] = make_testdata_IX_dataset_2d (nx, ny)
% Create IX_dataset_2d object with random x and y axes and Gaussian signal centred on [5,3]
%
%   >> [hh_gau,hp_gau,pp_gau] = make_testdata_IX_dataset_2d (nx, ny)
%
% The objects are different everytime this is run, as a random number generator is used.
%
% Input:
% ------
%   nx          Number of x bin boundaries
%   ny          Number of y values
%
% Output:
% -------
%   hh_gau      hist-hist 2D Gaussian with range x=c. 0-10 and y=c. 0-6
%   hp_gau      hist-point (different x,y,signal and errors)
%   pp_gau      point-point (different x,y,signal and errors)
%
% Author: T.G.Perring

xrange=10;
yrange=6;

% hist-hist
x=xrange*sort(rand(1,nx));
y=yrange*sort(rand(1,ny));
[xx,yy]=ndgrid(x,y);
signal=10*exp(-0.5*(((xx-xrange/2)/(xrange/4)).^2 + ((yy-yrange/2)/(yrange/4)).^2));
err=0.5+rand(nx,ny);

hh_gau=IX_dataset_2d(x,y,signal(1:end-1,1:end-1),err(1:end-1,1:end-1),'hist-hist',IX_axis('Energy transfer','meV','$w'),'Temperature','Counts',false,false);

% hist-point
x=xrange*sort(rand(1,nx));
y=yrange*sort(rand(1,ny));
[xx,yy]=ndgrid(x,y);
signal=10*exp(-0.5*(((xx-xrange/2)/(xrange/4)).^2 + ((yy-yrange/2)/(yrange/4)).^2));
err=0.5+rand(nx,ny);
    
hp_gau=IX_dataset_2d(x,y,signal(1:end-1,:),err(1:end-1,:),'hist-pnt',IX_axis('Energy transfer','meV','$w'),'Temperature','Counts',false,false);

% point-point
x=xrange*sort(rand(1,nx));
y=yrange*sort(rand(1,ny));
[xx,yy]=ndgrid(x,y);
signal=10*exp(-0.5*(((xx-xrange/2)/(xrange/4)).^2 + ((yy-yrange/2)/(yrange/4)).^2));
err=0.5+rand(nx,ny);
    
pp_gau=IX_dataset_2d(x,y,signal,err,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'Temperature','Counts',false,false);
