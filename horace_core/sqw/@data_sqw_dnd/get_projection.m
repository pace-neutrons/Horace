function proj = get_projection(obj)
% Extract the projection, used to build data_sqw_dnd object from the object
% itself.
%
% This function just returns the projection for new (year 2021) sqw objects
% but used for compatibility with old sqw objects.
%
% TODO: needs refactoring with new projection. A bit dodgy in current state
%
alatt=obj.alatt;
angdeg=obj.angdeg;
bmat =  bmatrix (alatt, angdeg);
%
offset = obj.uoffset(:);
shift = ([bmat,[0;0;0];[0,0,0,1]]\offset)';
pix_range = obj.pix.pix_range-repmat(shift,2,1);
img_range_guess = range_add_border(pix_range,obj.border_size);
if  all(abs(img_range_guess(:)-obj.img_db_range(:))<=abs(obj.border_size)) || ...
        (all(obj.ulen == 1) && any(abs(diag(obj.u_to_rlu)-1)>eps)) % the input is the raw sqw object
    proj=ortho_proj();
    proj.alatt  = alatt;
    proj.angdeg = angdeg;

else % the input is the cut
    proj = ortho_proj('alatt',alatt,'angdeg',angdeg,'lab',obj.ulabel);
    proj = proj.set_from_ubmat(obj.u_to_rlu(1:3,1:3),obj.ulen(1:3));
end
proj.offset = obj.uoffset;



