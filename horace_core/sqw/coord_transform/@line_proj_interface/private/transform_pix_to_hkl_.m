function [pix_hkl,ei] = transform_pix_to_hkl_(obj,pix_input,varargin)
% Transform pixels expressed in crystal Cartesian coordinate systems
% into image coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal Cartesian coordinate system
%             or pixelData object containing this information.
% Returns:
% pix_hkl -- [3xNpix] or [4xNpix] array the pixels coordinates transformed
%            into hkl coordinate system
%

alignment_needed = false;
if isa(pix_input,'PixelDataBase')
    pix_cc = pix_input.q_coordinates;
    ndim = 3;
    input_is_obj = true;
    if pix_input.is_misaligned
        alignment_needed = true;
        alignment_mat = pix_input.alignment_matr;
    end
else % if pix_input is 4-d,
    ndim = size(pix_input,1);
    pix_cc = pix_input(1:3,:);
    input_is_obj = false;

end

if ~isempty(obj.ub_inv_legacy) % legacy alignment
    transf_to_hkl = inv(obj.ub_inv_legacy(1:3,1:3));
else
    transf_to_hkl = obj.bmatrix();
end
%
if alignment_needed
    pix_hkl= (transf_to_hkl\alignment_mat)*pix_cc;
else
    pix_hkl= transf_to_hkl\pix_cc;
end

if input_is_obj
    ei = pix_input.dE;
else
    if ndim == 3
        ei = [];
    else
        ei = pix_input(4,:);
    end
end
