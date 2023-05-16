function pix_transf = do_ortho_ortho_transformation_(...
    obj,pix_input,varargin)
% convert image coordinates expressed in one image coordinate system
% into image coordinates expressed in another image coordinate system
% given that both coordinate systems are defined by the similar ortholinear
% transformations, so the final transformation is the shift and rotation
% with respect to current coordinate system.
%

if obj.offset(4) ~=0
    shift_ei = true;
else
    shift_ei = false;
end

if isa(pix_input, 'PixelDataBase')
    pix_coord = pix_input.q_coordinates;
    input_is_obj = true;
else
    ndim = size(pix_input,1);
    if ndim == 4
        ei = pix_input(4,:);
        pix_coord = pix_input(1:3,:);
    else
        pix_coord = pix_input;
    end
    input_is_obj = false;
end


%
shift = obj.ortho_ortho_offset_(1:3);
pix_transf= (bsxfun(@plus,obj.ortho_ortho_transf_mat_*pix_coord,shift(:)));

if input_is_obj
    if shift_ei
        ei = pix_input.dE -obj.shift(4);
    else
        ei = pix_input.dE;
    end
    pix_transf = [pix_transf;ei];
else
    if shift_ei
        ei = ei + obj.ortho_ortho_offset_(4);
    end
    if ndim == 4
        pix_transf = [pix_transf;ei];
    end
end
