function pix_coord = convert_img_to_pix_(obj,img_coord)
% convert image coordinates arrray crystal cartesian (pixels) coordinates
% system


if size(img_coord,1)~=4
    error('PROJECTION:invalid_argument',...
        ' images array must have 4 rows')
end

transf = obj.u_to_rlu;
pix_coord  = transf\img_coord;




