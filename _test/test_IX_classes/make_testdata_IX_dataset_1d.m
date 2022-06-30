function [hh_1d_gau,hp_1d_gau,pp_1d_gau]=make_testdata_IX_dataset_1d (nx0, nw)
% Create arrays of IX_dataset_1d with random x axes and Gaussian signal
%
%   >> [hh_1d_gau,hp_1d_gau,pp_1d_gau]=make_testdata_IX_dataset_1d (nx0, nw)
%
% The objects are different everytime this is run, as a random number generator is used.
%
% Input:
% -------
%   nx0                 Used to generate values of points along the x axis. Each
%                      IX_dataset_1d will have approximately nx0 points, with
%                      values approximately between 0 and 10.
%   nw                  Number of workspaces in the output IX_dataset_1d arrays
%
% Output:
% -------
%   hh_1d_gau           Array of nw IX_dataset_1d objects, all with different x, signal error
%                      arrays, mixed histogram and point datasets. The x arrays have
%                      different lengths, but are approximately on the range 0-10.
%                       The Gaussians correspond to an overall 2D Gaussian centred on x=5
%                      and the middle workspace number i.e. nw/2
%   hp_1d_gau           hist-point (different x,y,signal and errors)
%   pp_1d_gau           point-point (different x,y,signal and errors)
%
% Author: T.G.Perring



xrange=10;

% A big point array
% ------------------------------
tic
nx=nx0+round(0.2*nx0*rand(nw,1));
pp_1d_gau=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y=10*exp(-0.5*(((x-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    pp_1d_gau(i)=IX_dataset_1d(x,y,e,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
end
toc

% A big histogram array
% ------------------------------
tic
nx=nx0+round(0.2*nx0*rand(nw,1));
hh_1d_gau=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y=10*exp(-0.5*(((x-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    hh_1d_gau(i)=IX_dataset_1d(x,y,e,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
end
toc

% A big mixed histogram and point array
% -------------------------------------
tic
nx=nx0+round(0.2*nx0*rand(nw,1));
hp_1d_gau=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y=10*exp(-0.5*(((x-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    dn=round(rand(1));
    hp_1d_gau(i)=IX_dataset_1d(x,y(1:end-dn),e(1:end-dn),'Point data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);
end
toc
