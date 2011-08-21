function [xv,yv,z]=prepare_for_patch(x,y,signal)
% Prepare arrays suitable for patch function
%
%   >> [xv,yv,z]=prepare_for_patch(x,y,signal)
%
% Input:
% ------
%   x       x-axis values (vector length m)
%   y       y axis values (vector length n)
%   signal  Intensity array size=[M,N] where M=m or m-1, and N=n or n-1
%           depending on whether or not the corresponding axis values
%           are bin boundaries or bin centres.
%
% Output:
% -------
%   xv      x-coords of verticies for patch plot
%   yv      y-coords of verticies for patch plot
%   z       Intensity array correctly ordered for use in patch plot


nx = size(signal,1);
ny = size(signal,2);
npatch = nx*ny;

if numel(x)==nx
    x=bin_boundaries_simple(x);
end
if numel(y)==ny
    y=bin_boundaries_simple(y);
end
if size(x,1)>1, x=x'; end   % make row
if size(y,1)>1, y=y'; end   % make row

xv = [x(1:end-1);x(2:end);x(2:end);x(1:end-1)];
xv = repmat(xv,1,ny);

yv = [y(1:end-1);y(1:end-1);y(2:end);y(2:end)];
yv = repmat(yv,nx,1);
yv = reshape(yv,4,npatch);

z=signal(:)';
