function [x,hist,distr]=axis(w,n)
% Get the nth axis object and if is histogram
%
%   >> [x,hist,distr]=axis(w,n)
%
%   w   IX_datset_3d object 
%   n   Axis index. Can only be n=1,2 or 3 for IX_datset_3d object.

if numel(w)==1
    if n==1
        x=w.x;
        if numel(w.x)==size(w.signal,1)
            hist=false;
        else
            hist=true;
        end
        distr=w.x_distribution;
    elseif n==2
        x=w.y;
        if numel(w.y)==size(w.signal,2)
            hist=false;
        else
            hist=true;
        end
        distr=w.y_distribution;
    elseif n==3
        x=w.z;
        if numel(w.z)==size(w.signal,3)
            hist=false;
        else
            hist=true;
        end
        distr=w.z_distribution;
    else
        error('Axis index must be 1,2 or 3')
    end
else
    error('Can only have scalar input dataset')
end
