function [ax,hist]=axis(w,n)
% Get information for one or more axes and if is histogram data for each axis
%
%   >> [ax,hist]=axis(w)
%   >> [ax,hist]=axis(w,n)
%
% Input:
% -------
%   w       IX_datset_xxx object
%   n       Axis index, must be 1 for IX_dataset_1d. (Default: [1])
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

if nargin==1
    n=1;
else
    if ~all(n==1)
        error('IX_dataset:invalid_argument',...
            'Can only have scalar input, and axis index n=1')
    end
end

ax = struct();
[ax,hist] = set_struct(ax,w(1));
if numel(w)>1
    ax=repmat(ax,1,numel(w));
    hist =repmat(hist,1,numel(w));
    for i=1:numel(w)
        [ax(i),hist(i)] = set_struct(ax(i),w(i));
    end
end


function [aa,hist] = set_struct(aa,w)
aa.values=w.x;
aa.axis=w.x_axis;
aa.distribution=w.x_distribution;
if numel(w.x)==size(w.signal,1)
    hist=false;
else
    hist=true;
end

