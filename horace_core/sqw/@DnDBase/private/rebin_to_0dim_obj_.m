function obj = rebin_to_0dim_obj_(obj,other_obj,keep_contents)
% rebin the contents of a n-dimensional object into empty 0-dimensional object
%
obj.axes.img_range = other_obj.axes.img_range;
obj.proj = other_obj.proj;
s = other_obj.s.*other_obj.npix;
e = other_obj.e.*other_obj.npix.^2;
if keep_contents
    obj.npix = obj.npix + sum(other_obj.npix(:));
    obj.s = obj.s*obj.npix + sum(s(:));
    obj.e = obj.e*obj.npix^2 + sum(e(:));
else
    obj.npix = sum(other_obj.npix(:));
    obj.s = sum(s(:));
    obj.e = sum(e(:));
end
obj.s = obj.s/obj.npix;
obj.e = obj.e/(obj.npix*obj.npix);