function [pix_min,pix_max] = calc_pix_range_(obj,pixels,pix_range)

if nargin<3
    pix_min = min(pixels,[],2);
    pix_max = max(pixels,[],2);    
else
    pix_min = pix_range(:,1);
    pix_max = pix_range(:,2);    
end
pix_min = min(pix_min,obj.pix_min_);
pix_max = max(pix_max,obj.pix_max_);

