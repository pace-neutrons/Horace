function pix_transf = transform_pix_to_img_(obj,pix_input,varargin)
% Transform pixels expressed in crystal Cartesian coordinate systems
% into image coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal Cartesian coordinate system
%             or pixelData object containing this information.
% Returns:
% pix_out -- [3xNpix or [4xNpix]Array the pixels coordinates transformed
%            into coordinatesystem, related to image (e.g. hkl system)
%
if isa(pix_input,'PixelDataBase')
    pix_cc = pix_input.q_coordinates;
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

[rot_to_img,shift]=obj.get_pix_img_transformation(ndim);
%
pix_transf= ((bsxfun(@minus,pix_cc,shift))'*rot_to_img')';
if input_is_obj
    if shift_ei
        ei = pix_input.dE -obj.offset(4);
    else
        ei = pix_input.dE;
    end
    pix_transf = [pix_transf;ei];
end
