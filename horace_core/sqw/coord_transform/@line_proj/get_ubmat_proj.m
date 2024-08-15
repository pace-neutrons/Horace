function ubp = get_ubmat_proj(obj)
%GET_UBMAT_PROJ -- returns ubmat_proj, which is sister projection for
% line_proj
%
if obj.alatt_defined && obj.angdeg_defined
    ubp = ubmat_proj(obj.u_to_rlu,obj.img_scales,...
        obj.alatt,obj.angdeg,obj.offset,obj.label,obj.title);
else
    ubp = ubmat_proj(obj.u_to_rlu,obj.img_scales,...
        'offset',obj.offset,'label',obj.label,'title',obj.title);
end
