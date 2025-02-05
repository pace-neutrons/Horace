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

if isempty(varargin)
    ax_block = [];
else
    ax_block = varargin{1};
end
% Change Axes. Need to change axes scales in projection coordinate system
if ~isempty(ax_block)
    % get range of axes in crystal cartezian coordinate system to
    % recalculate it in new aligned projection.
    [range_in_cc,closest_nodes] = obj.get_axes_cc_range(ax_block);
end
obj.do_check_combo_arg = false;
alignment_info.hkl_mode = true;
rlu_corr = alignment_info.get_corr_mat(obj);

if any(abs(obj.offset_(1:3)-zeros(1,3))>4*eps('single'))
    obj.offset_(1:3) = (rlu_corr*obj.offset_(1:3)')';
end
obj.u_to_rlu = rlu_corr*obj.u_to_rlu(1:3,1:3);

obj.alatt_  = alignment_info.alatt;
obj.angdeg_ = alignment_info.angdeg;
obj.do_check_combo_arg = true;
obj = obj.check_combo_arg();

% Change Axes. Need to change axes scales in projection coordinate system
if isempty(ax_block)
    return;
end
ax_block = obj.align_axes(ax_block,range_in_cc,closest_nodes);
