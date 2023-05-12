function pix_transf = transform_pix_to_img_(obj,pix_input,varargin)
% Transform pixels expressed in crystal Cartesian coordinate systems
% into image coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal Cartesian coordinate system
%             or pixelData object containing this information.
% Returns:
% pix_out -- [3xNpix] or [4xNpix] array the pixels coordinates transformed
%            into coordinate system, related to the image (e.g. hkl system)
%
if isa(pix_input,'PixelDataBase')
    if pix_input.is_misaligned
        pix_cc = pix_input.get_raw_data('q_coordinates');
    else
        pix_cc = pix_input.q_coordinates;
    end
    if obj.offset(4) ~=0
        shift_ei = true;
    else
        shift_ei = false;
    end
    ndim   = 3;
    input_is_obj = true;
else % if pix_input is 4-d, this will use 4-D matrix and shift
    % if its 3-d -- matrix is 3-dimensional and energy is not shifted
    % anyway
    pix_cc = pix_input;
    ndim = size(pix_cc,1);
    input_is_obj = false;
end

[pix_to_img,offset]=obj.get_pix_img_transformation(ndim,pix_input);
%
pix_transf= ((pix_to_img'*bsxfun(@minus,pix_cc,offset(:))));
if input_is_obj
    if shift_ei
        ei = pix_input.dE -obj.offset(4);
    else
        ei = pix_input.dE;
    end
    pix_transf = [pix_transf;ei];
end
