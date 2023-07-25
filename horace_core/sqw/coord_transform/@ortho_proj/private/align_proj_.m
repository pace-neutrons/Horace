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
% obj  -- the ortho_proj class, modified by information,
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
% Change Axes. Need to change axes scales in projection coordinate system
if ~isempty(ax_block)
    img_range = ax_block.img_range;
    [full_range,perm] = expand_box(img_range(1,1:3),img_range(2,1:3));
    % Transfer ranges into Crystal Cartesian coordinate system
    range_in_cc  = obj.transform_img_to_pix(full_range); % axes_block sizes

    %Identify nodes nearest to node 1:
    perm_dist = perm - perm(:,1);
    closest_nodes = sum(perm_dist,1)==1;
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
if isempty(ax_block)
    return
end

% Change Axes. Need to change axes scales in projection coordinate system.
% Modified offset is accounted for within the transformation.
full_range_corr = obj.transform_pix_to_img(range_in_cc);
corr_range = [min(full_range_corr,[],2),max(full_range_corr,[],2)];
centre = 0.5*(corr_range(:,1)+corr_range(:,2));
%sizes of the modified box in the image coordinate system
size = vecnorm(full_range_corr(:,closest_nodes)-full_range_corr(:,1));

new_range = [centre-0.5*size(:),centre+0.5*size(:)]';
img_range(:,1:3)   = new_range;
ax_block.img_range = img_range;

