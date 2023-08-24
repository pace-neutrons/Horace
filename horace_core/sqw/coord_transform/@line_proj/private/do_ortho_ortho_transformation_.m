function pix_transf = do_ortho_ortho_transformation_(...
    obj,img_input,varargin)
% convert image coordinates expressed in one image coordinate system
% into image coordinates expressed in another image coordinate system
% given that both coordinate systems are defined by the similar ortholinear
% transformations, so the final transformation is the shift and rotation
% with respect to current coordinate system.
%

ndim = size(img_input,1);
if abs(obj.offset(4))>4*eps('single') && ndim > 3
    shift_ei = true;
else
    shift_ei = false;
end

if isa(img_input, 'PixelDataBase')
    error('HORACE:line_proj:invalid_argument',...
        'ortho-ortho transformation should not expect PixelData');
else
    if ndim == 4
        ei = img_input(4,:);
        img_coord = img_input(1:3,:);
    else
        img_coord = img_input;
    end
end

%
shift = obj.ortho_ortho_offset_(1:3);
pix_transf= (bsxfun(@plus,obj.ortho_ortho_transf_mat_*img_coord,shift(:)));

if shift_ei
    ei = ei + obj.ortho_ortho_offset_(4);
end
if ndim == 4
    pix_transf = [pix_transf;ei];
end

