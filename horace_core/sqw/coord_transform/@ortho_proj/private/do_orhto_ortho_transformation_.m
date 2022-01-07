function pix_transf = do_orhto_ortho_transformation_(...
    obj,pix_input,varargin)
% convert image


if obj.offset(4) ~=0
    shift_ei = true;
else
    shift_ei = false;
end


if isa(pix_input,'PixelData')
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
pix_transf= (bsxfun(@plus,pix_coord'*obj.ortho_ortho_transf_mat_,shift))';

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
    pix_transf = [pix_transf;ei];
end

