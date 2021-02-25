function proj = get_projection(obj)
% Extract the projection, used to build data_sqw_dnd object from the object
% itself.
%
% This function just returns the projection for new (year 2021) sqw objects
% but used for compartibility with old sqw objects.
%
% TODO: needs refactoring with new projection
alatt=obj.alatt;
angdeg=obj.angdeg;

pix_range = obj.pix.pix_range;
img_range_guess = range_add_border(pix_range,obj.border_size);
if any(abs(img_range_guess-obj.img_range)>abs(obj.border_size))  % the input is the cut
    [u,v]=projection.uv_from_rlu_mat(alatt,angdeg,obj.u_to_rlu(1:3,1:3),...
        obj.ulen(1:3));
    proja = projaxes(u,v,'lab',obj.ulabel);
    proj = projection(proja);
else % the input is the raw sqw object
    proj=projection();
end
proj.alatt=alatt;
proj.angdeg=angdeg;



