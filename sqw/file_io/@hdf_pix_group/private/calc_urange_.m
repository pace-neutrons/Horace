function [umin,umax] = calc_urange_(obj,pixels,urange)

if nargin<3
    umin = min(pixels,[],2);
    umax = max(pixels,[],2);    
else
    umin = urange(:,1);
    umax = urange(:,2);    
end
umin = min(umin,obj.pix_min_);
umax = max(umax,obj.pix_max_);

