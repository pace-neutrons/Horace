function status = valid_components_ (obj)
% Return true if copmponents have valid locations and parameters
%
%   >> status = valid_components_ (obj)
%
% This method checks, for example, that the moderator is not coincident
% with the fermi chopper, or the shaping chopper is not before the
% moderator.
%
% Input:
% ------
%   obj     IX_mod_shape_chop object
%
% Output:
% -------
%   ok      True if valid, false otherwise


status = true;  % assume the best...

xmod = obj.moderator.distance;
xshape = obj.shaping_chopper.distance;
xmono = obj.mono_chopper.distance;

if ~(xmod > xshape && xshape > xmono)
    status = false;
end
