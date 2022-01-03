function pix_transf = transform_pix_to_img_(obj,pix_input,varargin)
% Transform pixels expressed in crystal Cartesian coordinate systems
% into image coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal Cartesian coordinate system
%             or pixelData object.
% Returns:
% pix_out -- the pixels coordinates transformed into coordinate
%             system, related to image (e.g. hkl system)
%
if isa(pix_input,'PixelData')
    pix_cc = pix_input.q_coordinates;
    if obj.shift(4) ~=0
        shift_ei = true;
    else
        shift_ei = false;
    end
    ndim   = 3;
    pix_input = true;
else
    pix_cc = pix_input;
    ndim = size(pix_cc,1);
    pix_input = false;
end

[rot_to_img,shift]=obj.get_pix_img_transformation(ndim);
%
pix_transf= ((bsxfun(@minus,pix_cc,shift))'*rot_to_img')';
if pix_input
    if shift_ei
        ei = pix_input.dE -obj.shift(4);
    else
        ei = pix_input.dE;
    end
    pix_transf = [pix_transf;ei];
end

