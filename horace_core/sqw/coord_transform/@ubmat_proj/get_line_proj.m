function lp = get_line_proj(obj)
%GET_LINE_PROJ -- returns line_proj, which is sister projection for
% ubmat_proj
%

if obj.alatt_defined && obj.angdeg_defined
    lp = line_proj(obj.u,obj.v,obj.w,obj.nonorthogonal,...
        obj.type,obj.alatt,obj.angdeg,obj.offset,obj.label,obj.title);
else
    lp = line_proj(obj.u,obj.v,obj.w,obj.nonorthogonal,...
        obj.type,'offset',obj.offset,'label',obj.label,'title',obj.title);
end
% transfer symmetry transformation if one is defined
if ~isempty(obj.sym_transf_)
    lp.sym_transf = obj.sym_transf_;
end
