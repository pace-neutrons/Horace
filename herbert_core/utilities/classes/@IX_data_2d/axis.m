function [ax,hist]=axis(w,n)
% Get information for one or more axes and if is histogram data for each axis
%
%   >> [ax,hist]=axis(w)
%   >> [ax,hist]=axis(w,n)
%
% Input:
% -------
%   w       Single IX_datset_2d object
%   n       Axis index or array of indicies. Can only have elements equal
%          to 1 or 2 for IX_datset_2d object. (Default: [1,2])
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

if numel(w)==1
    if nargin==1
        n=[1,2];
    else
        if any(n)<1 || any(n)>2
            error('Check axis indicies equal 1 or 2')
        end
    end
    [ax,hist]=axis_n(w,n(1));
    for i=2:numel(n)
        ax(i)=axis_n(w,n(i));
    end
else
    error('Can only have scalar input dataset')
end

%--------------------------------------------------------------------------
function [ax,hist]=axis_n(w,n)
if n==1
    ax.values=w.x;
    ax.axis=w.x_axis;
    ax.distribution=w.x_distribution;
    if numel(w.x)==size(w.signal,1)
        hist=false;
    else
        hist=true;
    end
elseif n==2
    ax.values=w.y;
    ax.axis=w.y_axis;
    ax.distribution=w.y_distribution;
    if numel(w.y)==size(w.signal,2)
        hist=false;
    else
        hist=true;
    end
end
