function [ax,hist]=axis(w,n)
% Get information for one or more axes and if is histogram data for each axis
%
%   >> [ax,hist]=axis(w)
%   >> [ax,hist]=axis(w,n)
%
% Input:
% -------
%   w       Single IX_datset_2d object
%   n       Axis index, must be 1 for IX_dataset_1d.
%          (This syntax is uncluded only for compatibility with axis method for 2D, 3D, ... objects.
%           Accordingly, n can be an array too, but only with all elements equal to 1)
%
% Output:
% -------
%   ax      Structure or array structure with fields:
%             values          double    Values of bin boundaries (if histogram data)
%                                       Values of data point positions (if point data)
%             axis            IX_axis   x-axis object containing caption and units codes
%             distribution    logical   Distribution data flag (true is a distribution; false otherwise)
%
%   hist    Logical array with true for axes that are histogram data, false for point data

if nargin==1, n=1; end
if numel(w)==1 && all(n==1)
    ax.values=w.x;
    ax.axis=w.x_axis;
    ax.distribution=w.x_distribution;
    if numel(w.x)==size(w.signal,1)
        hist=false;
    else
        hist=true;
    end
    if numel(n)>1
        ax=repmat(ax,1,numel(n));
    end
else
    error('Can only have scalar input, and axis index n=1')
end
