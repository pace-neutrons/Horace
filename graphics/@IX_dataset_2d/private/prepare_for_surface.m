function [xv,yv,z,c]=prepare_for_surface(x,y,signal,error)
% Prepare arrays suitable for surface plot
%
%   >> [xv,yv,z]=prepare_for_surf(x,y,signal)
%
% Input:
% ------
%   x       x-axis values (vector length m)
%   y       y axis values (vector length n)
%   signal  Intensity array size=[M,N] where M=m or m-1, and N=n or n-1
%           depending on whether or not the corresponding axis values
%           are bin boundaries or bin centres.
%   error   [Optional] Matching error array
%
% Output:
% -------
%   xv      x-coords of verticies for surface plot
%   yv      y-coords of verticies for surface plot
%   z       Intensity array correctly ordered for use in surface plot
%   c       Error array equivalently ordered, if error array provided as input


nx = size(signal,1);
ny = size(signal,2);

if numel(x)~=nx
    x=0.5*(x(1:end-1)+x(2:end));
end
if numel(y)~=ny
    y=0.5*(y(1:end-1)+y(2:end));
end

[xv,yv]=ndgrid(x,y);
z=signal;
if nargin==4
    c=error;
end
