function [irange,contained]=interval_in_array(x,interval,hist)
%  Find minimum enclosing range of an array of points or bin boundaries that enclose an interval.
%
%   >> [irange,contained]=interval_in_array(x,interval,bins)
%
% Input:
%   x           Array of x values or bin boundaries, assumed monotonic increasing.
%               If boundaries, must have length at least two.
%
%   interval    [xlo,xhi], the interval, assumed xlo<=xhi.
%
%   hist        =true if x are bin boundaries
%               =false if points
%
% Output:
%   irange      1x2 array of lower and upper point/bin indices that enclose interval, or that
%              part of the interval that intersects with the x array.
%               If no data enclosed or on the boundaries at all, then irange=[]
%
%   contained   =true if range fully contained in bins
%               =false if not

nx=numel(x);
if nx==1 && hist
    error('Number of elements must exceed one if contains bin boundaries')
end

% Catch case when interval entireluy outside range
if interval(1)>x(end)||interval(2)<x(1)
    irange=[]; contained=false;
    return
end

% Get indicies of points that enclose the range.
ilo=upper_index(x,interval(1));
ihi=lower_index(x,interval(2));

if ilo==0 || ihi>nx
    contained=false;
else
    contained=true;
end

% Ensure that the range -Inf, +Inf rounded towards limits of data
irange=[max(ilo,1),min(ihi,nx)];

if hist
    if irange(1)~=irange(2)
        irange(2)=irange(2)-1;      % so the index elements refer to bin numbers, not boundary numbers
    elseif irange(2)==nx
        irange=irange-1;
    end
end
