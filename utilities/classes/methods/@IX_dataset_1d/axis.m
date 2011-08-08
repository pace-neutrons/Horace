function [x,hist,distr]=axis(w,n)
% Get the nth axis object
%
%   >> [x,hist,distr]=axis(w,n)
%
%   w   IX_datset_1d object 
%   n   Axis index. Can only be n=1 for IX_datset_1d object.

if numel(w)==1 && n==1
    x=w.x;
    if numel(w.x)==numel(w.signal)
        hist=false;
    else
        hist=true;
    end
    distr=w.x_distribution;
else
    error('Can only have scalar input, and axis index n=1')
end
