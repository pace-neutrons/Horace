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
if exist('header_av','var') && isfield(header_av,'u_to_rlu')
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
difr = obj.img_db_range - pix_range;
if  ~isempty(bmat_inv_ext) && all(abs(difr(:))<=1.e-4) % the input is the raw sqw object
    u_transf = (inv(bmat_inv_ext(1:3,1:3))/bmatrix(proj.alatt,proj.angdeg))';
    
    proj = proj.set_from_data_mat(u_transf,[1,1,1]);
else % the input is the cut
    u_transf = (inv(obj.u_to_rlu(1:3,1:3))/bmatrix(proj.alatt,proj.angdeg))';
    proj = proj.set_from_data_mat(u_transf,obj.ulen(1:3));
end

