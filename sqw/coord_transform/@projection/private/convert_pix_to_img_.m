function img_coord = convert_pix_to_img_(obj,pix_coord)
% convert pixels coordinates into image coordinates expressed
% in appropriate units.

transf = obj.u_to_rlu;
if size(pix_coord,1)<4
    error('PROJECTION:invalid_argument',...
        ' pixels array must have not less than 4 rows')
end
if size(pix_coord,1) > 4
    tmp_img = transf*pix_coord(1:4,:);
    img_coord = [tmp_img;pix_coord(5:end,:)];
else
    img_coord  = transf*pix_coord;
end



