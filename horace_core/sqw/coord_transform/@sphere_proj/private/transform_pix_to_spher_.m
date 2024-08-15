function pix_transf = transform_pix_to_spher_(obj,pix_input,varargin)
% Transform pixels expressed in crystal Cartesian coordinate systems
% into image coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal Cartesian coordinate system
%             or pixelData object containing this information.
% Returns:
% pix_out -- [3xNpix or [4xNpix] Array the pixels coordinates transformed
%            into spherical coordinate system defined by object properties
%
if isa(pix_input,'PixelDataBase')
    if pix_input.is_misaligned
        pix_cc = pix_input.get_raw_data('q_coordinates');
    else
        pix_cc = pix_input.q_coordinates;
    end
    shift_ei = obj.offset(4) ~=0;

    ndim = 3;
    input_is_obj = true;
else % if pix_input is 4-d, this will use 4-D matrix and shift
    % if its 3-d -- matrix is 3-dimensional and energy is not shifted
    % anyway
    ndim         = size(pix_input,1);
    pix_cc       = pix_input;
    input_is_obj = false;
end

[rot_mat,offset_cc,scales,offset_present,obj] = ...
    obj.get_pix_img_transformation(ndim,pix_input);

%
if offset_present
    pix_transf= (rot_mat*(bsxfun(@minus,pix_cc,offset_cc(:))));
else
    pix_transf=  rot_mat*pix_cc;
end
[azimuth,elevation,r] = cart2sph(pix_transf(1,:),pix_transf(2,:),pix_transf(3,:));

if ndim == 4
    pix_transf = [r/scales(1); scales(2)*(pi/2-elevation); azimuth*scales(3); pix_transf(4,:)];
else
    pix_transf = [r/scales(1); scales(2)*(pi/2-elevation); azimuth*scales(3)];
end
% set phi = 0 for r == 0
r_zero = abs(pix_transf(1,:))<eps('double');
pix_transf(2,r_zero) = 0;
if input_is_obj
    if shift_ei
        ei = pix_input.dE -obj.offset(4);
    else
        ei = pix_input.dE;
    end
    pix_transf = [pix_transf;ei];
end
