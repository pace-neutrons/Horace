function [obj,ax_block] = align_proj_(obj,alignment_info,varargin)
% Apply crystal alignment information to the projection and axes block
% and realign them.
% Inputs:
% obj -- initialized instance of the projection class.
% alignment_info
%     -- crystal_alignment_info class, containing information
%        about new alignment
% Optional:
% ax_block
%     -- instance of the axes_block class
% Returns:
% obj  -- the line_proj class, modified by information,
%         containing in the alignment info class
% ax_block
%      -- instance of the input axes_block class,with the ranges, modified
%         according to alignment information
%
if isempty(obj.w_)
    uvw = [obj.u_(:),obj.v_(:)];
    w_defined = false;
else
    uvw = [obj.u_(:),obj.v_(:),obj.w_(:)];
    w_defined = true;
end
if isempty(varargin)
    ax_block = [];
else
    ax_block = varargin{1};
end
if ~isempty(ax_block)
    % get range of axes in crystal cartezian coordinate system to
    % recalculate it in new aligned projection.
    [range_in_cc,closest_nodes] = obj.get_axes_cc_range(ax_block);
end

alignment_info.hkl_mode = true;
rlu_corr = alignment_info.get_corr_mat(obj);
uvw_corr = rlu_corr*uvw;
obj.u_ = uvw_corr(:,1)';
obj.v_ = uvw_corr(:,2)';
if w_defined
    obj.w_ = uvw_corr(:,3)';
end
if ~isequal(obj.offset_(1:3),zeros(1,3))
    obj.offset_(1:3) = (rlu_corr*obj.offset_(1:3)')';
end

obj.alatt_  = alignment_info.alatt;
obj.angdeg_ = alignment_info.angdeg;
obj = obj.check_combo_arg();
% Change Axes. Need to change axes scales in projection coordinate system
if isempty(ax_block)
    return;
end
ax_block = obj.align_axes(ax_block,range_in_cc,closest_nodes);
