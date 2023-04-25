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

    ndim = 3;
    [rot_to_img,shift]=obj.get_pix_img_transformation(ndim);

    pix_transf = zeros(4, pix_input.num_pixels);
    shift_ei = obj.offset(4) ~= 0;

    pix_transf(1:3, :) = rot_to_img * (pix_input.q_coordinates - shift);

    if shift_ei
        pix_transf(4, :) = pix_input.dE - obj.offset(4);
    else
        pix_transf(4, :) = pix_input.dE;
    end

else
    % if pix_input is 4-d, this will use 4-D matrix and shift
    % if its 3-d -- matrix is 3-dimensional and energy is not shifted
    % anyway
    ndim = size(pix_input, 1);
    [rot_to_img, shift]=obj.get_pix_img_transformation(ndim);

    pix_transf = rot_to_img * (pix_input - shift);
end

end
