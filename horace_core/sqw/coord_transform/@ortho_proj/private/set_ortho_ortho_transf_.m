function obj=set_ortho_ortho_transf_(obj)
% sets transformation, which convert image from one orhtonormal to another
% orthonormal system coordinates.
%
targ_proj = obj.targ_proj_;


[rot_to_img_source,shift_source]=obj.get_pix_img_transformation(3);
[rot_to_img_targ,shift_targ]=targ_proj.get_pix_img_transformation(3);

obj.ortho_ortho_offset_ = (shift_source'-shift_targ')*rot_to_img_targ';
obj.ortho_ortho_offset_ = [obj.ortho_ortho_offset_,obj.offset(4)-targ_proj.offset(4)];

obj.ortho_ortho_transf_mat_ = rot_to_img_source'\rot_to_img_targ';
