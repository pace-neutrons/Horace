function [is,mess] = eq_to_tol_type_equal_(pix1,pix2,name_a,name_b)
% Helper function used by equal_to_tol to validate
% if type of two objects is equal for purposes of equal_to_tol comparison
% procedure
% Overload used in equal_to_tols to check types allowed for compariosn
% pixes allow comparison of two classes PixelDataMemory and PixelDataFile
%
% Inputs:
% obj1    -- object 1 to compare
% obj2    -- object 2 to compare
%
% Optional:
% name_a  -- the name of first object in comparison
% name_b  -- the name of second object in comparison
%            These names become part of information message in case if
%            objects types are different
%
% Returns:
% is      -- true if objects types are equal and false if not.
% mess    -- the message providing additinal information about object types
%            it the types are different
%
is   = true;
mess = '';

% first object is certanly PixelDataBase. Check sececond

right_type = isa(pix2,'PixelDataBase');
if right_type
    right_npix = pix1.num_pixels == pix2.num_pixels;
    if right_npix
        return
    end
end

if nargin<3
    name_a = 'input_1';
end
if nargin<4
    name_b = 'input_2';
end

is = false;
if ~right_type
    mess = sprintf('Objects have different types. var:"%s" has class: "%s" and var:"%s" class: "%s"', ...
        name_a,class(pix1), name_b,class(pix2));
    return;
end

mess = sprintf(['PixelData objects have different number of pixels. ', ...
    'var:%s has: %i pixels and var:%s has: %i'], ...
    name_a,pix1.num_pixels,name_b, pix2.num_pixels);
end