function source_proj=set_ortho_ortho_transf_(source_proj)
% sets transformation, which convert image from one orthonormal (source) to another
% orthonormal (target) coordinate system.
%
targ_proj = source_proj.targ_proj_;


[pix_to_img_source,shift_source]= source_proj.get_pix_img_transformation(3);
[pix_to_img_targ,shift_targ]    = targ_proj.get_pix_img_transformation(3);

source_proj.ortho_ortho_offset_ = pix_to_img_targ*(shift_source(:)-shift_targ(:));
source_proj.ortho_ortho_offset_ = [source_proj.ortho_ortho_offset_;source_proj.offset(4)-targ_proj.offset(4)];

source_proj.ortho_ortho_transf_mat_ = pix_to_img_targ/pix_to_img_source;
