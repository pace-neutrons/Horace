function  contrib_ind = get_contrib_cell_ind_(source_proj,...
    cur_axes_block,target_proj,targ_axes_block)
% Return the indexes of cells, which may contain the nodes,
% belonging to the target axes block by transforming the source
% coordinate system (SCS) into target coordinate system (TCS)
% and interpolating signal on SCS nodes assuming target coordinate system
% area contains unit signal and signal on SCS is interpolated from unary
% values on TCS and zero values outside of TCS.
%

[may_contributeND,may_contribute_dE] = ...
    source_proj.may_contribute(cur_axes_block,target_proj,targ_axes_block);
if isempty(may_contributeND)
    contrib_ind = [];
    return;
end
if source_proj.do_3D_transformation_
    contrib_ind = source_proj.convert_3Dplus1Ind_to_4Dind_ranges(...
        may_contributeND ,may_contribute_dE);
else
    contrib_ind = find(may_contributeND);
end

