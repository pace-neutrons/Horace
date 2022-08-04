function proj = get_projection(obj,header_av)
% Extract the ortho_proj used to build old style data_sqw_dnd object
% from the object itself.
%
% This function just returns the projection for new (year 2021) sqw objects
% but used for compatibility with old sqw objects.
%
% TODO: needs refactoring with new projection. A bit dodgy in current state
% will go to compartibility with old versions in a future.
%
alatt=obj.alatt;
angdeg=obj.angdeg;
if exist('header_av','var')
    bmat_inv_ext  =  header_av.u_to_rlu;
else
    bmat_inv_ext   = [];
    bmat =     bmatrix(alatt,angdeg);
end

proj = obj.proj;
offset = proj.offset';
%
if isempty(bmat_inv_ext)
    shift = (bmat\offset(1:3))';
    shift = [shift,offset(4)];
else
    shift = (bmat_inv_ext*offset)';
end
% attempt to identify if original sqw file
% is newly generated one or is the cut. There is difference in
% transformations between them in old Horace.
pix_range = obj.pix.pix_range-repmat(shift,2,1);
img_range_guess = range_add_border(pix_range,obj.border_size);
if  all(abs(img_range_guess(:)-obj.img_db_range(:))<=abs(obj.border_size)) || ...
        (all(obj.ulen == 1) && any(abs(diag(obj.u_to_rlu)-1)>eps)) % the input is the raw sqw object
    if any(abs(diag(obj.u_to_rlu)-1)>eps)
        proj = proj.set_from_data_mat(obj.u_to_rlu(1:3,1:3),obj.ulen(1:3));
    end
else % the input is the cut
    proj = proj.set_from_data_mat(obj.u_to_rlu(1:3,1:3),obj.ulen(1:3));
end

%--------------------------------------------------------------------------
% TODO: this is compatibility function to support alignment.
% This will change when alginment matrix is attached to pixels
if ~isempty(bmat_inv_ext)
    proj = proj.set_ub_inv_compat(bmat_inv_ext(1:3,1:3));
end

