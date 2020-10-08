function [ok, mess] = equal_to_tol(obj, other_pix, varargin)
%% EQUAL_TO_TOL Check if two PixelData objects are equal to a given tolerance
%
if ~(isa(other_pix, 'PixelData'))
    ok = false;
    mess = sprintf('Objects of class ''%s'' and ''%s'' cannot be equal.', ...
                   class(obj), class(other_pix));
    return
end

if obj.num_pixels ~= other_pix.num_pixels
    ok = false;
    mess = sprintf(['PixelData objects are not equal. '...
                    'Argument 1 has ''%i'' pixels, argument 2 has ''%i'''], ...
                   obj.num_pixels, other_pix.num_pixels);
    return
end
